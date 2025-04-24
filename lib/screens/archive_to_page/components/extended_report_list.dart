import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:radar/resources/pallete.dart';
import 'dart:convert';

/// Виджет расширенного отчета с выбором периода и экспортом в CSV
/// 
/// Особенности:
/// - Диапазонный выбор дат через [SfDateRangePicker]
/// - Автоматическая генерация CSV-файлов
/// - Обработка разрешений на запись файлов
/// - Визуальная индикация состояний (загрузка/ошибка)
/// - Адаптивный дизайн с анимацией размеров
class ExtendedReportList extends StatefulWidget {
  const ExtendedReportList({super.key});

  @override
  _ExtendedReportListState createState() => _ExtendedReportListState();
}

class _ExtendedReportListState extends State<ExtendedReportList> {
  /// Форматировщик дат для отображения в интерфейсе
  final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');
  
  /// Форматировщик дат для API-запросов
  final DateFormat _apiDateFormatter = DateFormat('yyyy-MM-dd');
  
  /// Начальная дата периода
  DateTime? _startDate;
  
  /// Конечная дата периода
  DateTime? _endDate;
  
  /// Флаг состояния загрузки данных
  bool _isLoading = false;

  /// Основной метод экспорта данных
  /// 
  /// Этапы:
  /// 1. Валидация выбранной даты
  /// 2. Формирование API-запроса
  /// 3. Обработка ответа сервера
  /// 4. Сохранение CSV через [_saveToCsv]
  Future<void> _downloadAndSaveReports() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите дату начала периода'),
          backgroundColor: Pallete.cherryDark,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Формируем параметры запроса
      final params = {
        'start_date': _apiDateFormatter.format(_startDate!),
        if (_endDate != null) 'end_date': _apiDateFormatter.format(_endDate!),
      };
      final uri = Uri.parse('http://192.168.1.1:8080/maintenance-reports')
          .replace(queryParameters: params);

      // Выполняем HTTP-запрос
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        await _saveToCsv(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Файл успешно сохранен'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Pallete.cherryDark,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Сохранение данных в CSV-файл
  /// 
  /// Особенности:
  /// - Конвертация JSON в CSV через [ListToCsvConverter]
  /// - Запрос разрешений на запись
  /// - Сохранение в папку Downloads/RadarReports
  Future<void> _saveToCsv(List<dynamic> reports) async {
    // Формируем CSV-данные
    final csvData = List<List<dynamic>>.from([
      ['Дата', 'Узел', 'Комментарий'], // Заголовки
      ...reports.map((report) => [
            report['date'],
            report['node'],
            report['comment'],
          ]),
    ]);

    // Конвертируем в CSV-строку
    final csvString = const ListToCsvConverter().convert(csvData);

    // Запрашиваем разрешение на запись
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Разрешение на запись не предоставлено');
    }

    // Сохраняем файл
    final directory = await getDownloadsDirectory();
    final fileName = 'reports_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${directory?.path}/$fileName');
    await file.writeAsString(csvString);
  }

  /// Отображение диалога выбора дат
  /// 
  /// Использует [SfDateRangePicker] для выбора периода
  void _openDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите диапазон дат',
            style: TextStyle(fontFamily: 'CuprumBold')),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.5,
          child: SfDateRangePicker(
            selectionMode: DateRangePickerSelectionMode.range,
            initialSelectedRange: PickerDateRange(_startDate, _endDate),
            onSelectionChanged: (args) {
              if (args.value is PickerDateRange) {
                setState(() {
                  _startDate = args.value.startDate;
                  _endDate = args.value.endDate;
                });
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Сбросить',
                style: TextStyle(color: Pallete.mainOrange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Применить',
                style: TextStyle(color: Pallete.mainOrange)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Pallete.backColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Кнопка выбора даты
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.textPageColorSecond,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : () => _openDatePicker(context),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Pallete.mainOrange)
                    : const Text('Выберите дату',
                        style: TextStyle(
                          color: Pallete.mainOrange,
                          fontSize: 20,
                          fontFamily: 'CuprumBold')),
              ),
              // Отображение выбранного периода
              if (_startDate != null || _endDate != null) ...[
                const SizedBox(height: 20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Выбрано: ',
                          style: TextStyle(
                            color: Pallete.textPageColorSecond,
                            fontSize: 16,
                            fontFamily: 'Cuprum'),
                        ),
                        Flexible(
                          child: Text(
                            '${_startDate != null ? _dateFormatter.format(_startDate!) : ''} '
                            '- ${_endDate != null ? _dateFormatter.format(_endDate!) : ''}',
                            style: TextStyle(
                              color: Pallete.cherryDark,
                              fontSize: 16,
                              fontFamily: 'CuprumBold'),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 15),
                    // Кнопка экспорта
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Pallete.mainOrange,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _downloadAndSaveReports,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Pallete.textPageColorSecond)
                          : const Text('Скачать отчет',
                              style: TextStyle(
                                color: Pallete.textPageColorSecond,
                                fontSize: 20,
                                fontFamily: 'CuprumBold')),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}