import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';
import 'date_filter.dart';

/// Заголовок приложения с меню и фильтрацией
/// 
/// Особенности:
/// - Кастомная типографика с иерархией заголовков
/// - Интеграция с системой цветов [Pallete]
/// - Поддержка внешнего виджета фильтра
/// - Адаптивные отступы и позиционирование
class AppHeader extends StatelessWidget {
  /// Коллбэк для открытия меню
  final VoidCallback onMenuPressed;
  
  /// Внешний виджет фильтра (например, [DateFilter])
  final Widget filterWidget;

  const AppHeader({
    super.key,
    required this.onMenuPressed,
    required this.filterWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Элементы по краям
        children: [
          // Левая область с меню и заголовками
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50), // Отступ для верхнего поля
              IconButton(
                icon: const Icon(Icons.menu, 
                  color: Pallete.textPageColorSecond, // Цвет иконки меню
                  size: 30),
                onPressed: onMenuPressed, // Действие при нажатии
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Основной заголовок
                  Text('Архив',
                    style: TextStyle(
                      color: Pallete.textPageColorSecond,
                      fontSize: 48,
                      fontFamily: 'CuprumBold')), // Кастомный шрифт
                  SizedBox(height: 4),
                  // Подзаголовок
                  Text('Состояния узлов',
                    style: TextStyle(
                      color: Pallete.textPageColorSecond,
                      fontSize: 24,
                      fontFamily: 'CuprumBold')),
                ],
              ),
            ],
          ),
          // Правая область с фильтром
          filterWidget, // Внедряемый виджет фильтрации
        ],
      ),
    );
  }
}