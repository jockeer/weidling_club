import 'package:firebase_messaging/firebase_messaging.dart';


class PushNotificacionProvider{

     FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    void initNotifications(){

        _firebaseMessaging.requestNotificationPermissions();

    }

    Future<String> obtainToken() async {

          String token =  await this._firebaseMessaging.getToken();
          return token;
    }
}