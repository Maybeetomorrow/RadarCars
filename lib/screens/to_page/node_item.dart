import 'package:flutter/material.dart';

/// Модель данных узла для технического обслуживания
/// 
/// Особенности:
/// - Инкапсулирует состояние выбора (чекбокс)
/// - Содержит контроллер для текстового поля комментариев
/// - Автоматическая инициализация параметров
class NodeItem {
  /// Название компонента/узла оборудования
  final String name;
  
  /// Флаг выбора элемента (чекбокс)
  bool isSelected;
  
  /// Контроллер для ввода комментариев
  final TextEditingController commentController;

  NodeItem({required this.name})
      : isSelected = false, // Начальное состояние - не выбран
        commentController = TextEditingController(); // Автоматическое создание контроллера
}