import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forui/forui.dart';
import 'package:swustmeow/components/utils/base_page.dart';
import 'package:swustmeow/components/utils/refresh_icon.dart';
import 'package:swustmeow/data/m_theme.dart';
import 'package:swustmeow/data/showcase_values.dart';
import 'package:swustmeow/data/values.dart';
import 'package:swustmeow/entity/todo.dart';
import 'package:swustmeow/utils/color.dart';
import 'package:swustmeow/utils/text.dart';
import 'package:uuid/uuid.dart';
import '../components/todo/animated_todo_item.dart';
import '../services/boxes/todo_box.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<StatefulWidget> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  List<Todo> _todos = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  String _isEditingUuid = '';
  late AnimationController _refreshAnimationController;

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
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  void _loadTodos() {
    if (Values.showcaseMode) {
      _refresh(() {
        _todos = ShowcaseValues.todos.map((c) => Todo.fromJson(c)).toList();
        _isLoading = false;
      });
      return;
    }

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
    List<dynamic>? result = TodoBox.get('todoList');
    if (result == null) return null;
    return result.isEmpty ? [] : result.cast();
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_scrollListener);
    // _scrollController.dispose();
    _refreshAnimationController.dispose();
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
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    final todo = Todo(
        uuid: const Uuid().v4(),
        content: '',
        color: generateColorFromString(DateTime.timestamp().toString(),
                minBrightness: 0.8)
            .toInt(),
        isFinished: false);
    _refresh(() {
      _todos.insert(0, todo);
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
    await TodoBox.put('todoList', _todos);
  }

  @override
  Widget build(BuildContext context) {
    const iconSize = 40.0;
    final todos = _isSearching ? _searchResult : _todos;
    final unfinished = _buildTodoWidgets(todos, false);
    final finished = _buildTodoWidgets(todos, true);

    return BasePage(
      header: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  children: [
                    Text(
                      '待办',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      todos.isEmpty
                          ? '点击右下加号以新增待办'
                          : finished.length < todos.length
                              ? '已完成待办：${finished.length}/${todos.length}'
                              : '已全部完成：${todos.length}个待办',
                      style: TextStyle(
                        color: MTheme.backgroundText,
                        fontSize: 10,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: iconSize, child: _buildSearchPopover()),
              RefreshIcon(
                isRefreshing: _isRefreshing,
                onRefresh: () async {
                  if (_isLoading || _isRefreshing) return;

                  _refresh(() {
                    _isRefreshing = true;
                    _refreshAnimationController.repeat();
                  });
                  _loadTodos();
                  _refresh(() {
                    _isSearching = false;
                    _searchResult.clear();
                    _isRefreshing = false;
                    _refreshAnimationController.stop();
                    _refreshAnimationController.reset();
                  });
                },
              ),
              SizedBox(width: iconSize, child: _buildTrashPopover())
            ],
          ),
          SizedBox(height: 8.0),
        ],
      ),
      content: _buildContent(unfinished, finished),
    );
  }

  List<Widget> _buildTodoWidgets(Iterable<Todo> todos, bool finished) {
    return [
      ...todos.where((t) => t.isFinished == finished).map(
            (t) => Opacity(
              opacity: finished ? 0.4 : 1,
              child: _buildItem(t),
            ),
          )
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
                color: MTheme.primary2,
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
                    parent: BouncingScrollPhysics(),
                  ),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: result.length,
                  itemBuilder: (context, index) => result[index],
                  padding: EdgeInsets.zero,
                ),
              ),
        Positioned(
          bottom: 32,
          right: 24,
          child: FloatingActionButton(
            onPressed: _addNewTodo,
            backgroundColor: MTheme.primary2,
            child: FaIcon(
              FontAwesomeIcons.plus,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchPopover() {
    return FPopover(
      controller: _searchPopoverController,
      popoverAnchor: Alignment.bottomLeft,
      childAnchor: Alignment.topRight,
      popoverBuilder: (context, style, _) => SizedBox(
        width: 300,
        child: Padding(
          padding: EdgeInsets.all(MTheme.radius),
          child: FTextField(
            controller: _searchController,
            hint: '搜待办，点击右侧刷新按钮可清除',
            textInputAction: TextInputAction.done,
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
          ),
        ),
      ),
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
      key: Key(todo.uuid),
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
