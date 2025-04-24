import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:radar/resources/pallete.dart';
import 'dart:convert';

/// Диалог детального отчета с навигацией по датам
/// 
/// Особенности:
/// - Динамическая загрузка данных через HTTP API
/// - Поддержка горизонтального и вертикального скроллинга
/// - Визуальная индикация статусов и ошибок
/// - Навигация между отчетами через стрелки
/// - Адаптивные размеры диалога
class ReportDetailsDialog extends StatefulWidget {
  final DateTime currentDate;
  final DateFormat formatter;
  final List<DateTime> allDates;

  const ReportDetailsDialog({
    super.key,
    required this.currentDate,
    required this.formatter,
    required this.allDates,
  });

  @override
  _ReportDetailsDialogState createState() => _ReportDetailsDialogState();
}

class _ReportDetailsDialogState extends State<ReportDetailsDialog> {
  late DateTime _currentDate;
  Map<String, dynamic> _reportData = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentDate = widget.currentDate;
    _loadReportData(); // Инициализация данных при создании
  }

  /// Загрузка данных отчета для текущей даты
  /// 
  /// Особенности:
  /// - Форматирование даты в URL-совместимый вид
  /// - Обработка HTTP-ответов и ошибок
  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_currentDate);
      final response = await http.get(
        Uri.parse('http://192.168.1.1:8080/daily-reports/$formattedDate'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _reportData = data;
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

  /// Навигация между датами отчетов
  /// 
  /// Логика:
  /// - Определяет текущий индекс даты
  /// - Предотвращает выход за границы списка
  /// - Обновляет данные при смене даты
  void _navigateDate(int direction) async {
    final index = widget.allDates.indexOf(_currentDate);
    if (index == -1) return;

    final newIndex = index + direction;
    if (newIndex >= 0 && newIndex < widget.allDates.length) {
      setState(() => _currentDate = widget.allDates[newIndex]);
      await _loadReportData();
    }
  }

  /// Построение основного контента диалога
  /// 
  /// Варианты отображения:
  /// 1. Индикатор загрузки
  /// 2. Экран ошибки с повторной загрузкой
  /// 3. Таблица с данными отчета
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Pallete.mainOrange),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage,
            style: const TextStyle(
              color: Pallete.cherryDark,
              fontSize: 16,
              fontFamily: 'Cuprum'
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.mainOrange,
            ),
            onPressed: _loadReportData,
            child: const Text(
              'Повторить',
              style: TextStyle(color: Pallete.textPageColorSecond),
            ),
          )
        ],
      );
    }

    if (_reportData.isEmpty || !_reportData.containsKey('nodes')) {
      return const Center(
        child: Text(
          'Нет данных для отображения',
          style: TextStyle(
            color: Pallete.textPageColorSecond,
            fontSize: 16,
            fontFamily: 'Cuprum'
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 12,
            horizontalMargin: 10,
            headingTextStyle: const TextStyle(
              fontFamily: 'CuprumBold',
              fontSize: 14,
              color: Pallete.textPageColorSecond,
            ),
            columns: const [
              DataColumn(
                label: SizedBox(width: 150, child: Text('Компонент')),
              ),
              DataColumn(
                label: SizedBox(width: 120, child: Text('Статус')),
              ), 
              DataColumn(
                label: SizedBox(width: 80, child: Text('Ошибки')),
              ), 
              DataColumn(
                label: SizedBox(width: 80, child: Text('Сигналы')),
              ),
            ],
            rows: (_reportData['nodes'] as List)
                .map<List<DataRow>>((node) => [
                      _buildNodeRow(node),
                      ...(node['subnodes'] as List).map<DataRow>(
                        (subnode) => _buildSubnodeRow(subnode),
                      ),
                    ])
                .expand((i) => i)
                .toList(),
          ),
        ),
      ),
    );
  }

  /// Построение строки основного узла
  /// 
  /// Особенности:
  /// - Фоновая подсветка строки
  /// - Форматирование названия узла
  /// - Отображение статуса и счетчиков
  DataRow _buildNodeRow(Map<String, dynamic> node) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color>(
        (states) => Pallete.backColor.withOpacity(0.1)),
      cells: [
        DataCell(SizedBox(
          width: 150,
          child: Text(
            node['node_name'].toString(),
            style: const TextStyle(
              fontFamily: 'CuprumBold',
              fontSize: 14,
            ),
          ),
        )),
        DataCell(SizedBox(
          width: 120,
          child: _buildStatusIndicator(node['node_status'].toString()),
        )),
        DataCell(SizedBox(
          width: 80,
          child: _buildErrorCount(node['total_errors'] as int),
        )),
        DataCell(SizedBox(
          width: 80,
          child: _buildWarningCount(node['total_warnings'] as int),
        )),
      ],
    );
  }

  /// Построение строки подузла
  /// 
  /// Особенности:
  /// - Отступ для визуальной иерархии
  /// - Упрощенный стиль текста
  DataRow _buildSubnodeRow(Map<String, dynamic> subnode) {
    return DataRow(
      cells: [
        DataCell(SizedBox(
          width: 150,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              subnode['subnode_name'].toString(),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        )),
        DataCell(SizedBox(
          width: 120,
          child: _buildStatusIndicator(subnode['subnode_status'].toString()),
        )),
        DataCell(SizedBox(
          width: 80,
          child: _buildErrorCount(subnode['errors'] as int),
        )),
        DataCell(SizedBox(
          width: 80,
          child: _buildWarningCount(subnode['warnings'] as int),
        )),
      ],
    );
  }

  /// Виджет индикатора статуса
  /// 
  /// Логика цветов:
  /// - Красный для критических статусов
  /// - Оранжевый для предупреждений
  /// - Зеленый для нормальных состояний
  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'критично':
        color = Pallete.cherryDark;
        break;
      case 'осторожно':
        color = Pallete.mainOrange;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontFamily: 'Cuprum',
          fontSize: 14,
        ),
      ),
    );
  }

  /// Виджет счетчика ошибок
  /// 
  /// Особенности:
  /// - Цветовая индикация наличия ошибок
  /// - Иконка Material Design
  Widget _buildErrorCount(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          color: count > 0 ? Pallete.cherryDark : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: TextStyle(
            color: count > 0 ? Pallete.cherryDark : Colors.grey,
            fontFamily: 'Cuprum',
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Виджет счетчика предупреждений
  /// 
  /// Особенности:
  /// - Цветовая индикация наличия предупреждений
  /// - Иконка Material Design
  Widget _buildWarningCount(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: count > 0 ? Pallete.mainOrange : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: TextStyle(
            color: count > 0 ? Pallete.mainOrange : Colors.grey,
            fontFamily: 'Cuprum',
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.allDates.indexOf(_currentDate);
    final hasPrevious = index > 0;
    final hasNext = index < widget.allDates.length - 1;

    return Dialog(
      backgroundColor: Pallete.backColor,
      insetPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    Text(
                      'ОТЧЕТ СУ ОТ ${widget.formatter.format(_currentDate)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontFamily: 'CuprumBold',
                        color: Pallete.textPageColorSecond,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: Pallete.textPageColorSecond.withOpacity(0.5),
                      thickness: 1.5,
                    ),
                  ],
                ),
              ),
              _buildContent(),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      iconSize: 32,
                      icon: Icon(
                        Icons.chevron_left,
                        color: hasPrevious ? Pallete.mainOrange : Colors.grey,
                      ),
                      onPressed: hasPrevious ? () => _navigateDate(-1) : null,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 8),
                        backgroundColor: Pallete.mainOrange.withOpacity(0.1),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'ЗАКРЫТЬ',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'CuprumBold',
                          color: Pallete.cherryDark,
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 32,
                      icon: Icon(
                        Icons.chevron_right,
                        color: hasNext ? Pallete.mainOrange : Colors.grey,
                      ),
                      onPressed: hasNext ? () => _navigateDate(1) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}