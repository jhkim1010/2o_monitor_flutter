import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LoggerService {
  static LoggerService? _instance;
  File? _logFile;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  final DateFormat _fileDateFormat = DateFormat('yyyyMMdd_HHmmss');

  LoggerService._();

  static LoggerService get instance {
    _instance ??= LoggerService._();
    return _instance!;
  }

  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final timestamp = _fileDateFormat.format(DateTime.now());
      _logFile = File('${logDir.path}/app_$timestamp.log');
      
      await _writeToFile('=== Application Started ===', LogLevel.info);
      await _writeToFile('Log file: ${_logFile!.path}', LogLevel.info);
    } catch (e) {
      print('Failed to initialize logger: $e');
    }
  }

  String _getLogLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  String _getCallerInfo() {
    try {
      final stackTrace = StackTrace.current;
      final frames = stackTrace.toString().split('\n');
      
      // 스택 트레이스에서 호출자 정보 찾기
      // _writeToFile -> debug/info/warning/error -> 실제 호출자
      // 따라서 4번째 프레임이 실제 호출 위치
      for (int i = 3; i < frames.length && i < 10; i++) {
        final frame = frames[i].trim();
        // 예: #3      _MonitorScreenState._startPolling (package:flutter_monitor/screens/monitor_screen.dart:34:5)
        // 또는: #3      DatabaseService.connect (package:flutter_monitor/services/database_service.dart:23:5)
        final match = RegExp(r'\(([^:]+):(\d+):(\d+)\)').firstMatch(frame);
        if (match != null) {
          final filePath = match.group(1)!;
          final lineNumber = match.group(2)!;
          final columnNumber = match.group(3)!;
          
          // 파일 경로에서 파일명만 추출
          String fileName = filePath;
          if (fileName.contains('/')) {
            fileName = fileName.split('/').last;
          } else if (fileName.contains('\\')) {
            fileName = fileName.split('\\').last;
          }
          
          return '$fileName:$lineNumber:$columnNumber';
        }
      }
    } catch (e) {
      // 스택 트레이스 파싱 실패 시 무시
    }
    return 'unknown:0:0';
  }

  Future<void> _writeToFile(String message, LogLevel level) async {
    if (_logFile == null) {
      print('Logger not initialized: $message');
      return;
    }

    try {
      final timestamp = _dateFormat.format(DateTime.now());
      final levelStr = _getLogLevelString(level);
      final callerInfo = _getCallerInfo();
      final logEntry = '[$timestamp] [$levelStr] [$callerInfo] $message\n';
      
      await _logFile!.writeAsString(logEntry, mode: FileMode.append);
      
      // 콘솔에도 출력 (디버그 모드에서 유용)
      print(logEntry.trim());
    } catch (e) {
      print('Failed to write to log file: $e');
    }
  }

  Future<void> debug(String message) async {
    await _writeToFile(message, LogLevel.debug);
  }

  Future<void> info(String message) async {
    await _writeToFile(message, LogLevel.info);
  }

  Future<void> warning(String message) async {
    await _writeToFile(message, LogLevel.warning);
  }

  Future<void> error(String message, [Object? error, StackTrace? stackTrace]) async {
    await _writeToFile(message, LogLevel.error);
    if (error != null) {
      await _writeToFile('Error: $error', LogLevel.error);
    }
    if (stackTrace != null) {
      await _writeToFile('StackTrace: $stackTrace', LogLevel.error);
    }
  }

  String? getLogFilePath() {
    return _logFile?.path;
  }
}

