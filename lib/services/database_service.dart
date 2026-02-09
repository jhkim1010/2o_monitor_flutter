import 'dart:async';
import 'package:postgres/postgres.dart';
import '../models/reading.dart';
import 'logger_service.dart';

class DatabaseConnectionResult {
  final bool success;
  final String? errorMessage;
  final String? errorDetails;

  DatabaseConnectionResult({
    required this.success,
    this.errorMessage,
    this.errorDetails,
  });
}

class DatabaseService {
  Connection? _connection;
  int? _terminalNumber;

  Future<DatabaseConnectionResult> connect(String host, String databaseName, int terminalNumber) async {
    try {
      await LoggerService.instance.info('Attempting to connect to database: $host, database: $databaseName, terminal: $terminalNumber');
      _terminalNumber = terminalNumber;
      
      _connection = await Connection.open(
        Endpoint(
          host: host,
          port: 5432,
          database: databaseName,
          username: 'postgres',
          password: 'wkrdjqwnd',
        ),
        settings: ConnectionSettings(
          sslMode: SslMode.disable,
        ),
      );

      await LoggerService.instance.info('Database connection successful');
      return DatabaseConnectionResult(success: true);
    } catch (e, stackTrace) {
      final errorString = e.toString();
      final stackString = stackTrace.toString();
      
      // 에러 타입별로 상세 메시지 생성
      String errorMessage = 'Connection failed';
      String errorDetails = errorString;
      
      if (errorString.contains('SocketException') || errorString.contains('Failed host lookup')) {
        errorMessage = 'Network error: Cannot reach the server';
        errorDetails = 'Unable to connect to $host:5432. Please check:\n'
            '- The IP address is correct\n'
            '- The PostgreSQL server is running\n'
            '- Firewall settings allow connections\n'
            '- Network connectivity';
      } else if (errorString.contains('authentication') || errorString.contains('password')) {
        errorMessage = 'Authentication failed';
        errorDetails = 'Invalid username or password. Please verify:\n'
            '- Username: postgres\n'
            '- Password: wkrdjqwnd\n'
            '- User has access to the database';
      } else if (errorString.contains('database') && errorString.contains('does not exist')) {
        errorMessage = 'Database not found';
        errorDetails = 'Database "$databaseName" does not exist on the server.\n'
            'Please check the database name and try again.';
      } else if (errorString.contains('timeout') || errorString.contains('timed out')) {
        errorMessage = 'Connection timeout';
        errorDetails = 'The connection attempt timed out.\n'
            'Please check:\n'
            '- Network connectivity\n'
            '- Server is accessible\n'
            '- Firewall settings';
      } else if (errorString.contains('refused')) {
        errorMessage = 'Connection refused';
        errorDetails = 'The server refused the connection.\n'
            'Please check:\n'
            '- PostgreSQL is running on port 5432\n'
            '- Server accepts remote connections\n'
            '- Firewall allows port 5432';
      } else {
        errorMessage = 'Connection error';
        errorDetails = 'Error: $errorString';
      }
      
      await LoggerService.instance.error('Database connection error: $errorMessage', e, stackTrace);
      await LoggerService.instance.error('Error details: $errorDetails', e, stackTrace);
      
      return DatabaseConnectionResult(
        success: false,
        errorMessage: errorMessage,
        errorDetails: errorDetails,
      );
    }
  }

  Future<void> disconnect() async {
    await LoggerService.instance.info('Disconnecting from database');
    await _connection?.close();
    _connection = null;
    await LoggerService.instance.info('Database disconnected');
  }

  Future<List<Reading>> getReadings() async {
    if (_connection == null || _terminalNumber == null) {
      // 연결이 끊어진 경우에만 로그 출력
      await LoggerService.instance.warning('getReadings called but connection or terminal number is null');
      return [];
    }

    try {
      // 로그 출력 제거 - 변동이 있을 때만 monitor_screen에서 로그 출력
      final results = await _connection!.execute(
        'SELECT rcant, rcodigo, rexp, rprecio, rtotal, id_reading '
        'FROM public.readings '
        'WHERE nterminal = \$1 '
        'ORDER BY id_reading',
        parameters: [_terminalNumber],
      );

      final readings = <Reading>[];
      
      for (final row in results) {
        try {
          // 안전한 데이터 파싱 - null 체크 및 타입 변환
          if (row.length < 6) {
            await LoggerService.instance.warning('Row has insufficient columns: ${row.length}, expected 6');
            continue;
          }
          
          final reading = Reading.fromMap({
            'rcant': row[0] is int ? row[0] : (row[0] != null ? int.tryParse(row[0].toString()) ?? 0 : 0),
            'rcodigo': row[1]?.toString() ?? '',
            'rexp': row[2]?.toString() ?? '',
            'rprecio': row[3] != null 
                ? (row[3] is num ? (row[3] as num).toDouble() : double.tryParse(row[3].toString()) ?? 0.0)
                : 0.0,
            'rtotal': row[4] != null 
                ? (row[4] is num ? (row[4] as num).toDouble() : double.tryParse(row[4].toString()))
                : null,
            'id_reading': row[5] is int ? row[5] : (row[5] != null ? int.tryParse(row[5].toString()) ?? 0 : 0),
          });
          readings.add(reading);
        } catch (e, stackTrace) {
          // 개별 행 파싱 오류 로그
          await LoggerService.instance.error('Error parsing reading row', e, stackTrace);
          await LoggerService.instance.error('Row data: $row', e, stackTrace);
          // 오류가 발생한 행은 건너뛰고 계속 진행
          continue;
        }
      }
      
      // 로그 출력 제거 - 변동이 있을 때만 monitor_screen에서 로그 출력
      return readings;
    } catch (e, stackTrace) {
      // 에러가 발생한 경우에만 로그 출력
      await LoggerService.instance.error('Error fetching readings', e, stackTrace);
      await LoggerService.instance.error('Error details: $e', e, stackTrace);
      return [];
    }
  }

  bool get isConnected {
    try {
      final connected = _connection != null;
      if (!connected) {
        LoggerService.instance.warning('Database connection check: not connected');
      }
      return connected;
    } catch (e) {
      LoggerService.instance.error('Error checking connection status', e);
      return false;
    }
  }
}

