# Stabill

TODO: Add Project Description

# Stabill - Feature & Architecture To-Do List

## 🚀 Core Setup
- [x] Create repository and initialize Flutter project
- [x] Set up Supabase backend

## 🔐 Authentication
- [ ] Implement user sign-up using Supabase Auth
- [ ] Implement password reset flow using Supabase Auth
- [ ] Link users to their data in Supabase
- [ ] Use [Secure Storage](https://pub.dev/packages/supabase_flutter#a-idcustom-localstorageacustom-localstorage) for user sessions

## 🏦 Accounts
- [ ] Allow users to create, rename, archive, and delete accounts
- [ ] Store and display account fields:
  - [ ] Name
  - [ ] Created date
  - [ ] Current balance
  - [ ] Available balance
  - [ ] Archived status
- [ ] Enable account display order customization:
  - [ ] Custom
  - [ ] Name
  - [ ] Balance

## 💸 Transactions
- [ ] Create, edit, archive, and delete transactions
- [ ] Support transaction fields:
  - [ ] Name
  - [ ] Amount (in cents)
  - [ ] Cleared status
  - [ ] Transaction date
  - [ ] Type (withdrawal/deposit)
  - [ ] Check number
  - [ ] Archived status
  - [ ] Memo
- [ ] Implement categorization:
  - [ ] Manual
  - [ ] Automatic
- [ ] Ensure uncleared transactions count toward current balance only
- [ ] Ensure cleared transactions count toward both balances
- [ ] Maintain real-time balance updates when transactions change
- [ ] Allow moving transactions between accounts
- [ ] Implement infinite scrolling and real-time updates for transactions
- [ ] Enable sorting transactions by date and optionally prioritize uncleared transactions
- [ ] Implement autocomplete for transaction names based on recent entries
- [ ] Add bulk export and import for transactions
- [ ] Implement hiding transactions

## 🔄 Transfers & Balancing
- [ ] Enable fund transfers between accounts (withdrawal from one, deposit into another)
- [ ] Implement balance correction via a cleared transaction

## ⏳ Scheduled Transactions
- [ ] Implement scheduled transactions with fields:
  - [ ] Linked account
  - [ ] Start date
  - [ ] Next application date
  - [ ] Frequency
- [ ] Create Supabase Edge Function to apply due scheduled transactions every minute
- [ ] Send push notifications for scheduled transactions (Android only)
- [ ] Display scheduled transaction alerts in a notification section (for Web & Windows)

## 🎨 UI & UX
- [ ] Implement light, dark, and system themes with automatic switching
- [ ] App Icons
- [ ] App Splashscreens
- [ ] Support account and transaction filtering and sorting
- [ ] Display clear indicators when no more data is available

## 🧩 Mockable Architecture
- [ ] Design services with a mockable layer to run without Supabase while maintaining the same interface

## 📡 Real-Time Features
- [ ] Implement real-time streaming for account and transaction changes

## 🔗 Advanced Integrations
- [ ] Integrate Plaid for transaction categorization and account linking
- [ ] Implement AI-based auto-categorization for transactions

## 🔒 Security & RLS
- [ ] Implement Row Level Security (RLS) for user-linked data in Supabase
- [ ] Secure scheduled transaction execution using Supabase Edge Functions or PostgreSQL functions

Investigate: https://supabase.com/dashboard/project/vyuqaamvpzcuyawldpcz/settings/api-keys/new


## Running Supabase locally

You will need to have Docker Desktop and the Supabase CLI installed to run.
https://supabase.com/docs/guides/local-development

Edge Functions
https://supabase.com/docs/guides/functions/quickstart