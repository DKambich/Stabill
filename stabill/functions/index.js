const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.deleteUserData = functions.auth.user().onDelete(async (user) => {
  const userDoc = admin.firestore().collection("users").doc(user.uid);
  const userAccounts = await userDoc.collection("accounts").get();
  const deletedAccounts = userAccounts.docs.map((doc) => doc.ref.delete());

  await Promise.allSettled(deletedAccounts);
  await userDoc.delete();
});

exports.onDeleteAccount = functions.firestore
  .document("/users/{userID}/accounts/{accountID}")
  .onDelete(async (snap, context) => {
    // Get all Transactions of the Account and queue their deletion
    let deletedDocs = (
      await snap.ref.collection("transactions").get()
    ).docs.map((doc) => doc.ref.delete());

    // Get all ScheduledTransactions of the Account and queue their deletion
    deletedDocs.push(
      (await snap.ref.collection("scheduledTransactions").get()).docs.map(
        (doc) => doc.ref.delete()
      )
    );

    // Delete all the queued docs
    await Promise.allSettled(deletedDocs);
  });

exports.processScheduledTransactions = functions.pubsub
  .schedule("*/5 * * * *")
  .onRun(async (context) => {
    // Retrieve all ScheduledTransactions that are enabled and are past processing time
    const query = admin
      .firestore()
      .collectionGroup("scheduledTransactions")
      .where("enabled", "=", true)
      .where("timestamp", "<", admin.firestore.Timestamp.now());

    const retrievedTransactions = await query.get();

    // For each document
    retrievedTransactions.forEach(function (transaction) {
      const transactionData = transaction.data();
      const parentAccount = transaction.ref.parent.parent;

      // Add a transaction from the ScheduledTransaction metadata
      parentAccount.collection("transactions").add({
        name: transactionData.name,
        amount: transactionData.amount,
        checkNumber: transactionData.checkNumber,
        memo: transactionData.memo,
        timestamp: transactionData.timestamp,
        cleared: transactionData.cleared,
        hidden: transactionData.hideIfCleared ? transactionData.cleared : false,
        method: transactionData.method,
      });

      // Calculate the Account balance deltas
      const currentDelta =
      transactionData.amount *
        (transactionData.method == "TransactionType.withdrawal" ? -1 : 1);
      const availDelta = transactionData.cleared ? currentDelta : 0;

      // Update the Account balances
      parentAccount.update({
        availableBalance: admin.firestore.FieldValue.increment(availDelta),
        currentBalance: admin.firestore.FieldValue.increment(currentDelta),
      });

      // Update the ScheduledTransaction fields 
      const nextDate = transactionData.timestamp.toDate();
      const updates = {};
      switch (transactionData.frequency) {
        case "Frequency.once":
          updates["enabled"] = false;
          break;
        case "Frequency.daily":
          nextDate.setDate(nextDate.getDate() + 1);
          break;
        case "Frequency.weekly":
          nextDate.setDate(nextDate.getDate() + 7);
          break;
        case "Frequency.biweekly":
          nextDate.setDate(nextDate.getDate() + 14);
          break;
        case "Frequency.endOfMonth":
          nextDate.setMonth(nextDate.getMonth() + 1);
          nextDate.setDate(0);
          break;
        case "Frequency.monthly":
          nextDate.setMonth(nextDate.getMonth() + 1);
          break;
        case "Frequency.yearly":
          nextDate.setFullYear(nextDate.getFullYear() + 1);
          break;
      }
      updates["timestamp"] = nextDate;
      transaction.ref.update(updates);
    });
    console.debug(`This function updated ${retrievedTransactions.size} documents`);
  });
