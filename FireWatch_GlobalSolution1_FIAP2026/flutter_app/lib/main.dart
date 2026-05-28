import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/fire_provider.dart';
import 'screens/home_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/report_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Aviso: Arquivo .env não encontrado. Usando mocks.");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FireProvider()..fetchFoci()),
      ],
      child: const FireWatchApp(),
    ),
  );
}

class FireWatchApp extends StatelessWidget {
  const FireWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FireWatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1923),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B35),
          secondary: Color(0xFFFFAA00),
          surface: Color(0xFF1A2535),
          background: Color(0xFF0F1923),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final List<Widget> _screens = const [
    HomeScreen(),
    AlertsScreen(),
    DashboardScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FireProvider>(context);
    
    return Scaffold(
      body: _screens[provider.currentTabIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0A1218),
        selectedIndex: provider.currentTabIndex,
        onDestinationSelected: (index) => provider.setTabIndex(index),
        indicatorColor: const Color(0xFFFF6B35).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: Color(0xFFFF6B35)),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications, color: Color(0xFFFF6B35)),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFFFF6B35)),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_outlined),
            selectedIcon: Icon(Icons.report, color: Color(0xFFFF6B35)),
            label: 'Reportar',
          ),
        ],
      ),
    );
  }
}
