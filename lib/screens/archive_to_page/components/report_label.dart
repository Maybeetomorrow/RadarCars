import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';

/// Виджет заголовка раздела отчетов
/// 
/// Особенности:
/// - Кастомный шрифт [CuprumBold] для выделения
/// - Фиксированное позиционирование слева
/// - Интеграция с системой цветов [Pallete]
/// - Адаптивные отступы для разных экранов
class ReportLabel extends StatelessWidget {
  const ReportLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 40.0, top: 10.0), // Отступы для позиционирования
      child: Align(
        alignment: Alignment.centerLeft, // Выравнивание по левому краю
        child: Text('Отчёт',
          style: TextStyle(
            color: Pallete.textPageColorSecond, // Цвет из глобальной палитры
            fontSize: 48, // Крупный шрифт для заголовка
            fontFamily: 'CuprumBold', // Кастомный шрифт
          ),
        ),
      ),
    );
  }
}