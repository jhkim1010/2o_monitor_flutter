import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/database_service.dart';
import '../services/logger_service.dart';
import 'monitor_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _databaseController = TextEditingController();
  final _terminalController = TextEditingController();
  final _preferencesService = PreferencesService();
  final _databaseService = DatabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    LoggerService.instance.info('LoginScreen initialized');
    _loadSavedInfo();
  }

  Future<void> _loadSavedInfo() async {
    await LoggerService.instance.debug('Loading saved connection info');
    final savedInfo = await _preferencesService.getConnectionInfo();
    if (savedInfo != null) {
      await LoggerService.instance.info('Found saved connection info: ${savedInfo['host']}, database: ${savedInfo['database']}, terminal: ${savedInfo['terminal']}');
      setState(() {
        _hostController.text = savedInfo['host'] as String;
        _databaseController.text = savedInfo['database'] as String;
        _terminalController.text = savedInfo['terminal'].toString();
      });
    } else {
      await LoggerService.instance.debug('No saved connection info found, setting default terminal to 1');
      setState(() {
        _terminalController.text = '1';
      });
    }
  }

  Future<void> _handleLogin() async {
    await LoggerService.instance.info('Login attempt started');
    
    if (!_formKey.currentState!.validate()) {
      await LoggerService.instance.warning('Login form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final host = _hostController.text.trim();
    final databaseName = _databaseController.text.trim();
    final terminalNumber = int.tryParse(_terminalController.text.trim());

    if (databaseName.isEmpty) {
      await LoggerService.instance.warning('Database name is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter database name')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (terminalNumber == null) {
      await LoggerService.instance.warning('Invalid terminal number: ${_terminalController.text.trim()}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid terminal number')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 연결 정보 저장
    await LoggerService.instance.info('Saving connection info: $host, database: $databaseName, terminal: $terminalNumber');
    await _preferencesService.saveConnectionInfo(host, databaseName, terminalNumber);

    // 데이터베이스 연결 시도
    final result = await _databaseService.connect(host, databaseName, terminalNumber);

    if (!mounted) return;

    if (result.success) {
      await LoggerService.instance.info('Login successful, navigating to MonitorScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MonitorScreen(
            databaseService: _databaseService,
            host: host,
            databaseName: databaseName,
            terminalNumber: terminalNumber,
          ),
        ),
      );
    } else {
      await LoggerService.instance.error('Login failed: ${result.errorMessage}');
      
      // 상세한 에러 메시지를 다이얼로그로 표시
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.errorMessage ?? 'Connection Failed',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result.errorDetails != null) ...[
                    const Text(
                      'Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.errorDetails!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Connection Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Host: $host', style: const TextStyle(fontSize: 12)),
                  Text('Database: $databaseName', style: const TextStyle(fontSize: 12)),
                  Text('Port: 5432', style: const TextStyle(fontSize: 12)),
                  Text('Terminal: $terminalNumber', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
      // 간단한 스낵바도 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to connect to database'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _databaseController.dispose();
    _terminalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Barcode Monitor',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: 'PostgreSQL IP Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.computer),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter IP address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _databaseController,
                  decoration: const InputDecoration(
                    labelText: 'Database Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.storage),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter database name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _terminalController,
                  decoration: const InputDecoration(
                    labelText: 'Terminal Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter terminal number';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'User: postgres (fixed)',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Password: wkrdjqwnd (fixed)',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                FutureBuilder<String?>(
                  future: Future.value(LoggerService.instance.getLogFilePath()),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Log file: ${snapshot.data}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Connect',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

