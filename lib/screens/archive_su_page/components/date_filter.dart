import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:radar/resources/pallete.dart';

/// Виджет фильтрации по датам с использованием календаря
/// 
/// Особенности:
/// - Интеграция с [SfDateRangePicker] для выбора диапазонов
/// - Поддержка сброса и применения фильтров
/// - Визуальная индикация активного фильтра
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
  /// - Использует [SfDateRangePicker] для выбора диапазона
  /// - Автоматически применяет текущие даты из состояния
  /// - Обновляет родительский виджет при выборе
  void _showDatePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите диапазон дат', 
          style: TextStyle(fontFamily: 'CuprumBold')),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.5,
          child: SfDateRangePicker(
            initialDisplayDate: DateTime.now(),
            initialSelectedRange: PickerDateRange(
              widget.selectedStartDate, 
              widget.selectedEndDate
            ),
            selectionMode: DateRangePickerSelectionMode.range,
            onSelectionChanged: (args) {
              if (args.value is PickerDateRange) {
                // Обновляем родительский виджет при выборе диапазона
                widget.onStartDateChanged(args.value.startDate);
                widget.onEndDateChanged(args.value.endDate);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Сброс фильтрации при нажатии
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
      padding: const EdgeInsets.only(top: 110.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.filter_list,
              // Цвет иконки зависит от активности фильтра
              color: widget.selectedStartDate != null || widget.selectedEndDate != null 
                ? Pallete.mainOrange 
                : Pallete.textPageColorSecond, 
              size: 30),
            onPressed: _showDatePickerDialog,
          ),
          const SizedBox(width: 8),
          const Text('Фильтр',
            style: TextStyle(
              color: Pallete.textPageColorSecond,
              fontSize: 24,
              fontFamily: 'CuprumBold')),
        ],
      ),
    );
  }
}