import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

class MessageProvider {
  // final FirebaseMessaging firebaseMessaging;
  final User? user;

  MessageProvider(
    //this.firebaseMessaging,
    this.user,
  );

  Future<bool> requestPermissions() async {
    return false;
  }

  Future<void> subscribe() async {
    try {
      if (user == null) throw Exception("User is not signed in");
      // final String uid = user!.uid;
      // await firebaseMessaging.subscribeToTopic(uid);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unsubscribe() async {
    try {
      if (user == null) throw Exception("User is not signed in");
      // final String uid = user!.uid;
      // await firebaseMessaging.unsubscribeFromTopic(uid);
    } catch (e) {
      rethrow;
    }
  }
}
