import 'package:flutter/material.dart';
import 'screens/animated_logo_page/animated_logo_screen.dart';

/// Точка входа в приложение
/// 
/// Запускает приложение через константный экземпляр [MyApp]
/// для оптимизации производительности
void main() => runApp(const MyApp());

/// Основной виджет приложения
/// 
/// Особенности:
/// - Отключает отладочный баннер
/// - Использует [AnimatedLogoScreen] как стартовый экран
/// - Реализован через [StatelessWidget]
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Скрываем баннер отладки
      home: const AnimatedLogoScreen(),  // Начальный экран приложения
    );
  }
}