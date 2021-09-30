const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onDeleteAccount = functions.firestore
  .document("/users/{userID}/accounts/{accountID}")
  .onDelete(async (snap, context) => {
    const deletedDocs = (
      await snap.ref.collection("/transactions").get()
    ).docs.map((doc) => doc.ref.delete());

    await Promise.allSettled(deletedDocs);
  });

exports.processRecurringTransactions = functions.pubsub
  .schedule("*/5 * * * *")
  .onRun(async (context) => {
    const query = admin
      .firestore()
      .collectionGroup("recurringTransactions")
      .where("enabled", "=", true)
      .where("timestamp", "<", admin.firestore.Timestamp.now());

    const docs = await query.get();
    // docs.forEach(function (doc) {});
    console.debug(`This function found ${docs.size} documents`);
  });
