// scan_button.dart
import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';

/// Кастомная круглая кнопка сканирования с поддержкой текста и теневых эффектов
/// 
/// Особенности:
/// - Адаптивный размер и масштабирование текста
/// - Динамическая тень, соответствующая основному цвету
/// - Поддержка как иконок, так и текстового содержимого
/// - Гибкая кастомизация стилей
class ScanButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final Color color;
  final String text;
  final TextStyle? textStyle;

  const ScanButton({
    super.key,
    required this.onPressed,
    this.size = 20.0,           // Стандартный размер в 20 логических пикселей
    this.color = Pallete.mainOrange, // Основной цвет из дизайн-системы
    this.text = "",             // Текстовая метка (пустая строка по умолчанию)
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle, // Круглая форма кнопки
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3), // Полупрозрачная тень
              blurRadius: 8.0,               // Радиус размытия
              spreadRadius: 2.0,             // Радиус распространения
            )
          ],
        ),
        // Условный рендеринг текста при необходимости
        child: text.isNotEmpty
            ? Center(
                child: Text(
                  text,
                  style: textStyle ??
                      TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.6, // Адаптивный размер текста
                        fontWeight: FontWeight.bold,
                      ),
                ),
              )
            : null,
      ),
    );
  }
}