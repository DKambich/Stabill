# **Tasks**

## General

- Screens
  - Login 🚧
  - Create Account
  - Home
    - Account List 🚧
    - Insights (https://pub.dev/packages/syncfusion_flutter_charts)
  - Settings
  - Transactions 🚧
- Feature: Dark mode and improved theming ✅
- Feature: Import data from Checkbook ✅
- Feature: In-App Notifications/Messages
  - https://pub.dev/packages/flash#getting-started
  - https://pub.dev/packages/fluttertoast
  - https://resocoder.com/2021/01/30/snackbar-toast-dialog-in-flutter-flash-package/
- Feature: App Notifications
  - https://firebase.flutter.dev/docs/messaging/apple-integration/
  - https://firebase.flutter.dev/docs/messaging/notifications/
  - https://firebase.flutter.dev/docs/messaging/server-integration/
- Feature: Export data to CSV
- Improvement: Use proper capitalization and keyboard type for TextInputs
- Improvement: Dispose of controllers when finished with widgets
- Improvement: Better error handling for promises
- Improvement: Add better tooltips for buttons
- Improvement: Add commas to BalanceText ✅

- Responsive UI: https://pub.dev/packages/responsive_builder || https://pub.dev/packages/responsive_framework
  - Improvement: Convert modals to 'prompts' that show as dialogs on large screens or modals on small screens
  - Improvement: Convert lists to grids on larger screen sizes

- Improvement: Delete user data upon deleting account
  - https://firebase.google.com/docs/functions/auth-events#trigger_a_function_on_user_deletion

## Accounts

- UI: Display Account List ✅
  - Show list of accounts ✅
  - Show cumulative balance of accounts ✅
- Action: Create account ✅
  - Improvement: Convert the new account dialog to bottom sheet ✅
- Action: Delete account ✅
  - Improvement: Add OnDelete to delete the transactions subcollection ✅
- Action: Rename account ✅
- Action: Reorder accounts
  - https://pub.dev/packages/reorderableitemsview
  - https://pub.dev/packages/reorderable_grid_view
- Action: Transfer funds between accounts ✅
  - Improvement: Create a withdrawal/deposit transaction for each account respectively, rather than directly modifying ✅
- Improvement: Display accounts differently based on screen size
  - https://api.flutter.dev/flutter/widgets/GridView-class.html

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
      - Enhancement: Allow user preference to display non-cleared transactions first
  - Action: Hide transaction (show only if cleared)
  - Action: Transfer transaction to another account
- Feature: Searching transactions by name
  - Enhancement: Allow for autocompleting of top 10-15 common items (https://api.flutter.dev/flutter/material/Autocomplete-class.html)
    - https://stackoverflow.com/questions/55579906/how-to-count-items-occurence-in-a-list
    - https://stackoverflow.com/questions/61343000/dart-sort-list-by-two-properties#61343892
- Feature: Sorting transaction
  - Default sort by date ✅
  - Sorting by other properties
- Feature: Balance correction ✅
- Feature: Scheduled transactions
  - https://stackoverflow.com/questions/47659525/creating-a-document-in-firestore-using-cloud-functions
