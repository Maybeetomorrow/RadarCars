import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:radar/resources/pallete.dart';
import 'package:radar/screens/archive_su_page/components/report_date_item.dart';
import 'package:radar/screens/archive_su_page/components/report_details_dialog.dart';

/// Виджет списка дат отчетов с поддержкой детализации
/// 
/// Особенности:
/// - Адаптивная высота на основе размеров экрана
/// - Кастомная анимация прокрутки
/// - Интеграция с диалогом деталей отчета
/// - Тень и скругление контейнера
class ReportsList extends StatelessWidget {
  /// Список дат для отображения
  final List<DateTime> dates;
  
  /// Форматировщик дат для унификации отображения
  final DateFormat formatter;

  const ReportsList({
    super.key,
    required this.dates,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Адаптивная высота (40% от экрана)
      height: MediaQuery.of(context).size.height * 0.4,
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
        child: ClipRRect(
          // Скругление углов для внутреннего контента
          borderRadius: BorderRadius.circular(15),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(), // Эффект упругой прокрутки
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            itemCount: dates.length,
            itemBuilder: (context, index) => ReportDateItem(
              date: dates[index],
              formatter: formatter,
              onTap: () => showDialog(
                context: context,
                builder: (context) => ReportDetailsDialog(
                  currentDate: dates[index],
                  formatter: formatter,
                  allDates: dates, // Передача текущего списка дат
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}