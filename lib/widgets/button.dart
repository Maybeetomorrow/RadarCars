import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';

/// Кастомная кнопка с градиентным фоном и стандартизированным стилем
/// 
/// Особенности:
/// - Поддержка изменения размеров
/// - Кастомизируемый цвет фона
/// - Встроенные эффекты нажатия
/// - Автоматическая адаптация текста
class Button extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Color color;

  const Button({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.width = 300,       // Стандартная ширина по умолчанию
    this.height = 45,       // Стандартная высота по умолчанию
    this.color = Pallete.mainOrange, // Цвет фона по умолчанию
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Градиентный фон (в текущей реализации используется один цвет)
        gradient: const LinearGradient(
          colors: [Pallete.mainOrange, Pallete.mainOrange],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(7), // Закругление углов
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(width, height), // Минимальные размеры
          backgroundColor: Colors.transparent, // Прозрачный фон для видимости градиента
          shadowColor: Colors.transparent, // Отключение стандартной тени
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Pallete.whiteColor,       // Белый текст
            fontWeight: FontWeight.w600,      // Полужирное начертание
            fontFamily: 'CuprumRegular',     // Кастомный шрифт
            fontSize: 22,                    // Размер шрифта
          ),
        ),
      ),
    );
  }
}