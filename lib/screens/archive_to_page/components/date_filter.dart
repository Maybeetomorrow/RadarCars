import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:radar/resources/pallete.dart';

/// Виджет фильтрации по датам с диапазонным выбором
/// 
/// Особенности:
/// - Интеграция с [SfDateRangePicker] для выбора периода
/// - Визуальная индикация активного фильтра
/// - Поддержка сброса и применения диапазона
/// - Адаптивные размеры диалогового окна
class DateFilter extends StatefulWidget {
  /// Текущая начальная дата фильтра
  final DateTime? selectedStartDate;
  
  /// Текущая конечная дата фильтра
  final DateTime? selectedEndDate;
  
  /// Коллбэк при изменении начальной даты
  final ValueChanged<DateTime?> onStartDateChanged;
  
  /// Коллбэк при изменении конечной даты
  final ValueChanged<DateTime?> onEndDateChanged;

  const DateFilter({
    super.key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  _DateFilterState createState() => _DateFilterState();
}

class _DateFilterState extends State<DateFilter> {
  /// Форматировщик дат для отображения в интерфейсе
  final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');

  /// Отображение диалога выбора дат
  /// 
  /// Особенности:
  /// - Начальное отображение текущей даты
  /// - Автоматическое применение текущего диапазона
  /// - Обработка сброса через кнопку "Сбросить"
  void _showDatePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите диапазон дат', 
          style: TextStyle(fontFamily: 'CuprumBold')),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% ширины экрана
          height: MediaQuery.of(context).size.height * 0.5, // 50% высоты экрана
          child: SfDateRangePicker(
            initialDisplayDate: DateTime.now(), // Начальная дата
            initialSelectedRange: PickerDateRange(
              widget.selectedStartDate, 
              widget.selectedEndDate
            ),
            selectionMode: DateRangePickerSelectionMode.range, // Режим диапазона
            onSelectionChanged: (args) {
              if (args.value is PickerDateRange) {
                // Обновление родительского состояния
                widget.onStartDateChanged(args.value.startDate);
                widget.onEndDateChanged(args.value.endDate);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Полный сброс выбранных дат
              widget.onStartDateChanged(null);
              widget.onEndDateChanged(null);
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
    return Padding(
      padding: const EdgeInsets.only(top: 110.0), // Отступ для верхнего расположения
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.filter_list,
              // Цвет зависит от активности фильтра
              color: widget.selectedStartDate != null || widget.selectedEndDate != null 
                ? Pallete.mainOrange 
                : Pallete.textPageColorSecond, 
              size: 30),
            onPressed: _showDatePickerDialog, // Открытие диалога выбора дат
          ),
          const SizedBox(width: 8),
          const Text('Фильтр',
            style: TextStyle(
              color: Pallete.textPageColorSecond,
              fontSize: 24,
              fontFamily: 'CuprumBold')), // Заголовок фильтра
        ],
      ),
    );
  }
}