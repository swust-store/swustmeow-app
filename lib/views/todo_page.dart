import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/entity/todo.dart';
import 'package:swustmeow/utils/color.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:uuid/uuid.dart';
import '../components/todo/animated_todo_item.dart';
import '../data/values.dart';
import '../services/box_service.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<StatefulWidget> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  List<Todo> _todos = [];
  bool _isLoading = true;
  String _isEditingUuid = '';

  // bool _scrollLock = false;
  final TextEditingController _searchController = TextEditingController();
  late FPopoverController _searchPopoverController;
  late FPopoverController _trashPopoverController;
  List<Todo> _searchResult = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    // _scrollController.addListener(_scrollListener);
    _searchPopoverController = FPopoverController(vsync: this);
    _trashPopoverController = FPopoverController(vsync: this);
  }

  void _loadTodos() {
    final cached = _getCachedTodoList();
    if (cached != null) {
      _refresh(() {
        _todos = cached;
        _isLoading = false;
      });
      return;
    }

    _refresh(() {
      _todos = [];
      _isLoading = false;
    });
  }

  List<Todo>? _getCachedTodoList() {
    List<dynamic>? result = BoxService.todoBox.get('todoList');
    if (result == null) return null;
    return result.isEmpty ? [] : result.cast();
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_scrollListener);
    // _scrollController.dispose();
    super.dispose();
  }

  void _refresh([Function()? fn]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn ?? () {});
    });
  }

  // void _scrollListener() {
  //   double clientHeight = MediaQuery.of(context).size.height;
  //   double threshold = clientHeight * 0.15;
  //
  //   if (_scrollController.offset <= -threshold && !_scrollLock) {
  //     _scrollLock = true;
  //     _addNewTodo();
  //   } else {
  //     _scrollLock = false;
  //   }
  // }

  void _addNewTodo() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

    final todo = Todo(
        uuid: const Uuid().v4(),
        content: '',
        color: generateColorFromString(DateTime.timestamp().toString(),
                minBrightness: 0.8)
            .toInt(),
        isFinished: false);
    _refresh(() {
      _todos.add(todo);
      _isEditingUuid = todo.uuid;
      _refreshCache();
    });
  }

  void _removeTodo(Todo todo) {
    _refresh(() {
      _todos.remove(todo);
      _refreshCache();
    });
  }

  void _editTodo(Todo todo, String newContent) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh(() {
        todo.content = newContent;
        _refreshCache();
        _isEditingUuid = '';
      });
    });
  }

  void _finishTodo(Todo todo) {
    _refresh(() {
      todo.isFinished = true;
      _refreshCache();
    });
  }

  Future<void> _refreshCache() async {
    await BoxService.todoBox.put('todoList', _todos);
  }

  @override
  Widget build(BuildContext context) {
    const iconSize = 40.0;
    final todos = _isSearching ? _searchResult : _todos;
    final unfinished = _buildTodoWidgets(todos, false);
    final finished = _buildTodoWidgets(todos, true);

    return Transform.flip(
      flipX: Values.isFlipEnabled.value,
      flipY: Values.isFlipEnabled.value,
      child: BasePage(
          gradient: LinearGradient(colors: [
            MTheme.primary1,
            MTheme.primary1,
            MTheme.primary2,
            Colors.white
          ], transform: const GradientRotation(pi / 2)),
          top: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Text(
                          '待办',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          todos.isEmpty ? '点击右下加号以新增待办' : finished.length < todos.length
                              ? '已完成待办：${finished.length}/${todos.length}'
                              : '已全部完成：${todos.length}个待办',
                          style: TextStyle(
                            color: MTheme.primaryText,
                            fontSize: 14,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: iconSize, child: _buildSearchPopover()),
                  SizedBox(
                    width: iconSize,
                    child: IconButton(
                      onPressed: () => _refresh(() {
                        _isSearching = false;
                        _searchResult.clear();
                      }),
                      icon: FaIcon(
                        FontAwesomeIcons.rotateRight,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: iconSize, child: _buildTrashPopover())
                ],
              ),
              SizedBox(height: 16.0),
            ],
          ),
          bottom: _buildContent(unfinished, finished)),
    );
  }

  List<Widget> _buildTodoWidgets(Iterable<Todo> todos, bool finished) {
    return [
      ...todos.where((t) => t.isFinished == finished).map((t) => Opacity(
            opacity: finished ? 0.4 : 1,
            child: _buildItem(t),
          ))
    ];
  }

  Widget _buildContent(List<Widget> unfinished, List<Widget> finished) {
    final result = [
      ...unfinished,
      ...finished,
      const SizedBox(
        height: (48 + 32) * 2,
      )
    ];

    return Stack(
      children: [
        _isLoading
            ? CircularProgressIndicator(
                color: context.theme.colorScheme.primary,
              )
            : FTappable(
                onPress: () {
                  if (_isEditingUuid.isEmpty) return;
                  _refresh(() => _isEditingUuid = '');
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: result.length,
                  itemBuilder: (context, index) => result[index],
                  padding: EdgeInsets.zero,
                ),
              ),
        Positioned(
          bottom: 48 + 32,
          right: 16,
          child: FloatingActionButton(
            onPressed: _addNewTodo,
            backgroundColor: MTheme.primary3,
            child: FaIcon(
              FontAwesomeIcons.plus,
              color: Colors.white,
              size: 20,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSearchPopover() {
    return FPopover(
      controller: _searchPopoverController,
      popoverBuilder: (context, style, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: FTextField(
            controller: _searchController,
            hint: '搜待办，点击右侧刷新按钮可清除搜索',
            maxLines: 1,
            autofocus: true,
            onChange: (String value) {
              if (value.isEmpty) {
                _refresh(() {
                  _searchResult.clear();
                  _isSearching = false;
                });
                return;
              }

              final result = _onSearch(value);
              _refresh(() {
                _searchResult = result;
                _isSearching = true;
              });
            },
          )),
      child: IconButton(
        onPressed: () {
          _searchPopoverController.toggle();
          _searchController.clear();
          _refresh(() {
            _searchResult.clear();
          });
        },
        icon: FaIcon(
          FontAwesomeIcons.magnifyingGlass,
          color: _isSearching ? Colors.red[200] : Colors.white,
          size: 20,
        ),
        color: context.theme.colorScheme.primary,
      ),
    );
  }

  List<Todo> _onSearch(String query) {
    return _todos
        .where((t) => t.content.pureString.contains(query.pureString))
        .toList();
  }

  Widget _buildTrashPopover() {
    pop() => _trashPopoverController.hide();

    return FPopoverMenu(
      popoverController: _trashPopoverController,
      menuAnchor: Alignment.topRight,
      childAnchor: Alignment.bottomRight,
      menu: [
        FTileGroup(children: [
          FTile(
            title: const Text('清除未完成'),
            prefixIcon: FaIcon(FontAwesomeIcons.circle),
            onPress: () {
              _refresh(() {
                _todos.removeWhere((t) => !t.isFinished);
                _refreshCache();
              });
              pop();
            },
          ),
          FTile(
            title: const Text('清除已完成'),
            prefixIcon: FaIcon(FontAwesomeIcons.solidCircleCheck),
            onPress: () {
              _refresh(() {
                _todos.removeWhere((t) => t.isFinished);
                _refreshCache();
              });
              pop();
            },
          ),
          FTile(
            title: const Text('清除空待办'),
            prefixIcon: FaIcon(FontAwesomeIcons.solidTrashCan),
            onPress: () {
              _refresh(() {
                _todos.removeWhere((t) => t.content.isEmpty || t.isNew);
                _refreshCache();
              });
              pop();
            },
          ),
          FTile(
            title: const Text(
              '清除所有',
              style: TextStyle(color: Colors.red),
            ),
            prefixIcon: FaIcon(
              FontAwesomeIcons.trash,
              color: Colors.red,
            ),
            onPress: () {
              _refresh(() {
                _todos.clear();
                _refreshCache();
              });
              pop();
            },
          )
        ])
      ],
      child: IconButton(
        onPressed: () {
          _trashPopoverController.toggle();
        },
        icon: FaIcon(
          FontAwesomeIcons.solidTrashCan,
          color: _isSearching ? Colors.red[200] : Colors.white,
          size: 20,
        ),
        color: context.theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildItem(Todo todo) {
    return AnimatedTodoItem(
      todo: todo,
      isEditing: _isEditingUuid == todo.uuid,
      onDelete: () => _removeTodo(todo),
      onFinishEdit: (newContent) {
        _editTodo(todo, newContent);
      },
      onEdit: () {
        _refresh(() => _isEditingUuid = todo.uuid);
      },
      onFinish: () => _finishTodo(todo),
    );
  }
}
