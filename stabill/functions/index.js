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
    // docs.forEach(function (doc) {});
    console.debug(`This function found ${docs.size} documents`);
  });
