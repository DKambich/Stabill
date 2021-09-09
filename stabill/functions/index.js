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

function getSignFromMethod(method) {
  return method == "TransactionType.Withdrawal" ? -1 : 1;
}

exports.onCreateTransaction = functions.firestore
  .document("/users/{userID}/accounts/{accountID}/transactions/{transactionID}")
  .onCreate(async (snap, context) => {
    const transaction = snap.data();

    let amount = transaction.amount * getSignFromMethod(transaction.method);

    const accountRef = snap.ref.parent.parent;
    updateAccountBalance(accountRef, amount, transaction.cleared ? amount : 0);
  });

exports.onUpdateTransaction = functions.firestore
  .document("/users/{userID}/accounts/{accountID}/transactions/{transactionID}")
  .onUpdate(async (change, context) => {
    const oldTransaction = change.before.data();
    const newTransaction = change.after.data();
    const accountRef = change.after.ref.parent.parent;

    const oldAmount =
      oldTransaction.amount * getSignFromMethod(oldTransaction.method) * -1;
    const newAmount =
      newTransaction.amount * getSignFromMethod(newTransaction.method);
    updateAccountBalance(
      accountRef,
      oldAmount + newAmount,
      (oldTransaction.cleared ? oldAmount : 0) +
        (newTransaction.cleared ? newAmount : 0)
    );

    updateAccountBalance(accountRef, newAmount);
  });
exports.onDeleteTransaction = functions.firestore
  .document("/users/{userID}/accounts/{accountID}/transactions/{transactionID}")
  .onDelete(async (snap, context) => {
    const transaction = snap.data();

    let amount =
      transaction.amount * getSignFromMethod(transaction.method) * -1;

    const accountRef = snap.ref.parent.parent;
    const account = await accountRef.get();
    if (account == undefined || account == null) return;
    updateAccountBalance(accountRef, amount, transaction.cleared ? amount : 0);
  });
