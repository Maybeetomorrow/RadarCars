import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:radar/resources/pallete.dart';

/// Виджет выбора диапазона дат с визуальной индикацией
/// 
/// Особенности:
/// - Материальный дизайн с эффектом нажатия
/// - Адаптивное отображение выбранного диапазона
/// - Интеграция с системой цветов [Pallete]
/// - Поддержка частичного выбора дат (начальная/конечная)
class ReportDateRange extends StatelessWidget {
  /// Начальная дата диапазона
  final DateTime? startDate;
  
  /// Конечная дата диапазона
  final DateTime? endDate;
  
  /// Коллбэк при нажатии на виджет
  final VoidCallback onTap;
  
  /// Форматировщик дат для унификации отображения
  final DateFormat formatter;

  const ReportDateRange({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onTap,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
      child: Material(
        elevation: 3, // Тень для эффекта возвышения
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap, // Ripple-эффект при нажатии
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Pallete.mainOrange, // Цвет фона из палитры
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Отображение диапазона дат с подстановкой форматированных значений
                Text(
                  '${startDate != null ? formatter.format(startDate!) : 'Начальная дата'} '
                  '- ${endDate != null ? formatter.format(endDate!) : 'Конечная дата'}',
                  style: const TextStyle(
                    color: Pallete.textPageColorSecond,
                    fontSize: 20,
                    fontFamily: 'CuprumBold',
                  ),
                ),
                const Icon(Icons.calendar_today, 
                  color: Pallete.textPageColorSecond), // Иконка календаря
              ],
            ),
          ),
        ),
      ),
    );
  }
}