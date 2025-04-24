import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';
import 'date_filter.dart';

/// Заголовок приложения с меню и фильтрацией
/// 
/// Особенности:
/// - Адаптивная верстка с отступами
/// - Кастомная типографика [CuprumBold]
/// - Интеграция с внешним виджетом фильтра
/// - Иерархия заголовков (48px + 24px)
/// - Визуальная связь с меню через иконку
class AppHeader extends StatelessWidget {
  /// Коллбэк для обработки нажатия на меню
  final VoidCallback onMenuPressed;
  
  /// Внедряемый виджет фильтра (например, [DateFilter])
  final Widget filterWidget;

  const AppHeader({
    super.key,
    required this.onMenuPressed,
    required this.filterWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0), // Базовые отступы контейнера
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Элементы по краям
        children: [
          // Левая секция с меню и заголовками
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50), // Вертикальный отступ для меню
              IconButton(
                icon: const Icon(Icons.menu, 
                  color: Pallete.textPageColorSecond, // Цвет иконки меню
                  size: 30),
                onPressed: onMenuPressed, // Действие при нажатии
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Основной заголовок архива
                  Text('Архив',
                    style: TextStyle(
                      color: Pallete.textPageColorSecond,
                      fontSize: 48,
                      fontFamily: 'CuprumBold')), // Крупный шрифт
                  SizedBox(height: 4), // Отступ между заголовками
                  // Подзаголовок раздела
                  Text('Технического обслуживания',
                    style: TextStyle(
                      color: Pallete.textPageColorSecond,
                      fontSize: 24,
                      fontFamily: 'CuprumBold')), // Мелкий шрифт
                ],
              ),
            ],
          ),
          // Правая секция с фильтром
          filterWidget, // Внедрение внешнего виджета фильтрации
        ],
      ),
    );
  }
}