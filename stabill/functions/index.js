const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onDeleteAccount = functions.firestore
  .document("/users/{userID}/accounts/{accountID}")
  .onDelete(async (snap, context) => {
    // Only allow admin users to execute this function.
    const userID = context.params.userID,
      accountID = context.params.accountID;
    console.log(
      `User ${userID} has requested to delete account ${accountID} and it's subcollection`
    );

    const deletedDocs = (
      await snap.ref.collection("/transactions").get()
    ).docs.map((doc) => doc.ref.delete());

    await Promise.allSettled(deletedDocs);
  });

function updateAccountBalance(accountRef, currentDelta, availableDelta) {
  accountRef
    .update({
      currentBalance: admin.firestore.FieldValue.increment(currentDelta),
      availableBalance: admin.firestore.FieldValue.increment(availableDelta),
    })
    .catch((error) => console.log(error));
}

exports.onCreateTransaction = functions.firestore
  .document("/users/{userID}/accounts/{accountID}/transactions/{transactionID}")
  .onCreate(async (snap, context) => {
    const transaction = snap.data();
    const amount =
      transaction.method == "TransactionType.Withdrawal"
        ? -transaction.amount
        : transaction.amount;
    const accountRef = snap.ref.parent.parent;
    updateAccountBalance(accountRef, amount, transaction.cleared ? amount : 0);
  });

exports.onDeleteTransaction = functions.firestore
  .document("/users/{userID}/accounts/{accountID}/transactions/{transactionID}")
  .onDelete(async (snap, context) => {
    const transaction = snap.data();
    const amount =
      transaction.method == "TransactionType.Withdrawal"
        ? transaction.amount
        : -transaction.amount;
    const accountRef = snap.ref.parent.parent;
    const account = (await accountRef.get()).data();
    if (account == null || account == undefined) {
      return;
    }
    updateAccountBalance(accountRef, amount, transaction.cleared ? 0 : amount);
  });
