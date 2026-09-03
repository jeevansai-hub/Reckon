import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'providers/navigation_provider.dart';
import 'ui/screens/benchmark_screen.dart';
import 'ui/screens/navigation_screen.dart';
import 'ui/screens/telemetry_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce dark system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ReckonApp());
}

class ReckonApp extends StatelessWidget {
  const ReckonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'Reckon - GPS-Denied Positioning',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accentCyan,
            surface: AppColors.surface,
          ),
          fontFamily: 'Roboto',
        ),
        home: const MainShellScreen(),
      ),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    NavigationScreen(),
    TelemetryScreen(),
    BenchmarkScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.accentCyan,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.navigation_outlined),
              activeIcon: Icon(Icons.navigation),
              label: 'Navigate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors_outlined),
              activeIcon: Icon(Icons.sensors),
              label: 'Telemetry',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Benchmark',
            ),
          ],
        ),
      ),
    );
  }
}
