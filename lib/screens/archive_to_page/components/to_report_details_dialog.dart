import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:radar/resources/pallete.dart';
import 'dart:convert';

/// Диалог деталей отчета ТО с навигацией по датам
/// 
/// Особенности:
/// - Агрегация данных по техническому обслуживанию
/// - Поддержка горизонтальной навигации между датами
/// - Визуальная группировка работ по компонентам
/// - Обработка пустых состояний и ошибок
class ToReportDetailsDialog extends StatefulWidget {
  final DateTime currentDate;
  final DateFormat formatter;
  final List<DateTime> allDates;

  const ToReportDetailsDialog({
    super.key,
    required this.currentDate,
    required this.formatter,
    required this.allDates,
  });

  @override
  _ToReportDetailsDialogState createState() => _ToReportDetailsDialogState();
}

class _ToReportDetailsDialogState extends State<ToReportDetailsDialog> {
  late DateTime _currentDate;
  Map<String, String> _works = {}; // Карта компонент-работы
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentDate = widget.currentDate;
    _loadWorks(); // Инициализация данных при создании
  }

  /// Загрузка данных ТО через HTTP API
  /// 
  /// Особенности:
  /// - Агрегация данных по компонентам
  /// - Обработка дублирующихся записей
  /// - Валидация формата ответа
  Future<void> _loadWorks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_currentDate);
      final response = await http.get(
        Uri.parse('http://192.168.1.1:8080/maintenance-reports?start_date=$formattedDate'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dataList = json.decode(response.body);
        
        if (dataList is! List) {
          throw FormatException('Invalid data format');
        }
        
        Map<String, String> tempWorks = {};
        for (var item in dataList) {
          final node = item['node'] as String?;
          final comment = item['comment'] as String?;
          
          if (node != null && comment != null) {
            // Агрегация работ для одинаковых компонентов
            if (tempWorks.containsKey(node)) {
              tempWorks[node] = '${tempWorks[node]}, $comment';
            } else {
              tempWorks[node] = comment;
            }
          }
        }
        
        setState(() {
          _works = tempWorks;
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
        _errorMessage = 'Ошибка обработки данных: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Навигация между датами отчетов
  /// 
  /// Логика:
  /// - Определяет текущий индекс даты
  /// - Обновляет данные при смене даты
  /// - Предотвращает выход за границы списка
  void _navigateDate(int direction) async {
    final index = widget.allDates.indexOf(_currentDate);
    if (index == -1) return;

    final newIndex = index + direction;
    if (newIndex >= 0 && newIndex < widget.allDates.length) {
      setState(() {
        _currentDate = widget.allDates[newIndex];
      });
      await _loadWorks();
    }
  }

  /// Построение основного контента диалога
  /// 
  /// Варианты отображения:
  /// 1. Индикатор загрузки
  /// 2. Экран ошибки с повторной загрузкой
  /// 3. Список работ с группировкой
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
            onPressed: _loadWorks,
            child: const Text('Повторить',
              style: TextStyle(color: Pallete.textPageColorSecond)),
          )
        ],
      );
    }

    if (_works.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных о работах',
          style: TextStyle(
            color: Pallete.textPageColorSecond,
            fontSize: 16,
            fontFamily: 'Cuprum'
          ),
        ),
      );
    }

    return ListView(
      children: _works.entries.map((entry) => _buildWorkCard(
        component: entry.key,
        works: entry.value,
      )).toList(),
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
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок диалога
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    Text(
                      'ОТЧЕТ ТО ОТ ${widget.formatter.format(_currentDate)}',
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
              // Основной контент
              Expanded(child: _buildContent()),
              // Навигационные элементы
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

  /// Виджет карточки работ для компонента
  /// 
  /// Особенности:
  /// - Группировка по компонентам
  /// - Отображение списка работ с маркерами
  /// - Кастомизация цветов из палитры
  Widget _buildWorkCard({required String component, required String works}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: Pallete.mainOrange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название компонента
            Text(
              component,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'CuprumBold',
                color: Pallete.textPageColorSecond,
              ),
            ),
            const SizedBox(height: 6),
            // Список работ
            ...works.split(', ').map((work) => Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(color: Pallete.mainOrange)),
                      Expanded(
                        child: Text(
                          work.trim(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Cuprum',
                            color: Pallete.textPageColorSecond,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
          ],
        ),
      ),
    );
  }
}