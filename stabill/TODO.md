# **Tasks**
## General
- Feature: Dark mode and improved themeing
- Feature: Login and create account page and flow
- Feature: Import data from Checkbook
- Feature: Export data to CSV
## Accounts
- Action: Delete account
- Action: Reorder accounts
- Improvement: When transfering between accounts, create a seperate withdrawal/depoist transaction for each account respectively, rather than modifying the accounts directly
- Improvement: Convert the new account dialog to bottom sheet
## Transactions
- Feature: Create Popup menu when long pressing TransactionCards
	- Action: Delete transaction
	- Action: Edit transaction
	- Action: Mark transaction as cleared (show only if not cleared)
- Feature: Sort transactions by date (Allow future sorting by other properties?)
- Feature: Search transactions by transaction name
- Feature: Balance correction (create a transaction that will update account to given balance)
- Improvement: OnCreate, OnDelete, and OnChange of a transaction should update the balance of the parent account
- Feature: Scheduled transactions
