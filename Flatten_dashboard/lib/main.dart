import 'package:flatten/helpers/services/localizations/app_localization_delegate.dart';
import 'package:flatten/helpers/services/localizations/language.dart';
import 'package:flatten/helpers/services/navigation_service.dart';
import 'package:flatten/helpers/services/storage/local_storage.dart';
import 'package:flatten/helpers/theme/app_notifier.dart';
import 'package:flatten/helpers/theme/app_style.dart';
import 'package:flatten/helpers/theme/theme_customizer.dart';
import 'package:flatten/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  await Supabase.initialize(
    url: 'https://necbzbnfgzlyvtyrulro.supabase.co',
    publishableKey: 'sb_publishable_aL7ifStDQyHmXgoOOlsscg_qGFlDjLY',
  );

  await LocalStorage.init();
  AppStyle.init();
  await ThemeCustomizer.init();

  runApp(
    ChangeNotifierProvider<AppNotifier>(
      create: (context) => AppNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (context, notifier, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeCustomizer.instance.theme,
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: "/dashboard",
          getPages: getPageRoute(),
          builder: (context, child) {
            NavigationService.registerContext(context);
            return Directionality(
              textDirection: AppTheme.textDirection,
              child: child ?? Container(),
            );
          },
          localizationsDelegates: [
            AppLocalizationsDelegate(context),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: Language.getLocales(),
        );
      },
    );
  }
}
