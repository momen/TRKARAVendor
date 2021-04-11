import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trkar_vendor/screens/splash_screen.dart';
import 'package:trkar_vendor/utils/Provider/provider.dart';
import 'package:trkar_vendor/utils/local/AppLocalizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<Provider_control>(
      create: (_) => Provider_control(),
      child: MyApp(),
    ),
  );

  // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  // OneSignal.shared.init(
  //     "b2f7f966-d8cc-11e4-bed1-df8f05be55ba",
  //     iOSSettings: {
  //       OSiOSSettings.autoPrompt: false,
  //       OSiOSSettings.inAppLaunchUrl: false
  //     }
  // );
  // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
  // await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
}

class MyApp extends StatefulWidget {
  static void setlocal(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setlocal(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  void setlocal(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<Provider_control>(context);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      localeResolutionCallback: (devicelocale, supportedLocales) {
        for (var locale in supportedLocales) {
          if (locale.languageCode == devicelocale.languageCode &&
              locale.countryCode == devicelocale.countryCode) {
            return devicelocale;
          }
        }
        return supportedLocales.first;
      },
      supportedLocales: [
        Locale("ar", ""),
        Locale("en", ""),
      ],
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
        primaryColor: themeColor.getColor(),
        fontFamily: 'Cairo',
        snackBarTheme: SnackBarThemeData(
          backgroundColor: themeColor.getColor(),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
