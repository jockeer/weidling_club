import 'package:firebase_messaging/firebase_messaging.dart';


class PushNotificacionProvider{
     FirebaseMessaging _firebaseMessaging =  FirebaseMessaging.instance;

    void initNotifications(){

        _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

    }

    Future<String> obtainToken() async {

          String token =  await this._firebaseMessaging.getToken();
          return token;
    }
}