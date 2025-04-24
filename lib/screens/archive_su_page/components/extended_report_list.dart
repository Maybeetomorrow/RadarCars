import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:http/http.dart' as http;
import 'package:radar/resources/pallete.dart';

/// Виджет расширенного отчета с выбором узлов и периодов
/// 
/// Особенности:
/// - Экспорт данных в CSV-файл
/// - Массовое управление чекбоксами
/// - Диапазонный выбор дат через [SfDateRangePicker]
/// - Обработка разрешений на запись файлов
/// - Интеграция с файловой системой
class ExtendedReportList extends StatefulWidget {
  const ExtendedReportList({super.key});

  @override
  _ExtendedReportListState createState() => _ExtendedReportListState();
}

class _ExtendedReportListState extends State<ExtendedReportList> {
  /// Форматировщик дат для отображения
  final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');
  
  /// Выбранные даты периода
  DateTime? _startDate;
  DateTime? _endDate;
  
  /// Состояние выбранных чекбоксов
  List<bool> _checkedItems = [];
  bool _selectAll = false;
  
  /// Данные узлов с сервера
  List<dynamic> _nodes = [];
  
  /// Состояния загрузки и ошибок
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNodes(); // Загрузка данных при инициализации
    FlutterDownloader.initialize(debug: true); // Инициализация загрузчика
  }

  /// Загрузка списка узлов с сервера
  /// 
  /// Особенности:
  /// - Обработка HTTP-ответов
  /// - Инициализация состояний чекбоксов
  Future<void> _fetchNodes() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.1:8080/nodes'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _nodes = data;
          _checkedItems = List.filled(data.length, false);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Ошибка загрузки: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка подключения: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Массовое переключение чекбоксов
  void _toggleAll(bool value) {
    setState(() {
      _selectAll = value;
      _checkedItems = List.filled(_nodes.length, value);
    });
  }

  /// Отображение диалога выбора дат
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

  /// Подтверждение выбора и экспорт данных
  /// 
  /// Логика:
  /// - Валидация выбора дат и узлов
  /// - Запрос данных с сервера
  /// - Конвертация в CSV и сохранение
  Future<void> _confirmSelection() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите диапазон дат'),
          backgroundColor: Pallete.cherryDark,
        ),
      );
      return;
    }

    final selectedNodes = _nodes
        .where((node) => _checkedItems[_nodes.indexOf(node)])
        .map((node) => node['name'] as String)
        .toList();

    if (selectedNodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы один узел'),
          backgroundColor: Pallete.cherryDark,
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.1:8080/period-reports').replace(
          queryParameters: {
            'node_names': selectedNodes.join(','),
            'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
            'end_date': DateFormat('yyyy-MM-dd').format(_endDate!),
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final csvContent = _convertJsonToCsv(data);
        await _saveCsvFile(csvContent);
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
    }
  }

  /// Конвертация JSON-данных в CSV-формат
  /// 
  /// Структура CSV:
  /// Узел,Начало периода,Конец периода,Дата,Статус узла,Подсистема,Ошибки,Предупреждения,Статус подсистемы
  String _convertJsonToCsv(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('Узел,Начало периода,Конец периода,Дата,Статус узла,Подсистема,Ошибки,Предупреждения,Статус подсистемы');
    
    for (final nodeReport in data['report']) {
      final nodeName = nodeReport['node_name'];
      final periodStart = nodeReport['period_start'];
      final periodEnd = nodeReport['period_end'];
      
      for (final day in nodeReport['days']) {
        final date = day['date'];
        final nodeStatus = day['node_status'];
        
        for (final subnode in day['subnodes']) {
          buffer.writeln([
            nodeName,
            periodStart,
            periodEnd,
            date,
            nodeStatus,
            subnode['subnode_name'],
            subnode['errors'],
            subnode['warnings'],
            subnode['status'],
          ].map((e) => '"${e.toString().replaceAll('"', '""')}"').join(','));
        }
      }
    }
    
    return buffer.toString();
  }

  /// Сохранение CSV-файла в папку загрузок
  /// 
  /// Этапы:
  /// 1. Запрос разрешений
  /// 2. Создание директории RadarReports
  /// 3. Генерация имени файла
  /// 4. Запись данных
  /// 5. Запуск загрузки через [FlutterDownloader]
  Future<void> _saveCsvFile(String content) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Разрешение на запись не предоставлено');
    }

    final dir = await getDownloadsDirectory();
    if (dir == null) {
      throw Exception('Не удалось получить доступ к папке загрузок');
    }

    final saveDir = Directory('${dir.path}/RadarReports');
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    final fileName = 'Отчет_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.csv';
    final file = File('${saveDir.path}/$fileName');
    await file.writeAsString(content);

    await FlutterDownloader.enqueue(
      url: file.path,
      savedDir: saveDir.path,
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: true,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Файл сохранен в: ${saveDir.path}/$fileName'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Построение основного контента
  /// 
  /// Варианты отображения:
  /// 1. Индикатор загрузки
  /// 2. Сообщение об ошибке
  /// 3. Список узлов с чекбоксами
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Pallete.mainOrange));
    }
    
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(
            color: Pallete.cherryDark,
            fontSize: 16,
            fontFamily: 'Cuprum'
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.mainOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _toggleAll(!_selectAll),
            child: Text(
              _selectAll ? 'Снять все' : 'Выбрать все',
              style: const TextStyle(
                color: Pallete.cherryDark,
                fontFamily: 'CuprumBold',
              ),
            ),
          ),
        ),
        SizedBox(
          height: 310,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _nodes.length,
            itemBuilder: (context, index) {
              final node = _nodes[index];
              return CheckboxListTile(
                activeColor: Pallete.cherryDark,
                title: Text(node['name'] ?? 'Без названия'),
                subtitle: node['description'] != null 
                    ? Text(node['description'],
                        style: const TextStyle(fontSize: 12))
                    : null,
                value: _checkedItems[index],
                onChanged: (value) {
                  setState(() {
                    _checkedItems[index] = value!;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallete.textPageColorSecond,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _openDatePicker(context),
                    child: const Text('Выберите дату',
                        style: TextStyle(
                          color: Pallete.mainOrange,
                          fontSize: 20,
                          fontFamily: 'CuprumBold')),
                  ),
                ),
                if (_startDate != null || _endDate != null)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Выбрано: ',
                              style: TextStyle(
                                color: Pallete.textPageColorSecond,
                                fontSize: 16,
                                fontFamily: 'Cuprum'),
                            ),
                            Text(
                              '${_startDate != null ? _dateFormatter.format(_startDate!) : ''} '
                              '- ${_endDate != null ? _dateFormatter.format(_endDate!) : ''}',
                              style: TextStyle(
                                color: Pallete.cherryDark,
                                fontSize: 16,
                                fontFamily: 'CuprumBold'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey),
                    ],
                  ),
                _buildContent(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.mainOrange,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _confirmSelection,
                child: const Text('Подтвердить',
                    style: TextStyle(
                      color: Pallete.textPageColorSecond,
                      fontSize: 20,
                      fontFamily: 'CuprumBold')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}