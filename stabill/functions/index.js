const functions = require("firebase-functions");
const firebase_tools = require("firebase-tools");
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.recursiveAccountDelete = functions.firestore
  .document("/users/{userID}/accounts/{accountID}")
  .onDelete(async (snap, context) => {
    // Only allow admin users to execute this function.
    const userID = context.params.userID, accountID = context.params.accountID;
    console.log(
      `User ${userID} has requested to delete account ${accountID}`
    );

    console.log(
      `Deleting transaction subcollection of account ${accountID}`
    );

    // Run a recursive delete on the given document or collection path.
    // The 'token' must be set in the functions config, and can be generated
    // at the command line by running 'firebase login:ci'.
    await firebase_tools.firestore.delete(
      `/users/$${userID}/accounts/${accountID}/transactions`,
      {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
        token: functions.config().fb.token,
      }
    );
  });
