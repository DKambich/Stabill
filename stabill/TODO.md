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
## Accounts
- UI: Display Account List ✅
	- Show list of accounts ✅
	- Show cumulative balance of accounts ✅
- Action: Create account 🚧
	- Improvement: Convert the new account dialog to bottom sheet 
- Action: Delete account ✅
	- Improvement: Add OnDelete to delete the transactions subcollection

- Action: Rename account
- Action: Reorder accounts
- Action: Transfer funds between accounts 🚧
	- Improvement: Create a withdrawal/deposit transaction for each account respectively, rather than directly modifying
## Transactions
- UI: Display Transaction List ✅
	- Show list of transactions ✅
	- Show balance of account ✅
		- Improvement: Add OnCreate, OnDelete, and OnChange of a transaction to update the balance of the parent account dynamically
- Feature: Popup menu when long pressing transactions ✅
	- Action: Delete transaction ✅
	- Action: Edit transaction ✅
	- Action: Mark transaction as cleared (show only if not cleared) ✅
- Feature: Searching transactions by  name
- Feature: Sorting transaction
	- Default sort by date ✅
	- Sorting by other properties 
- Feature: Balance correction
- Feature: Scheduled transactions
- Feature: Transfer transactions to another account
- Feature: Hide transactions
- Enhancement: Hide FAB onScroll