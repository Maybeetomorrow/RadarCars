import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:radar/resources/navigation/side_menu.dart';
import 'package:radar/resources/pallete.dart';
import 'package:radar/screens/archive_su_page/components/app_header.dart';
import 'package:radar/screens/archive_su_page/components/date_filter.dart';
import 'package:radar/screens/archive_su_page/components/extended_report_list.dart';
import 'package:radar/screens/archive_su_page/components/report_label.dart';
import 'package:radar/screens/archive_su_page/components/reports_list.dart';
import 'dart:convert';

/// Страница архива служебных отчетов с фильтрацией по датам
/// 
/// Особенности:
/// - Интеграция с HTTP API для получения данных
/// - Поддержка фильтрации по временному диапазону
/// - Обработка состояний загрузки/ошибок
/// - Кастомные компоненты интерфейса
class ArchiveSuPage extends StatefulWidget {
  const ArchiveSuPage({super.key});

  @override
  _ArchiveSuPageState createState() => _ArchiveSuPageState();
}

class _ArchiveSuPageState extends State<ArchiveSuPage> {
  /// Глобальный ключ для управления Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  
  /// Форматировщик дат для отображения в интерфейсе
  final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');
  
  /// Полный список дат отчетов с сервера
  List<DateTime> _allDates = [];
  
  /// Флаг состояния загрузки данных
  bool _isLoading = true;
  
  /// Сообщение об ошибке при загрузке
  String _errorMessage = '';
  
  /// Выбранные пользователем даты для фильтрации
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _loadDates(); // Запуск загрузки данных при инициализации
  }

  /// Асинхронная загрузка списка дат отчетов
  /// 
  /// Особенности:
  /// - Обработка HTTP-ответов
  /// - Парсинг JSON-данных
  /// - Обновление состояния интерфейса
  Future<void> _loadDates() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.1:8080/dates'));
      
      if (response.statusCode == 200) {
        final List<dynamic> datesJson = json.decode(response.body);
        setState(() {
          _allDates = datesJson.map((dateStr) => DateTime.parse(dateStr)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Ошибка загрузки: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка подключения: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Фильтрация дат по выбранным диапазонам
  /// 
  /// Логика:
  /// - Если диапазон не выбран - возвращаются все даты
  /// - Использует методы [DateTime.isBefore] и [DateTime.isAfter]
  List<DateTime> get _filteredDates {
    if (_selectedStartDate == null && _selectedEndDate == null) return _allDates;
    
    return _allDates.where((date) {
      if (_selectedStartDate != null && date.isBefore(_selectedStartDate!)) return false;
      if (_selectedEndDate != null && date.isAfter(_selectedEndDate!)) return false;
      return true;
    }).toList();
  }

  /// Построение основного контента страницы
  /// 
  /// Варианты отображения:
  /// 1. Индикатор загрузки
  /// 2. Экран ошибки с кнопкой повтора
  /// 3. Список отчетов с фильтрами
  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: CircularProgressIndicator(
          color: Pallete.mainOrange,
          strokeWidth: 3,
        ),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, 
              color: Pallete.cherryDark, 
              size: 40),
            const SizedBox(height: 15),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Pallete.textPageColorSecond,
                fontSize: 16,
                fontFamily: 'Cuprum'
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.mainOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _loadDates,
              child: const Text('Повторить попытку',
                style: TextStyle(
                  color: Pallete.textPageColorSecond,
                  fontFamily: 'Cuprum'
                ),
              ),
            )
          ],
        ),
      );
    }
    
    return Column(
      children: [
        if (_selectedStartDate != null || _selectedEndDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              children: [
                Text(
                  '${_selectedStartDate != null 
                    ? _dateFormatter.format(_selectedStartDate!) 
                    : '...'} - ${_selectedEndDate != null 
                      ? _dateFormatter.format(_selectedEndDate!) 
                      : '...'}',
                  style: const TextStyle(
                    color: Pallete.textPageColorSecond,
                    fontSize: 16,
                    fontFamily: 'Cuprum'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedStartDate = null;
                    _selectedEndDate = null;
                  }),
                  child: const Text('Сбросить',
                    style: TextStyle(
                      color: Pallete.mainOrange,
                      fontFamily: 'Cuprum')),
                )
              ],
            ),
          ),
        ReportsList(
          dates: _filteredDates,
          formatter: _dateFormatter,
        ),
        const ReportLabel(),
        const ExtendedReportList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(selectedIndex: 2), // Меню навигации
      backgroundColor: Pallete.backColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppHeader(
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              filterWidget: DateFilter(
                selectedStartDate: _selectedStartDate,
                selectedEndDate: _selectedEndDate,
                onStartDateChanged: (date) => setState(() => _selectedStartDate = date),
                onEndDateChanged: (date) => setState(() => _selectedEndDate = date),
              ),
            ),
            _buildContent(),
          ],
        ),
      ),
    );
  }
}