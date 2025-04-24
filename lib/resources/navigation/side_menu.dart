import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';
import 'package:radar/screens/state_page/state_screen.dart';
import 'package:radar/screens/to_page/to_screen.dart';
import 'package:radar/screens/archive_su_page/archive_su_screen.dart';
import 'package:radar/screens/archive_to_page/archive_to_screen.dart';

/// Боковое меню приложения с навигацией между основными разделами
/// 
/// Особенности:
/// - Автоматическая подсветка активного раздела
/// - Анимация перехода между экранами
/// - Кастомизируемая цветовая схема из палитры
/// - Адаптивный заголовок с логотипом
class SideMenu extends StatefulWidget {
  final int selectedIndex;
  const SideMenu({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late int _selectedIndex = widget.selectedIndex;

  /// Список элементов меню с конфигурацией:
  /// - Иконка
  /// - Заголовок
  /// - Целевой экран (роут)
  final List<Map<String, dynamic>> _menuItems = [
    {
      "icon": Icons.key,
      "title": "Состояние",
      "route": const StatePage()
    },
    {
      "icon": Icons.settings,
      "title": "ТО",
      "route": const ToPage()
    },
    {
      "icon": Icons.archive_outlined,
      "title": "Архив СУ",
      "route": ArchiveSuPage()
    },
    {
      "icon": Icons.archive,
      "title": "Архив ТО",
      "route": const ArchiveToPage()
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Pallete.mainBlue,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Заголовок меню с логотипом
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Pallete.backColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Основной логотип приложения
                Image.asset(
                  'assets/images/mainLogo/logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const Text(
                  'Контроль транспорта 24/7',
                  style: TextStyle(
                    color: Pallete.textPageColorSecond,
                    fontSize: 24,
                    fontFamily: 'CuprumBold',
                  ),
                ),
              ],
            ),
          ),
          
          // Динамическая генерация пунктов меню
          ...List.generate(_menuItems.length, (index) {
            return Column(
              children: [
                ListTile(
                  leading: Icon(
                    _menuItems[index]['icon'],
                    color: _selectedIndex == index 
                        ? Pallete.mainOrange  // Активный цвет иконки
                        : Pallete.backColor,  // Неактивный цвет
                  ),
                  title: Text(
                    _menuItems[index]['title'],
                    style: TextStyle(
                      color: _selectedIndex == index 
                          ? Pallete.mainOrange  // Активный цвет текста
                          : Pallete.backColor,  // Неактивный цвет
                      fontFamily: 'CuprumBold',
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    Navigator.pop(context);
                    // Переход с заменой текущего экрана
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _menuItems[index]['route'],
                      ),
                    );
                  },
                  // Стиль для активного элемента
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: _selectedIndex == index 
                      ? Pallete.mainOrange.withOpacity(0.2)  // Подсветка фона
                      : Colors.transparent,
                ),
                // Разделитель между элементами (кроме последнего)
                if (index != _menuItems.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Pallete.backColor.withOpacity(0.1),
                    indent: 16,
                    endIndent: 16,
                  )
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}