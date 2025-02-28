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

#### RLS Policies

- SELECT: Enable users to select accounts based on the incoming authenticated user id matching the user_id on the selected account
- INSERT: Enable users to insert accounts based on the incoming authenticated user id matching the user_id on the inserted account
- UPDATE: Enable users to update accounts based on the incoming authenticated user id matching the user_id on the updated account
- DELETE: Enable users to delete accounts based on the incoming authenticated user id matching the user_id on the deleted account


#### Notes

- This table is realtime for updates and deletes so `alter table
  accounts replica identity full` was run to allow that

## Stored Procedures

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

# To Be Implemented

## Tables

### **Accounts**

- `order_index` (INTEGER) - Custom ordering for UI.

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

```sql
CREATE OR REPLACE FUNCTION update_account_balances()
RETURNS TRIGGER AS $$
BEGIN
    -- On INSERT, add the transaction amount to the balance
    IF TG_OP = 'INSERT' THEN
        UPDATE accounts
        SET available_balance = available_balance + NEW.amount,
            current_balance = current_balance + CASE WHEN NEW.cleared THEN NEW.amount ELSE 0 END
        WHERE id = NEW.account_id;

    -- On DELETE, subtract the transaction amount
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE accounts
        SET available_balance = available_balance - OLD.amount,
            current_balance = current_balance - CASE WHEN OLD.cleared THEN OLD.amount ELSE 0 END
        WHERE id = OLD.account_id;

    -- On UPDATE, adjust for changes in amount or cleared status
    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE accounts
        SET available_balance = available_balance - OLD.amount + NEW.amount,
            current_balance = current_balance - (CASE WHEN OLD.cleared THEN OLD.amount ELSE 0 END) + (CASE WHEN NEW.cleared THEN NEW.amount ELSE 0 END)
        WHERE id = NEW.account_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER transaction_balance_trigger
AFTER INSERT OR DELETE OR UPDATE ON transactions
FOR EACH ROW EXECUTE FUNCTION update_account_balances();
```

## Edge Functions

### **Scheduled Transaction Processor**

Runs periodically to apply due scheduled transactions.

```js
import { createClient } from '@supabase/supabase-js';
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export default async function apply_scheduled_transactions() {
    const now = new Date();
    const { data: scheduled } = await supabase
        .from('scheduled_transactions')
        .select('*')
        .lte('next_application_date', now.toISOString());

    for (const txn of scheduled) {
        await supabase.from('transactions').insert({
            account_id: txn.account_id,
            name: txn.name,
            amount: txn.amount,
            type: txn.type,
            cleared: txn.cleared,
            transaction_date: txn.next_application_date
        });

        // Update next application date
        let newDate = new Date(txn.next_application_date);
        if (txn.frequency === 'Daily') newDate.setDate(newDate.getDate() + 1);
        else if (txn.frequency === 'Weekly') newDate.setDate(newDate.getDate() + 7);
        else if (txn.frequency === 'Monthly') newDate.setMonth(newDate.getMonth() + 1);
        else if (txn.frequency === 'Yearly') newDate.setFullYear(newDate.getFullYear() + 1);

        await supabase
            .from('scheduled_transactions')
            .update({ next_application_date: newDate.toISOString() })
            .eq('id', txn.id);
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