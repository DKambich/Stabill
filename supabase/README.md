# Database Implementation Overview

This document provides a summary of the database schema, RLS (row-level security) policies, stored procedures, triggers, and edge functions haven been (and will be) implemented for Stabill.

## Tables

### **Users**

Stores user authentication and identity information using Supabase's built-in auth system.

### **Accounts**

Stores user-created accounts with their respective balances.

#### Columns

- `id` (uuid, Primary Key)
- `user_id` (uuid, Foreign Key -> Users) - The linked user that owns the account
- `name` (text) - The name of the account
- `created_at` (timestamp with time zone) - The time and date in UTC that the account was created at
- `current_balance` (integer) - The current balance (includes cleared and pending transactions) of the account in cents.
- `available_balance` (integer) - The available balance (only includes cleared transactions) of the account in cents.
- `is_archived` (boolean) - Whether the account is archived
- `order_index` (integer) - The user's display order for the account

#### RLS Policies

- SELECT: Enable users to select accounts based on the incoming authenticated user id matching the user_id on the selected account
- INSERT: Enable users to insert accounts based on the incoming authenticated user id matching the user_id on the inserted account
- UPDATE: Enable users to update accounts based on the incoming authenticated user id matching the user_id on the updated account
- DELETE: Enable users to delete accounts based on the incoming authenticated user id matching the user_id on the deleted account

#### Notes

- This table is realtime for updates and deletes so `alter table
accounts replica identity full` was run to allow that
- Deleting an account relies on the existing foreign-key cascade to remove its
  related transactions; the account DELETE policy controls access.

## Stored Procedures

### **ping**

Returns a static response to keep the Supabase project alive.

#### Outputs

'pong'

### **create_account**

Creates an account for the user based on the inputted account name and starting balance. If starting balance is greater than zero, it creates a cleared transaction to apply the starting balance to both the `current_balance` and `available_balance` of the created account.

#### Parameters

- `p_user_id` (uuid, Foreign Key -> Users) - The user id of the user that owns the account
- `p_account_name` (text) - The name of the account
- `p_starting_balance` (integer) - The starting balance of the account

#### Outputs

The record of the created account

#### Exceptions

- Raises an exception if the account name is null or empty
- Raises an exception if the starting balance is less than 0

### **reorder_accounts**

Updates the display order for the supplied account IDs. The function runs as
the caller, so the accounts UPDATE RLS policy controls which rows can change.
The account IDs are passed as a JSON array through the `jsonb` parameter.

Run this in the Supabase SQL editor:

```sql
create or replace function public.reorder_accounts(p_account_ids jsonb)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_account_id uuid;
  v_order_index integer := 0;
begin
  if jsonb_typeof(p_account_ids) <> 'array' then
    raise exception 'Account IDs must be a JSON array';
  end if;

  for v_account_id in
    select item.value::uuid
    from jsonb_array_elements_text(p_account_ids) with ordinality
      as item(value, position)
    order by item.position
  loop
    update public.accounts
    set order_index = v_order_index
    where id = v_account_id;

    v_order_index := v_order_index + 1;
  end loop;
end;
$$;

revoke all on function public.reorder_accounts(jsonb) from public;
grant execute on function public.reorder_accounts(jsonb) to authenticated;
```

### **transfer_funds**

Creates a cleared withdrawal in the source account and a cleared deposit in the destination account. The withdrawal is named `Transfer to {destination account name}` and the deposit is named `Transfer from {source account name}`. Both inserts run in one database transaction, so either both records are created or neither is.

#### Parameters

- `p_from_account_id` (uuid) - The source account
- `p_to_account_id` (uuid) - The destination account
- `p_amount` (bigint) - Positive amount in cents

#### Outputs

Returns `void`.

#### Exceptions

- Raises an exception if the source and destination accounts are the same
- Raises an exception if the amount is null or less than or equal to zero
- Raises an exception if either account cannot be found or accessed

The function runs as the caller and relies on the account and transaction row-level security policies. A transaction trigger updates account balances; the function does not change balances directly.

#### Implementation

```sql
create or replace function public.transfer_funds(
  p_from_account_id uuid,
  p_to_account_id uuid,
  p_amount bigint
)
returns void
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_transfer_date timestamptz := now();
  v_from_account_name text;
  v_to_account_name text;
begin
  if p_from_account_id = p_to_account_id then
    raise exception 'Transfer accounts must be different';
  end if;

  if p_amount is null or p_amount <= 0 then
    raise exception 'Transfer amount must be greater than zero';
  end if;

  select name into v_from_account_name
  from public.accounts
  where id = p_from_account_id;
  if not found then
    raise exception 'Source account not found';
  end if;

  select name into v_to_account_name
  from public.accounts
  where id = p_to_account_id;
  if not found then
    raise exception 'Destination account not found';
  end if;

  insert into public.transactions (
    account_id, name, amount, transaction_date,
    transaction_type, transaction_category, is_cleared, is_archived
  ) values (
    p_from_account_id,
    'Transfer to ' || v_to_account_name,
    p_amount,
    v_transfer_date,
    'withdrawal',
    'none',
    true,
    false
  );

  insert into public.transactions (
    account_id, name, amount, transaction_date,
    transaction_type, transaction_category, is_cleared, is_archived
  ) values (
    p_to_account_id,
    'Transfer from ' || v_from_account_name,
    p_amount,
    v_transfer_date,
    'deposit',
    'none',
    true,
    false
  );
end;
$$;
```

### **correct_account_balance**

Corrects an account to a target current balance by creating one cleared deposit or withdrawal for the difference. The target is expressed in cents and may be negative. The function locks the account row while reading its current balance, so concurrent corrections are serialized. If the account already has the target balance, no transaction is created and the function returns `false`.

#### Parameters

- `p_account_id` (uuid) - The account to correct
- `p_target_balance` (bigint) - The target current balance in cents

#### Outputs

Returns `true` when a balance-correction transaction is created, or `false` when no correction is needed.

The function runs as the caller and relies on account and transaction row-level security policies. A transaction trigger must update `current_balance` and `available_balance`; the function does not update account balances directly.

#### Implementation

```sql
create or replace function public.correct_account_balance(
  p_account_id uuid,
  p_target_balance bigint
)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_current_balance bigint;
  v_adjustment bigint;
  v_adjustment_date timestamptz := now();
begin
  if p_account_id is null then
    raise exception 'Account id is required';
  end if;

  if p_target_balance is null then
    raise exception 'Target balance is required';
  end if;

  if p_target_balance < -2147483648
     or p_target_balance > 2147483647 then
    raise exception 'Target balance is outside the supported range';
  end if;

  select current_balance into v_current_balance
  from public.accounts
  where id = p_account_id
  for update;

  if not found then
    raise exception 'Account not found';
  end if;

  v_adjustment := p_target_balance - v_current_balance;

  if v_adjustment = 0 then
    return false;
  end if;

  if v_adjustment > 0 then
    insert into public.transactions (
      account_id,
      name,
      amount,
      transaction_date,
      transaction_type,
      transaction_category,
      is_cleared,
      is_archived
    ) values (
      p_account_id,
      'Balance correction',
      v_adjustment,
      v_adjustment_date,
      'deposit',
      'other',
      true,
      false
    );
  else
    insert into public.transactions (
      account_id,
      name,
      amount,
      transaction_date,
      transaction_type,
      transaction_category,
      is_cleared,
      is_archived
    ) values (
      p_account_id,
      'Balance correction',
      abs(v_adjustment),
      v_adjustment_date,
      'withdrawal',
      'other',
      true,
      false
    );
  end if;

  return true;
end;
$$;

grant execute on function public.correct_account_balance(uuid, bigint)
  to authenticated;
```

# To Be Implemented

## Tables

### **Transactions**

Stores financial transactions linked to an account.

- `id` (UUID, Primary Key)
- `account_id` (UUID, Foreign Key -> Accounts)
- `name` (TEXT)
- `amount` (BIGINT) - Stored in cents to avoid floating-point issues.
- `type` (ENUM) - Either `deposit` or `withdrawal`.
- `cleared` (BOOLEAN)
- `transaction_date` (TIMESTAMP)
- `check_number` (INTEGER, Nullable)
- `memo` (TEXT, Nullable)
- `archived` (BOOLEAN)

#### RLS Policies

- SELECT: Enable users to select transactions based on the related account belonging to the incoming authenticated user id
- INSERT: Enable users to insert transactions based on the related account belonging to the incoming authenticated user id
- UPDATE: Enable users to update transactions based on the related account belonging to the incoming authenticated user id
- DELETE: Enable users to delete transactions based on the related account belonging to the incoming authenticated user id

### **Scheduled Transactions**

Manages recurring transactions that automatically apply at set intervals.

- `id` (UUID, Primary Key)
- `account_id` (UUID, Foreign Key -> Accounts)
- `name` (TEXT)
- `amount` (BIGINT)
- `type` (ENUM) - Either `deposit` or `withdrawal`.
- `cleared` (BOOLEAN)
- `start_date` (TIMESTAMP)
- `next_application_date` (TIMESTAMP)
- `frequency` (ENUM) - Daily, Weekly, Monthly, Yearly

## Triggers

### **Trigger: Update Account Balances on Transaction Insert/Delete/Update**

Automatically updates `current_balance` and `available_balance` on the Accounts table when a transaction is added, updated, or deleted.

The trigger applies deposits and withdrawals with the correct sign. `current_balance` includes cleared and uncleared transactions; `available_balance` includes only cleared transactions. Updates that move a transaction between accounts reverse its effect on the old account and apply it to the new one. The implementation is in `migrations/20261018000000_transfer_funds.sql`.

## Edge Functions

### **Scheduled Transaction Processor**

Runs periodically to apply due scheduled transactions.

```js
import { createClient } from "@supabase/supabase-js";
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export default async function apply_scheduled_transactions() {
  const now = new Date();
  const { data: scheduled } = await supabase
    .from("scheduled_transactions")
    .select("*")
    .lte("next_application_date", now.toISOString());

  for (const txn of scheduled) {
    await supabase.from("transactions").insert({
      account_id: txn.account_id,
      name: txn.name,
      amount: txn.amount,
      type: txn.type,
      cleared: txn.cleared,
      transaction_date: txn.next_application_date,
    });

    // Update next application date
    let newDate = new Date(txn.next_application_date);
    if (txn.frequency === "Daily") newDate.setDate(newDate.getDate() + 1);
    else if (txn.frequency === "Weekly") newDate.setDate(newDate.getDate() + 7);
    else if (txn.frequency === "Monthly")
      newDate.setMonth(newDate.getMonth() + 1);
    else if (txn.frequency === "Yearly")
      newDate.setFullYear(newDate.getFullYear() + 1);

    await supabase
      .from("scheduled_transactions")
      .update({ next_application_date: newDate.toISOString() })
      .eq("id", txn.id);
  }
}
```

## Indexing

Indexes were added for efficient querying:

```sql
CREATE INDEX idx_transactions_account_id ON transactions (account_id);
CREATE INDEX idx_transactions_date ON transactions (transaction_date DESC);
CREATE INDEX idx_scheduled_transactions_date ON scheduled_transactions (next_application_date ASC);
```

## Summary of Features

- **Accounts Management**: Create, rename, archive, and order accounts.
- **Transaction Management**: Add, edit, delete, and categorize transactions with pagination and real-time updates.
- **Scheduled Transactions**: Auto-applies transactions on set intervals.
- **Balances**: Atomic updates to account balances with triggers.
- **Realtime Updates**: Transactions and account balances update dynamically.
- **Bulk Import/Export**: Supports CSV-based transaction management.
