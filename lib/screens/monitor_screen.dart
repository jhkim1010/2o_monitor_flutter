import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/reading.dart';
import '../services/database_service.dart';
import '../services/logger_service.dart';

class MonitorScreen extends StatefulWidget {
  final DatabaseService databaseService;
  final String host;
  final String databaseName;
  final int terminalNumber;

  const MonitorScreen({
    super.key,
    required this.databaseService,
    required this.host,
    required this.databaseName,
    required this.terminalNumber,
  });

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  List<Reading> _readings = [];
  Timer? _pollTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    LoggerService.instance.info('MonitorScreen initialized for terminal ${widget.terminalNumber}');
    _loadInitialData();
    _startPolling();
  }

  Future<void> _loadInitialData() async {
    try {
      await LoggerService.instance.info('Loading initial readings data');
      final initialReadings = await widget.databaseService.getReadings();
      
      if (mounted) {
        if (initialReadings.isNotEmpty) {
          await LoggerService.instance.info('Found ${initialReadings.length} initial readings');
          setState(() {
            _readings = initialReadings;
          });
        } else {
          await LoggerService.instance.info('No initial readings found');
        }
      }
    } catch (e, stackTrace) {
      await LoggerService.instance.error('Error loading initial data', e, stackTrace);
    }
  }

  void _startPolling() {
    LoggerService.instance.info('Starting polling timer (100ms interval)');
    _pollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (!widget.databaseService.isConnected) {
        await LoggerService.instance.error('Database connection lost, stopping polling');
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database connection lost')),
          );
        }
        return;
      }

      final newReadings = await widget.databaseService.getReadings();
      
      if (mounted) {
        // 데이터가 실제로 변동되었는지 확인
        bool hasChanged = false;
        
        // 개수 변경 확인
        if (_readings.length != newReadings.length) {
          hasChanged = true;
          await LoggerService.instance.debug('Readings count changed: ${_readings.length} -> ${newReadings.length} items');
        } else {
          // 내용 변경 확인 (id_reading 비교)
          for (int i = 0; i < _readings.length; i++) {
            if (i >= newReadings.length || _readings[i].idReading != newReadings[i].idReading) {
              hasChanged = true;
              await LoggerService.instance.debug('Readings content changed');
              break;
            }
          }
        }
        
        // 변동이 있을 때만 화면 업데이트
        if (hasChanged) {
          setState(() {
            _readings = newReadings;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    LoggerService.instance.info('MonitorScreen disposing, stopping polling');
    _pollTimer?.cancel();
    super.dispose();
  }

  Reading? get _latestReading {
    if (_readings.isEmpty) return null;
    // id_reading이 0인 항목 찾기
    final readingWithZeroId = _readings.where((r) => r.idReading == 0).firstOrNull;
    return readingWithZeroId;
  }

  double get _totalAmount {
    return _readings.fold(0.0, (sum, reading) => sum + (reading.rtotal ?? 0.0));
  }

  // 스페인어 방식 숫자 포맷팅 (천 단위 구분자: 점)
  String _formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'es');
    return formatter.format(number);
  }

  String _formatDecimal(double number) {
    // 소수점 이하 무시하고 정수만 표시
    final intValue = number.floor();
    final formatter = NumberFormat('#,###', 'es');
    return formatter.format(intValue);
  }

  // 숫자를 스페인어로 읽기 (소수점 이하 제외)
  String _numberToSpanishWords(double number) {
    if (number == 0) return 'cero';
    
    final intPart = number.floor();
    return _intToSpanish(intPart);
  }

  String _intToSpanish(int number) {
    if (number == 0) return 'cero';
    if (number < 0) return 'menos ${_intToSpanish(-number)}';
    
    if (number < 20) {
      const units = [
        '', 'uno', 'dos', 'tres', 'cuatro', 'cinco', 'seis', 'siete', 'ocho', 'nueve',
        'diez', 'once', 'doce', 'trece', 'catorce', 'quince', 'dieciséis', 'diecisiete', 'dieciocho', 'diecinueve'
      ];
      return units[number];
    }
    
    if (number < 30) {
      return 'veinti${_intToSpanish(number - 20)}';
    }
    
    if (number < 100) {
      const tens = ['', '', 'veinte', 'treinta', 'cuarenta', 'cincuenta', 'sesenta', 'setenta', 'ochenta', 'noventa'];
      final ten = number ~/ 10;
      final unit = number % 10;
      if (unit == 0) {
        return tens[ten];
      }
      return '${tens[ten]} y ${_intToSpanish(unit)}';
    }
    
    if (number < 200) {
      final remainder = number % 100;
      if (remainder == 0) return 'cien';
      return 'ciento ${_intToSpanish(remainder)}';
    }
    
    if (number < 1000) {
      final hundred = number ~/ 100;
      final remainder = number % 100;
      String hundredStr = '';
      if (hundred == 1) {
        hundredStr = 'ciento';
      } else if (hundred == 5) {
        hundredStr = 'quinientos';
      } else if (hundred == 7) {
        hundredStr = 'setecientos';
      } else if (hundred == 9) {
        hundredStr = 'novecientos';
      } else {
        hundredStr = '${_intToSpanish(hundred)}cientos';
      }
      
      if (remainder == 0) return hundredStr;
      return '$hundredStr ${_intToSpanish(remainder)}';
    }
    
    if (number < 1000000) {
      final thousand = number ~/ 1000;
      final remainder = number % 1000;
      String thousandStr = '';
      if (thousand == 1) {
        thousandStr = 'mil';
      } else {
        thousandStr = '${_intToSpanish(thousand)} mil';
      }
      
      if (remainder == 0) return thousandStr;
      if (remainder < 100) return '$thousandStr ${_intToSpanish(remainder)}';
      return '$thousandStr ${_intToSpanish(remainder)}';
    }
    
    if (number < 1000000000) {
      // 백만 단위 처리
      final million = number ~/ 1000000;
      final remainder = number % 1000000;
      String millionStr = '';
      if (million == 1) {
        millionStr = 'un millón';
      } else {
        millionStr = '${_intToSpanish(million)} millones';
      }
      
      if (remainder == 0) return millionStr;
      if (remainder < 1000) {
        return '$millionStr ${_intToSpanish(remainder)}';
      }
      return '$millionStr ${_intToSpanish(remainder)}';
    }
    
    // 999,999,999까지 처리 (십억 단위)
    final billion = number ~/ 1000000000;
    final remainder = number % 1000000000;
    String billionStr = '';
    if (billion == 1) {
      billionStr = 'mil millones';
    } else {
      billionStr = '${_intToSpanish(billion)} mil millones';
    }
    
    if (remainder == 0) return billionStr;
    return '$billionStr ${_intToSpanish(remainder)}';
  }

  // WhatsApp 메시지 전송 URL 생성
  String _getWhatsAppUrl() {
    const phoneNumber = '541130123113'; // + 기호 제거
    const message = 'Consulta de instalacion de sistema ACE III';
    final encodedMessage = Uri.encodeComponent(message);
    return 'https://wa.me/$phoneNumber?text=$encodedMessage';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terminal ${widget.terminalNumber} - ${widget.host} - ${widget.databaseName}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await LoggerService.instance.info('Manual refresh triggered');
              setState(() {
                _isLoading = true;
              });
              final readings = await widget.databaseService.getReadings();
              await LoggerService.instance.info('Manual refresh completed: ${readings.length} readings');
              setState(() {
                _readings = readings;
                _isLoading = false;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // 왼쪽 절반: 전체 목록
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _readings.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : _buildLeftPanel(),
            ),
          ),
          // 오른쪽 절반: 최신 항목 + 합계
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // 오른쪽 위 (4배 크기)
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade50,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: _buildLatestReadingPanel(),
                  ),
                ),
                // 오른쪽 아래 (2배 크기)
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.blue.shade50,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: _buildTotalPanel(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Column(
      children: [
        // 헤더
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'Qty',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  'Code',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Description',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Price',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Total',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        // 리스트
        Expanded(
          child: ListView.builder(
            itemCount: _readings.length,
            itemBuilder: (context, index) {
              final reading = _readings[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        _formatNumber(reading.rcant),
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Text(
                        reading.rcodigo,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        reading.rexp,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatDecimal(reading.rprecio),
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatDecimal(reading.rtotal ?? 0.0),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLatestReadingPanel() {
    final latest = _latestReading;
    
    if (latest == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      );
    }

    // 왼쪽 패널의 기본 폰트 크기(14)의 3배
    const double baseFontSize = 14;
    const double largeFontSize = baseFontSize * 3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Qty와 Code를 1줄로 표시
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildDetailRow('Qty:', _formatNumber(latest.rcant), largeFontSize),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildDetailRow('Code:', latest.rcodigo, largeFontSize),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailRow('Description:', latest.rexp, largeFontSize),
        const SizedBox(height: 16),
        _buildDetailRow('Price:', _formatDecimal(latest.rprecio), largeFontSize),
        const SizedBox(height: 16),
        _buildDetailRow('Total:', _formatDecimal(latest.rtotal ?? 0.0), largeFontSize),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, double fontSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontSize: fontSize / 3, color: Colors.grey.shade700),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Importe Final과 숫자를 1줄로 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Importe Final',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _formatDecimal(_totalAmount),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 스페인어로 읽는 부분과 QR 코드를 나란히 배치
        // Importe Final이 0일 때는 스페인어 텍스트 표시하지 않음
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 스페인어 텍스트 영역 (폭 넓힘)
              if (_totalAmount > 0)
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Center(
                        child: Text(
                          _numberToSpanishWords(_totalAmount),
                          style: const TextStyle(
                            fontSize: 32,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                )
              else
                const Expanded(
                  flex: 4,
                  child: SizedBox(),
                ),
              const SizedBox(width: 12),
              // QR 코드 영역 (폭 줄임)
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'by ACE III',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Flexible(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final qrSize = constraints.maxWidth < constraints.maxHeight
                                ? constraints.maxWidth * 0.9
                                : (constraints.maxHeight - 30) * 0.9;
                            return QrImageView(
                              data: _getWhatsAppUrl(),
                              version: QrVersions.auto,
                              size: qrSize.clamp(80.0, 150.0),
                              backgroundColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

