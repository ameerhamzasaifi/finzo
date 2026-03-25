import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/finance_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool('onboarded') ?? false;

  runApp(FinzoApp(onboarded: onboarded));
}

class FinzoApp extends StatefulWidget {
  final bool onboarded;
  const FinzoApp({super.key, required this.onboarded});

  @override
  State<FinzoApp> createState() => _FinzoAppState();
}

class _FinzoAppState extends State<FinzoApp> {
  late bool _onboarded;

  @override
  void initState() {
    super.initState();
    _onboarded = widget.onboarded;
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    setState(() => _onboarded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboarded) {
      return MaterialApp(
        title: 'Finzo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: OnboardingScreen(onComplete: _completeOnboarding),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => FinanceProvider()..init(),
      child: MaterialApp(
        title: 'Finzo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
