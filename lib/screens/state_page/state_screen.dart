import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:radar/resources/navigation/side_menu.dart';
import 'package:radar/resources/pallete.dart';
import 'package:radar/screens/archive_su_page/archive_su_screen.dart';
import 'package:radar/resources/utils/scan_animation.dart';
import 'dart:convert';

/// Основная страница мониторинга состояния системы
/// 
/// Особенности:
/// - Анимации сканирования с интерактивными зонами
/// - Интеграция с API для получения данных узлов
/// - Визуализация статусов оборудования
/// - Поддержка архивных данных через навигацию
class StatePage extends StatefulWidget {
  const StatePage({super.key});

  @override
  State<StatePage> createState() => _StatePageState();
}

class _StatePageState extends State<StatePage> with SingleTickerProviderStateMixin {
  /// Контроллер для анимаций отображения данных
  late AnimationController _animationController;
  
  /// Анимация плавного появления
  late Animation<double> _opacityAnimation;
  
  /// Анимация смещения для эффекта появления
  late Animation<Offset> _slideAnimation;
  
  /// Глобальный ключ для управления Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  /// Данные выбранного узла
  Map<String, dynamic>? _selectedNodeData;
  
  /// ID последней нажатой кнопки сканирования
  int? _selectedButton;
  
  /// Флаг загрузки данных узла
  bool _isLoadingNode = false;
  
  /// Сообщение об ошибке загрузки узла
  String _nodeError = '';
  
  /// Текущая дата для запросов (заглушка)
  final String _currentDate = '2024-03-20';
  
  /// Список информации об узлах системы
  List<Map<String, dynamic>> _nodesInfo = [];
  
  /// Флаг загрузки информации об узлах
  bool _isLoadingNodesInfo = false;
  
  /// Сообщение об ошибке загрузки информации об узлах
  String _nodesInfoError = '';

  @override
  void initState() {
    super.initState();
    _initAnimations(); // Инициализация анимаций
  }

  /// Инициализация анимационных контроллеров
  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  /// Загрузка данных конкретного узла
  /// 
  /// Параметры:
  /// - nodeId: Идентификатор узла для запроса
  /// 
  /// Особенности:
  /// - Обработка структуры вложенного JSON
  /// - Автоматическое обновление интерфейса
  Future<void> _fetchNodeData(int nodeId) async {
    setState(() {
      _isLoadingNode = true;
      _nodeError = '';
      _selectedNodeData = null;
    });
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.1:8080/daily-reports/$_currentDate'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nodes = data['nodes'] as List<dynamic>;
        if (nodeId > 0 && nodeId <= nodes.length) {
          setState(() {
            _selectedNodeData = nodes[nodeId - 1] as Map<String, dynamic>;
          });
        } else {
          setState(() => _nodeError = 'Узел не найден');
        }
      } else {
        setState(() => _nodeError = 'Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _nodeError = 'Ошибка подключения: ${e.toString()}');
    } finally {
      setState(() => _isLoadingNode = false);
    }
  }

  /// Загрузка информации обо всех узлах системы
  /// 
  /// Особенности:
  /// - Отдельный запрос к /nodes
  /// - Обработка простого списка узлов
  Future<void> _fetchNodesInfo() async {
    setState(() {
      _isLoadingNodesInfo = true;
      _nodesInfoError = '';
    });
    try {
      final response = await http.get(Uri.parse('http://192.168.1.1:8080/nodes'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() => _nodesInfo = data.cast<Map<String, dynamic>>());
      } else {
        setState(() => _nodesInfoError = 'Ошибка загрузки: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _nodesInfoError = 'Ошибка подключения: ${e.toString()}');
    } finally {
      setState(() => _isLoadingNodesInfo = false);
    }
  }

  /// Обработчик нажатия на зону сканирования
  /// 
  /// Параметры:
  /// - nodeId: Идентификатор выбранного узла
  void _handleScanPress(int nodeId) {
    setState(() => _selectedButton = nodeId);
    _fetchNodeData(nodeId);
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Построение секции с изображениями оборудования
  /// 
  /// Особенности:
  /// - Декоративная рамка с тенью
  /// - Интеграция с диалогом информации об узлах
  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Pallete.textPageColorSecond, width: 2.0),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Image.asset(
                'assets/images/car/car_left.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/car/car_right.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 30,
          child: GestureDetector(
            onTap: () => _showImageInfoDialog(context),
            child: Container(
              decoration: BoxDecoration(
                color: Pallete.backColor.withOpacity(0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.info_outline,
                color: Pallete.textPageColorSecond,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Диалог с информацией об узлах системы
  /// 
  /// Особенности:
  /// - Динамическое обновление при открытии
  /// - Адаптивные размеры контента
  void _showImageInfoDialog(BuildContext context) {
    _fetchNodesInfo().then((_) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Pallete.textPageColorSecond,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Узлы в системе',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'CuprumBold',
                    color: Pallete.backColor,
                  ),
                ),
                const Divider(height: 20, color: Colors.grey),
                if (_isLoadingNodesInfo)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Pallete.backColor),
                    ),
                  )
                else if (_nodesInfoError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _nodesInfoError,
                      style: const TextStyle(
                        color: Pallete.cherryDark,
                        fontFamily: 'CuprumBold',
                      ),
                    ),
                  )
                else
                  ..._nodesInfo.map((node) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${node['id']}. ${node['name']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'CuprumBold',
                          color: Pallete.backColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        node['description'],
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'CuprumBold',
                          color: Pallete.backColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  )).toList(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Закрыть',
                      style: TextStyle(
                        color: Pallete.backColor,
                        fontFamily: 'CuprumBold',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Виджет информации о выбранном узле
  /// 
  /// Особенности:
  /// - Анимированное появление
  /// - Отображение статуса и подузлов
  Widget _buildNodeInfo() {
    if (_isLoadingNode) {
      return const Center(
        child: CircularProgressIndicator(color: Pallete.mainOrange),
      );
    }
    if (_nodeError.isNotEmpty) {
      return Center(
        child: Text(
          _nodeError,
          style: const TextStyle(color: Pallete.cherryDark),
        ),
      );
    }
    if (_selectedNodeData == null) return const SizedBox.shrink();
    final node = _selectedNodeData!;
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Pallete.textPageColorSecond,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node['node_name'] ?? 'Название узла',
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'CuprumBold',
                    color: Pallete.backColor,
                  ),
                ),
                const SizedBox(height: 10),
                _buildStatusRow(node['node_status']),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallete.backColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    onPressed: () => _showSubnodesDialog(context),
                    child: const Text(
                      'Просмотреть подузлы',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'CuprumBold',
                        color: Pallete.textPageColorSecond,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Строка статуса узла с цветовой индикацией
  /// 
  /// Параметры:
  /// - status: Текстовый статус для отображения
  Widget _buildStatusRow(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'критично':
        statusColor = Pallete.cherryDark;
        break;
      case 'осторожно':
        statusColor = Pallete.mainOrange;
        break;
      default:
        statusColor = Colors.green;
    }
    return Row(
      children: [
        const Text(
          'Состояние узла:',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'CuprumBold',
            color: Pallete.backColor,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'CuprumBold',
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Диалог списка подузлов
  /// 
  /// Особенности:
  /// - Табличное представление данных
  /// - Двойной скроллинг для больших данных
  void _showSubnodesDialog(BuildContext context) {
    if (_selectedNodeData == null) return;
    final subnodes = _selectedNodeData!['subnodes'] as List<dynamic>;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Pallete.backColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Подузлы ${_selectedNodeData!['node_name']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'CuprumBold',
                  color: Pallete.textPageColorSecond,
                ),
              ),
              const Divider(height: 20, color: Pallete.textPageColorSecond),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: _DialogHeaderText('Название')),
                        DataColumn(label: _DialogHeaderText('Статус')),
                        DataColumn(label: _DialogHeaderText('Ошибки')),
                        DataColumn(label: _DialogHeaderText('Предупреждения')),
                      ],
                      rows: subnodes.map<DataRow>((subnode) {
                        final status = subnode['subnode_status'].toString();
                        return DataRow(
                          cells: [
                            DataCell(SizedBox(
                              width: 200,
                              child: Text(
                                subnode['subnode_name'].toString(),
                                style: TextStyle(
                                  color: Pallete.textPageColorSecond.withOpacity(0.8),
                                  fontFamily: 'CuprumBold',
                                ),
                              ),
                            )),
                            DataCell(_buildStatusIndicator(status)),
                            DataCell(Text(
                              subnode['errors'].toString(),
                              style: TextStyle(
                                color: subnode['errors'] > 0 
                                    ? Pallete.cherryDark 
                                    : Pallete.textPageColorSecond.withOpacity(0.8),
                                fontFamily: 'CuprumBold',
                              ),
                            )),
                            DataCell(Text(
                              subnode['warnings'].toString(),
                              style: TextStyle(
                                color: subnode['warnings'] > 0 
                                    ? Pallete.mainOrange 
                                    : Pallete.textPageColorSecond.withOpacity(0.8),
                                fontFamily: 'CuprumBold',
                              ),
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Закрыть',
                  style: TextStyle(
                    color: Pallete.textPageColorSecond,
                    fontFamily: 'CuprumBold',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Индикатор статуса для таблиц
  /// 
  /// Параметры:
  /// - status: Текстовое представление статуса
  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'критично':
        color = Pallete.cherryDark;
        break;
      case 'осторожно':
        color = Pallete.mainOrange;
        break;
      default:
        color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontFamily: 'CuprumBold',
        ),
      ),
    );
  }

  /// Генерация анимированных зон сканирования
  /// 
  /// Конфигурации позиционирования берутся из списка scanConfigs
  List<Widget> _buildScanAnimations(BuildContext context) {
    final scanConfigs = [
      {'bottom': 350.0, 'right': 25.0, 'number': 10},
      {'bottom': 325.0, 'right': 175.0, 'number': 8},
      {'bottom': 350.0, 'right': 325.0, 'number': 6},
      {'bottom': 325.0, 'left': 115.0, 'number': 7},
      {'bottom': 325.0, 'left': 275.0, 'number': 9},
      {'top': 275.0, 'right': 25.0, 'number': 5},
      {'top': 310.0, 'right': 175.0, 'number': 3},
      {'top': 310.0, 'right': 325.0, 'number': 1},
      {'top': 275.0, 'left': 135.0, 'number': 2},
      {'top': 310.0, 'left': 275.0, 'number': 4},
    ];
    return scanConfigs.map((config) {
      final number = config['number'] as int;
      return _buildPositionedScan(
        context,
        bottom: config['bottom'] as double?,
        top: config['top'] as double?,
        left: config['left'] as double?,
        right: config['right'] as double?,
        number: number,
        isSelected: _selectedButton == number,
      );
    }).toList();
  }

  /// Позиционирование анимированных кнопок сканирования
  /// 
  /// Параметры:
  /// - top/bottom/left/right: Координаты позиционирования
  /// - number: Номер зоны сканирования
  /// - isSelected: Состояние выбора
  Positioned _buildPositionedScan(
    BuildContext context, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required int number,
    bool isSelected = false,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ScanAnimation(
        onScanPressed: () => _handleScanPress(number),
        buttonText: number.toString(),
        isSelected: isSelected,
        buttonTextStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Обработчик нажатий кнопок с закрытием клавиатуры
  void _handleButtonPress(Function() action) {
    FocusManager.instance.primaryFocus?.unfocus();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(selectedIndex: 0),
      backgroundColor: Pallete.backColor,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Pallete.textPageColorSecond,
                              size: 30,
                            ),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Состояние',
                            style: TextStyle(
                              color: Pallete.textPageColorSecond,
                              fontSize: 48,
                              fontFamily: 'CuprumBold',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 104.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.archive,
                              color: Pallete.textPageColorSecond,
                              size: 30,
                            ),
                            onPressed: () => _handleButtonPress(
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ArchiveSuPage(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Архив СУ',
                            style: TextStyle(
                              color: Pallete.textPageColorSecond,
                              fontSize: 24,
                              fontFamily: 'CuprumBold',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildImageSection(),
                      _buildNodeInfo(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ..._buildScanAnimations(context),
        ],
      ),
    );
  }
}

/// Виджет заголовка столбца таблицы
class _DialogHeaderText extends StatelessWidget {
  final String text;
  const _DialogHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'CuprumBold',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}