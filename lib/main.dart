import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/login_screen.dart';
import 'services/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 로거 초기화
  await LoggerService.instance.initialize();
  await LoggerService.instance.info('Application starting...');
  final logPath = LoggerService.instance.getLogFilePath();
  if (logPath != null) {
    await LoggerService.instance.info('Log file location: $logPath');
  }
  
  // 윈도우 매니저 초기화
  await windowManager.ensureInitialized();
  await LoggerService.instance.debug('Window manager initialized');
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await LoggerService.instance.info('Window shown and focused');
  });
  
  await LoggerService.instance.info('Running Flutter app');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

