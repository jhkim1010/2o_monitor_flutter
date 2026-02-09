import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

class PreferencesService {
  static const String _keyHost = 'db_host';
  static const String _keyDatabase = 'db_name';
  static const String _keyTerminal = 'terminal_number';

  Future<void> saveConnectionInfo(String host, String databaseName, int terminalNumber) async {
    await LoggerService.instance.debug('Saving connection info to preferences');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHost, host);
    await prefs.setString(_keyDatabase, databaseName);
    await prefs.setInt(_keyTerminal, terminalNumber);
    await LoggerService.instance.info('Connection info saved: $host, database: $databaseName, terminal: $terminalNumber');
  }

  Future<Map<String, dynamic>?> getConnectionInfo() async {
    await LoggerService.instance.debug('Loading connection info from preferences');
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString(_keyHost);
    final database = prefs.getString(_keyDatabase);
    final terminal = prefs.getInt(_keyTerminal);

    if (host != null && database != null && terminal != null) {
      await LoggerService.instance.debug('Found saved connection info');
      return {
        'host': host,
        'database': database,
        'terminal': terminal,
      };
    }
    await LoggerService.instance.debug('No saved connection info found');
    return null;
  }
}

