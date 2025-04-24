import 'package:flutter/animation.dart';

/// Класс управления анимациями для экрана с анимированным логотипом
///
/// Содержит:
/// - Контроллеры анимаций
/// - Tween-параметры для разных типов анимаций
/// - Методы инициализации и утилизации ресурсов
class AnimatedLogoAnimations {
  /// Требуется для работы анимаций
  final TickerProvider vsync;

  /// Основной контроллер анимаций
  late AnimationController mainController;
  
  /// Контроллер анимации исчезновения
  late AnimationController fadeOutController;

  /// Анимация масштабирования логотипа
  late Animation<double> scaleAnimation;
  
  /// Анимация вращения логотипа
  late Animation<double> rotationAnimation;
  
  /// Анимация появления логотипа
  late Animation<double> opacityAnimation;
  
  /// Анимация появления линии под логотипом
  late Animation<double> lineAnimation;
  
  /// Анимация появления текста
  late Animation<double> textAnimation;
  
  /// Анимация исчезновения всего элемента
  late Animation<double> fadeOutAnimation;

  /// Инициализирует все анимации
  AnimatedLogoAnimations({required this.vsync}) {
    _initializeMainAnimations();
    _initializeFadeOutAnimations();
  }

  /// Инициализация основных анимаций
  void _initializeMainAnimations() {
    mainController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: vsync,
    );

    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeInOutCubicEmphasized),
      ),
    );

    rotationAnimation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutSine),
      ),
    );

    lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeInOut),
      ),
    );

    textAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.75, 1.0, curve: Curves.linear),
      ),
    );
  }

  /// Инициализация анимации исчезновения
  void _initializeFadeOutAnimations() {
    fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );

    fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: fadeOutController,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Освобождение ресурсов анимаций
  void dispose() {
    mainController.dispose();
    fadeOutController.dispose();
  }
}