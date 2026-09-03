import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'providers/navigation_provider.dart';

void main() {
  runApp(const ReckonApp());
}

class ReckonApp extends StatelessWidget {
  const ReckonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: MaterialApp(
        title: 'Reckon',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
