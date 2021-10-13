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

    const docs = await query.get();
    docs.forEach(function (doc) {
      const docData = doc.data();
      doc.ref.parent.parent.collection("transactions").add({
        name: docData.name,
        amount: docData.amount,
        checkNumber: docData.checkNumber,
        memo: docData.memo,
        timestamp: docData.timestamp,
        cleared: docData.cleared,
        hidden: docData.hideIfCleared ? docData.cleared : false,
        method: docData.method,
      });

      const currentDelta =
        docData.amount *
        (docData.method == "TransactionType.Withdrawal" ? -1 : 1);
      const availDelta = docData.cleared ? currentDelta : 0;

      doc.ref.parent.parent.update({
        availableBalance: admin.firestore.FieldValue.increment(availDelta),
        currentBalance: admin.firestore.FieldValue.increment(currentDelta),
      });

      const frequency = docData.frequency;
      console.log(frequency);
      const nextDate = docData.timestamp.toDate();
      switch (frequency) {
        case "Frequency.once":
          docData.enabled = false;
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
      docData.timestamp = nextDate;
      doc.ref.update(docData);
    });
    console.debug(`This function found ${docs.size} documents`);
  });
