# **Tasks**

## General

- Screens
  - Login 🚧
  - Create Account
  - Home
    - Account List 🚧
    - Insights
  - Settings
  - Transactions 🚧
- Feature: Dark mode and improved themeing
- Feature: Import data from Checkbook
- Feature: Export data to CSV
- Improvement: Use proper capitalization and keyboard type for TextInputs
- Improvement: Dispose of controllers when finished with widgets
- Improvement: Better error handling for promises
- Improvement: Ensure any modification to account balances are rounded to 2 decimals
- Responsive UI: https://pub.dev/packages/responsive_builder
  - Improvement: Convert modals to 'prompts' that show as dialogs on large screens or modals on small screens
  - Improvement: Convert lists to grids on larger screen sizes

## Accounts

- UI: Display Account List ✅
  - Show list of accounts ✅
  - Show cumulative balance of accounts ✅
- Action: Create account ✅
  - Improvement: Convert the new account dialog to bottom sheet ✅
- Action: Delete account ✅
  - Improvement: Add OnDelete to delete the transactions subcollection ✅
- Action: Rename account
- Action: Reorder accounts
- Action: Transfer funds between accounts ✅
  - Improvement: Create a withdrawal/deposit transaction for each account respectively, rather than directly modifying ✅

## Transactions

- UI: Display Transaction List 🚧
  - Show list of transactions ✅
  - Show balance of account ✅
    - Improvement: OnWrite of a transaction to update the balance of the account ✅
  - Enhancement: Hide FAB onScroll
- Feature: Popup menu on button press per transaction ✅
  - Action: Delete transaction ✅
  - Action: Edit transaction ✅
  - Action: Mark transaction as cleared (show only if not cleared) ✅
  - Action: Hide transaction (show only if cleared)
  - Action: Transfer transaction to another account
- Feature: Searching transactions by name
- Feature: Sorting transaction
  - Default sort by date ✅
  - Sorting by other properties
- Feature: Balance correction ✅
- Feature: Scheduled transactions
