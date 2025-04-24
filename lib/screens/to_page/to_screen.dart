import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';
import 'package:radar/resources/navigation/side_menu.dart';
import 'package:radar/screens/archive_to_page/archive_to_screen.dart';
import 'package:radar/screens/to_page/km_info.dart';
import 'package:radar/screens/to_page/node_row.dart';
import 'package:radar/screens/to_page/to_repository.dart';
import 'package:radar/widgets/button.dart';
import 'node_item.dart';

/// Основная страница технического обслуживания (ТО)
/// 
/// Особенности:
/// - Интеграция с репозиторием для работы с API
/// - Управление списком узлов с чекбоксами и комментариями
/// - Отслеживание пробега до следующего ТО
/// - Поддержка прокрутки с фокусировкой на выбранных элементах
/// - Валидация данных перед отправкой
class ToPage extends StatefulWidget {
  const ToPage({super.key});

  @override
  State<ToPage> createState() => _ToPageState();
}

class _ToPageState extends State<ToPage> {
  /// Глобальный ключ для управления Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  
  /// Контроллер прокрутки для списка узлов
  final ScrollController _scrollController = ScrollController();
  
  /// Список узлов оборудования с состоянием
  List<NodeItem> _nodes = [];
  
  /// Ключи для доступа к отдельным строкам списка
  final List<GlobalKey> _rowKeys = [];
  
  /// Флаг загрузки данных узлов
  bool _isLoading = true;
  
  /// Сообщение об ошибке загрузки узлов
  String _errorMessage = '';
  
  /// Оставшийся пробег до ТО
  double _remainingKm = 0.0;
  
  /// Статус обслуживания
  String _serviceStatus = '';
  
  /// Флаг загрузки данных пробега
  bool _isKmLoading = true;
  
  /// Сообщение об ошибке загрузки пробега
  String _kmErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNodes(); // Загрузка узлов при инициализации
    _fetchRemainingKm(); // Загрузка данных пробега
  }

  /// Загрузка списка узлов оборудования
  /// 
  /// Особенности:
  /// - Генерация уникальных ключей для строк
  /// - Инициализация контроллеров текстовых полей
  Future<void> _fetchNodes() async {
    try {
      final data = await ToRepository.fetchNodes();
      setState(() {
        _nodes = data
            .map((node) => NodeItem(name: node['name'] as String))
            .toList();
        _rowKeys.addAll(List.generate(_nodes.length, (index) => GlobalKey()));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка подключения: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Загрузка данных оставшегося пробега
  /// 
  /// Особенности:
  /// - Обработка вложенных данных из ответа API
  Future<void> _fetchRemainingKm() async {
    try {
      final data = await ToRepository.fetchRemainingKm();
      setState(() {
        _remainingKm = data['remaining_km']?.toDouble() ?? 0.0;
        _serviceStatus = data['status'] ?? '';
        _isKmLoading = false;
      });
    } catch (e) {
      setState(() {
        _kmErrorMessage = 'Ошибка подключения: ${e.toString()}';
        _isKmLoading = false;
      });
    }
  }

  /// Отправка данных о проведенных работах
  /// 
  /// Особенности:
  /// - Валидация выбранных узлов
  /// - Очистка формы после успешной отправки
  /// - Визуальные уведомления через SnackBar
  Future<void> _submitMaintenance() async {
    final selectedNodes = _nodes
        .where((node) => node.isSelected)
        .map((node) => {
              'node_name': node.name,
              'comment': node.commentController.text,
            })
        .toList();
    
    if (selectedNodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы один узел для подтверждения'),
          backgroundColor: Pallete.cherryDark,
        ),
      );
      return;
    }

    try {
      await ToRepository.submitMaintenance(selectedNodes);
      setState(() {
        for (var node in _nodes) {
          node.isSelected = false;
          node.commentController.clear();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные успешно отправлены'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Pallete.cherryDark,
        ),
      );
    }
  }

  /// Виджет информации о пробеге
  /// 
  /// Инкапсулирует логику отображения:
  /// - Загрузка/ошибка/данные
  /// - Интеграция с [KmInfo]
  Widget _buildKmInfo() {
    return KmInfo(
      isKmLoading: _isKmLoading,
      kmErrorMessage: _kmErrorMessage,
      remainingKm: _remainingKm,
    );
  }

  @override
  void dispose() {
    for (var node in _nodes) {
      node.commentController.dispose(); // Освобождение ресурсов
    }
    _scrollController.dispose();
    super.dispose();
  }

  /// Прокрутка к выбранному элементу списка
  /// 
  /// Особенности:
  /// - Использует GlobalKey для доступа к контексту
  /// - Анимированная прокрутка с задержкой
  void _scrollToSelectedContent(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _rowKeys[index].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    });
  }

  /// Обработчик нажатий кнопок
  /// 
  /// Особенности:
  /// - Снимает фокус с текстовых полей
  /// - Выполняет переданный callback
  void _handleButtonPress(Function() action) {
    FocusManager.instance.primaryFocus?.unfocus();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const SideMenu(selectedIndex: 1), // Интеграция с навигационным меню
        backgroundColor: Pallete.backColor,
        body: Stack(
          children: [
            Column(
              children: [
                // Заголовок и навигация
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Левая секция с меню и заголовком
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
                              onPressed: () => _handleButtonPress(
                                () => _scaffoldKey.currentState?.openDrawer(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'ТО',
                              style: TextStyle(
                                color: Pallete.textPageColorSecond,
                                fontSize: 48,
                                fontFamily: 'CuprumBold',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Правая секция с архивом
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
                                    builder: (context) => const ArchiveToPage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Архив ТО',
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
                // Основное содержимое
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Блок пробега
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Pallete.textPageColorSecond,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              Text(
                                'Дистанция до ТО',
                                style: TextStyle(
                                  color: Pallete.textPageColorSecond.withOpacity(0.7),
                                  fontSize: 20,
                                  fontFamily: 'CuprumBold',
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildKmInfo(),
                            ],
                          ),
                        ),
                        // Блок списка узлов
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Pallete.textPageColorSecond,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                            margin: const EdgeInsets.only(bottom: 20),
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator(color: Pallete.mainOrange))
                                : _errorMessage.isNotEmpty
                                    ? Center(
                                        child: Text(
                                          _errorMessage,
                                          style: const TextStyle(color: Pallete.cherryDark),
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Text(
                                            'Выполнено',
                                            style: TextStyle(
                                              color: Pallete.textPageColorSecond,
                                              fontSize: 28,
                                              fontFamily: 'CuprumBold',
                                            ),
                                          ),
                                          // Список узлов с прокруткой
                                          Expanded(
                                            child: ListView.builder(
                                              controller: _scrollController,
                                              itemCount: _nodes.length,
                                              itemBuilder: (context, index) => NodeRow(
                                                node: _nodes[index],
                                                onFocus: () => _scrollToSelectedContent(index),
                                                rowKey: _rowKeys[index],                                            
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          // Кнопка подтверждения
                                          Button(
                                            buttonText: 'Подтвердить',
                                            onPressed: () => _handleButtonPress(_submitMaintenance),
                                            width: 250,
                                            height: 50,
                                          ),
                                        ],
                                      ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}