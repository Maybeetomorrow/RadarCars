import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';

/// Анимированная кнопка сканирования с эффектом пульсации
/// 
/// Особенности:
/// - Плавное изменение радиуса и прозрачности внешнего круга
/// - Анимация нажатия с изменением цвета и тени
/// - Поддержка кастомного текста и стилей
/// - Состояние выбора (isSelected) с альтернативной визуализацией
class ScanAnimation extends StatefulWidget {
  final VoidCallback? onScanPressed;
  final String buttonText;
  final TextStyle? buttonTextStyle;
  final bool isSelected;

  const ScanAnimation({
    super.key,
    this.onScanPressed,
    required this.buttonText,
    this.buttonTextStyle,
    this.isSelected = false,
  });

  @override
  State<ScanAnimation> createState() => _ScanAnimationState();
}

class _ScanAnimationState extends State<ScanAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;  // Анимация изменения радиуса
  late Animation<double> _opacityAnimation; // Анимация прозрачности
  bool _isPressed = false; // Состояние нажатия кнопки

  @override
  void initState() {
    super.initState();
    // Настройка контроллера анимации с повторением
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Анимация радиуса от 50 до 60 с плавным переходом
    _radiusAnimation = Tween<double>(begin: 50, end: 60).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Анимация прозрачности с задержкой начала
    _opacityAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    widget.onScanPressed?.call(); // Вызов колбэка при нажатии
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Внешний пульсирующий круг
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: _radiusAnimation.value,
                    height: _radiusAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Pallete.mainOrange.withOpacity(0.6),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // Внутренний статический круг
                Container(
                  width: _radiusAnimation.value * 0.55,
                  height: _radiusAnimation.value * 0.60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Pallete.mainOrange,
                      width: 2.0,
                    ),
                  ),
                ),

                // Основная кнопка с динамическими эффектами
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  width: 20.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                    color: widget.isSelected 
                        ? Pallete.cherryDark // Активный режим
                        : (_isPressed 
                            ? Pallete.mainOrange.withOpacity(0.8) // Состояние нажатия
                            : Pallete.mainOrange), // Обычное состояние
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.isSelected 
                            ? Pallete.cherryDark.withOpacity(0.5)
                            : Pallete.mainOrange.withOpacity(
                                _isPressed ? 0.5 : 0.3),
                        blurRadius: _isPressed ? 12.0 : 8.0,
                        spreadRadius: _isPressed ? 4.0 : 2.0,
                      )
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        widget.buttonText,
                        style: widget.buttonTextStyle ??
                            TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}