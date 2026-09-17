import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/locale/locale_provider.dart';
import 'core/notifications/push_service.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Registered before runApp so a push that wakes the app from a
  // terminated state still has a handler to land in.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: ZaytoonRiderApp()));
}

class ZaytoonRiderApp extends ConsumerStatefulWidget {
  const ZaytoonRiderApp({super.key});

  @override
  ConsumerState<ZaytoonRiderApp> createState() => _ZaytoonRiderAppState();
}

class _ZaytoonRiderAppState extends ConsumerState<ZaytoonRiderApp> {
  @override
  void initState() {
    super.initState();
    // Fire-and-forget: no part of the UI blocks on push being ready.
    ref.read(pushServiceProvider).start();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      routerConfig: router,
    );
  }
}
