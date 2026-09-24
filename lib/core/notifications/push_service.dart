import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';

/// Handles a push that arrives while the app is backgrounded or
/// terminated.
///
/// Must be a top-level function with the vm:entry-point pragma: the
/// OS spawns a *fresh isolate* to run it, so nothing from the running
/// app is in scope — which is why Firebase has to be initialized
/// again here rather than reusing main()'s instance.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM background message: ${message.messageId} ${message.data}');
}

/// Wraps [FirebaseMessaging] so the rest of the app never imports it
/// directly — same reasoning as [SecureStorageService] wrapping the
/// storage plugin.
class PushService {
  PushService([FirebaseMessaging? messaging])
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  String? _token;

  final _foregroundMessages = StreamController<RemoteMessage>.broadcast();

  /// The current FCM registration token, or null if permission was
  /// denied or the platform hasn't issued one yet.
  String? get token => _token;

  /// Foreground pushes, re-broadcast so features can react without
  /// importing firebase_messaging themselves. Broadcast because more
  /// than one screen may want them.
  Stream<RemoteMessage> get onForegroundMessage => _foregroundMessages.stream;

  /// TODO: POST the token to the backend once an endpoint exists to
  /// register it against — see README, needs a backend change.
  void registerDeviceToken(String token) {
    debugPrint('TODO: send device token to backend: $token');
  }

  void dispose() => _foregroundMessages.close();

  /// Requests notification permission, resolves the FCM token, and
  /// subscribes to the three message streams.
  static bool get _isApplePlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Polls for the APNs token, which iOS delivers asynchronously some
  /// time after `requestPermission()` returns. Returns null if it
  /// never shows up within [attempts] * [interval].
  Future<String?> _awaitApnsToken({
    Duration interval = const Duration(milliseconds: 500),
    int attempts = 20,
  }) async {
    for (var i = 0; i < attempts; i++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) return apnsToken;
      await Future<void>.delayed(interval);
    }
    return null;
  }

  Future<void> start() async {
    final settings = await _messaging.requestPermission();
    debugPrint('FCM permission: ${settings.authorizationStatus.name}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // iOS suppresses the system banner while the app is foregrounded
    // unless we opt in. Android shows foreground notifications via its
    // own channel config, so this is a no-op there.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Subscribed before the token fetch so a token that only lands
    // later still reaches us.
    _messaging.onTokenRefresh.listen((token) {
      _token = token;
      // TODO: POST the token to the backend once there's an endpoint
      // to register it against — see README, needs a backend change.
      if (kDebugMode) debugPrint('FCM token refreshed: $token');
    });

    // On Apple platforms the APNs token arrives asynchronously after
    // registration, and getToken() throws outright if it isn't there
    // yet. Waiting for it is the difference between a token and an
    // `apns-token-not-set` error on a cold start.
    if (_isApplePlatform && await _awaitApnsToken() == null) {
      debugPrint(
        'APNs token never arrived — push is unavailable on this device. '
        'Expected on a simulator; on a real device check the Push '
        'Notifications capability and network reachability.',
      );
      return;
    }

    try {
      _token = await _messaging.getToken();
      // Only in debug: the token identifies this specific install,
      // and it's needed to send a test push from the Firebase console.
      if (kDebugMode) debugPrint('FCM token: $_token');
      if (_token != null) registerDeviceToken(_token!);
    } catch (e) {
      debugPrint('FCM token unavailable: $e');
    }

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
          'FCM foreground message: ${message.messageId} ${message.data}');
      if (!_foregroundMessages.isClosed) _foregroundMessages.add(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      //deep-link to Order Details once that screen exists.
      debugPrint('FCM notification tapped: ${message.data}');
    });
  }
}

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService();
  ref.onDispose(service.dispose);
  return service;
});
