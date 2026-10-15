import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'app_provider.dart';
import 'screens/circles_screen.dart';
import 'screens/curricula_screen.dart';
import 'screens/plans_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/students_screen.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const HalaqatApp(),
    ),
  );
}

class HalaqatApp extends StatelessWidget {
  const HalaqatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حلقات القربات',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF047857),
          primary: const Color(0xFF047857),
          surface: Colors.white,
        ),
      ),
      home: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (!provider.isInitialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF047857)),
              ),
            );
          }
          if (provider.startupError != null) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'تعذر تحميل بيانات التطبيق من الخادم:\n${provider.startupError}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
          return provider.isAuthenticated
              ? const MainHomeScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  final List<Widget> screens = const [
    CirclesScreen(),
    CurriculaScreen(),
    StudyPlansScreen(),
    AttendanceScreen(),
    StudentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final operationError = provider.takeOperationError();
    if (operationError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(operationError),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }

    return Scaffold(
      body: screens[provider.currentTab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: provider.currentTab,
        onDestinationSelected: provider.setTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: Color(0xFF047857)),
            label: 'الحلقات',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFF047857)),
            label: 'المناهج',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: Color(0xFF047857)),
            label: 'الخطط',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check, color: Color(0xFF047857)),
            label: 'التحضير',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school, color: Color(0xFF047857)),
            label: 'الطلاب',
          ),
        ],
      ),
    );
  }
}
