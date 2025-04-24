import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';

/// Кастомное расширяемое текстовое поле с анимированными переходами
/// 
/// Особенности:
/// - Автоматически увеличивает высоту при фокусировке
/// - Анимация границы и размеров
/// - Поддержка кастомного контроллера и обработчиков фокуса
/// - Адаптивный стиль текста и подсказки
class ExpandableTextbox extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onFocus;

  const ExpandableTextbox({
    super.key,
    required this.hintText,
    this.controller,
    this.onFocus,
  });

  @override
  State<ExpandableTextbox> createState() => _ExpandableTextboxState();
}

class _ExpandableTextboxState extends State<ExpandableTextbox> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    // Настройка слушателя состояния фокуса
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) widget.onFocus?.call(); // Колбэк при активации фокуса
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      constraints: BoxConstraints(
        minHeight: 40,          // Минимальная высота
        maxHeight: _isFocused ? 150 : 40, // Максимальная при фокусе
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isFocused 
              ? Pallete.mainOrange      // Активная граница
              : Pallete.textPageColorSecond, // Неактивная
          width: _isFocused ? 2 : 1,   // Толщина границы
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: _isFocused ? null : 1, // Неограниченные строки при фокусе
        style: TextStyle(
          color: Pallete.textPageColorSecond,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Pallete.textPageColorSecond.withOpacity(0.5),
            fontSize: 16,
          ),
          border: InputBorder.none,    // Скрываем стандартную границу
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}