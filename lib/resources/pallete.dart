import 'package:flutter/material.dart';

/// Цветовая палитра приложения
/// 
/// Содержит кастомные цвета и часто используемые оттенки в виде статических констант.
/// Все цвета объявлены как `const` для оптимизации производительности и повторного использования.
class Pallete {
  // Базовые цвета
  static const Color blackColor = Colors.black;
  static const Color whiteColor = Colors.white;
  
  // Цвета текста
  static const Color textPageColor = Color(0XFF8a898c);      // Серо-графитовый для основного текста
  static const Color textPageColorSecond = Color(0xFF402f1e); // Коричневатый для заголовков/акцентов
  
  // Фоновые цвета
  static const Color backColor = Color(0xFFccbd9e);           // Бежевый фоновый цвет

  // Основные акцентные цвета приложения
  static const Color mainOrange = Color(0xFFF8981D);          // Ярко-оранжевый для кнопок и акцентов
  static const Color mainBlue = Color(0xFF18213a);            // Темно-синий для панели меню
  static const Color cherryDark = Color(0xFF790604);          // Темно-вишневый для предупреждений и выделения текста
}