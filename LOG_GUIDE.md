# Log File Guide

## Automatic Log File Creation

The log file is **automatically created** when you run the Flutter app. No additional steps are required.

## Log File Location

On Windows, log files are created in:
```
C:\Users\{YourUsername}\Documents\flutter_monitor\logs\app_YYYYMMDD_HHMMSS.log
```

Example:
```
C:\Users\marcoskim\Documents\flutter_monitor\logs\app_20240115_143025.log
```

## How to Run with Logging

### Method 1: Normal Run (Recommended)
Simply run the app as usual:
```powershell
C:\src\flutter\bin\flutter.bat run -d windows
```

The log file will be automatically created when the app starts.

### Method 2: View Log File Location
The log file path is displayed:
1. In the console output when the app starts
2. On the login screen (at the bottom, in small gray text)

### Method 3: Monitor Log File in Real-Time

Open a new PowerShell window and run:
```powershell
# Navigate to logs directory
cd $env:USERPROFILE\Documents\flutter_monitor\logs

# Watch the latest log file in real-time
Get-Content -Path (Get-ChildItem -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName -Wait -Tail 50
```

Or use a simpler command:
```powershell
# Find and watch the latest log file
$logFile = Get-ChildItem -Path "$env:USERPROFILE\Documents\flutter_monitor\logs" -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Get-Content -Path $logFile.FullName -Wait -Tail 50
```

## Log File Format

Each log entry includes:
- **Timestamp**: `[2024-01-15 14:30:25.123]`
- **Log Level**: `[INFO]`, `[DEBUG]`, `[WARN]`, `[ERROR]`
- **File Location**: `[filename.dart:line:column]`
- **Message**: The actual log message

Example:
```
[2024-01-15 14:30:25.123] [INFO] [main.dart:10:5] Application starting...
[2024-01-15 14:30:25.456] [INFO] [main.dart:14:5] Log file location: C:\Users\marcoskim\Documents\flutter_monitor\logs\app_20240115_143025.log
[2024-01-15 14:30:25.789] [DEBUG] [database_service.dart:12:5] Attempting to connect to database: 192.168.1.100, terminal: 1
```

## Quick Access to Log Directory

Create a shortcut or use this PowerShell command to open the log directory:
```powershell
explorer "$env:USERPROFILE\Documents\flutter_monitor\logs"
```

## Tips

1. **Each app run creates a new log file** with a unique timestamp
2. **Log files are never overwritten** - old logs are preserved
3. **Log file path is shown on the login screen** for easy reference
4. **All errors include stack traces** with line numbers for easy debugging

