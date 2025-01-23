import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/components/clickable.dart';
import 'package:miaomiaoswust/entity/todo.dart';
import 'package:miaomiaoswust/utils/color.dart';
import 'package:uuid/uuid.dart';
import '../components/home/animated_todo_item.dart';
import '../services/box_service.dart';
import '../utils/router.dart';
import 'main_page.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({
    super.key,
    required this.todos,
  });

  final List<Todo> todos;

  @override
  State<StatefulWidget> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  List<Todo> _todos = [];
  String _isEditingUuid = '';
  bool _scrollLock = false;
  final TextEditingController _searchController = TextEditingController();
  late FPopoverController _searchPopoverController;
  late FPopoverController _trashPopoverController;
  List<Todo> _searchResult = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _todos = widget.todos;
    _scrollController.addListener(_scrollListener);
    _searchPopoverController = FPopoverController(vsync: this);
    _trashPopoverController = FPopoverController(vsync: this);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    double clientHeight = MediaQuery.of(context).size.height;
    double threshold = clientHeight * 0.15;

    if (_scrollController.offset <= -threshold && !_scrollLock) {
      _scrollLock = true;
      _addNewTodo();
    } else {
      _scrollLock = false;
    }
  }

  void _addNewTodo() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

    final todo = Todo(
        uuid: const Uuid().v4(),
        content: '',
        color: generateColorFromString(DateTime.timestamp().toString(),
                minBrightness: 0.8)
            .value,
        isFinished: false);
    setState(() {
      _todos.add(todo);
      _isEditingUuid = todo.uuid;
      _refreshCache();
    });
  }

  void _removeTodo(Todo todo) {
    setState(() {
      _todos.remove(todo);
      _refreshCache();
    });
  }

  void _editTodo(Todo todo, String newContent) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        todo.content = newContent;
        _refreshCache();
        _isEditingUuid = '';
      });
    });
  }

  void _finishTodo(Todo todo) {
    setState(() {
      todo.isFinished = true;
      _refreshCache();
    });
  }

  void _refreshCache() {
    BoxService.todoListBox.put('todoList', _todos);
  }

  @override
  Widget build(BuildContext context) {
    final unfinished = _buildUnfinishedList();
    final finished = _buildFinishedList();
    final result = <Widget>[
          Container(
            alignment: Alignment.center,
            child: const Text(
              '下拉或点击右下按钮来添加新的待办项',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          )
        ] +
        unfinished +
        finished +
        <Widget>[
          const SizedBox(
            height: 32.0,
          )
        ];

    return SafeArea(
        bottom: true,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: _addNewTodo,
            backgroundColor: context.theme.colorScheme.secondary,
            child: FIcon(
              FAssets.icons.plus,
              color: context.theme.colorScheme.secondaryForeground,
            ),
          ),
          body: FScaffold(
              contentPad: false,
              header: FHeader.nested(
                title: const Text(
                  '待办',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                prefixActions: [
                  FHeaderAction(
                      icon: FIcon(FAssets.icons.chevronLeft),
                      onPress: () {
                        Navigator.of(context).pop();
                      })
                ],
                suffixActions: [
                  _buildSearchPopover(),
                  FHeaderAction(
                      icon: FIcon(
                        FAssets.icons.rotateCcw,
                        size: 20,
                      ),
                      onPress: () => setState(() {
                            _isSearching = false;
                            _searchResult.clear();
                          })),
                  _buildTrashPopover()
                ],
              ),
              content: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollUpdateNotification) {
                    _scrollListener();
                  }
                  return true;
                },
                child: Clickable(
                  onPress: () {
                    if (_isEditingUuid.isEmpty) return;

                    setState(() => _isEditingUuid = '');
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
              )),
        ));
  }

  Widget _buildSearchPopover() {
    return FPopover(
        controller: _searchPopoverController,
        followerBuilder: (context, style, _) => Padding(
            padding: const EdgeInsets.all(20),
            child: FTextField(
              controller: _searchController,
              hint: '搜待办...点击右侧刷新按钮可清除搜索',
              maxLines: 1,
              autofocus: true,
              onChange: (String value) {
                if (value.isEmpty) {
                  setState(() {
                    _searchResult.clear();
                    _isSearching = false;
                  });
                  return;
                }

                final result = _onSearch(value);
                setState(() {
                  _searchResult = result;
                  _isSearching = true;
                });
              },
            )),
        target: IconButton(
            onPressed: () {
              _searchPopoverController.toggle();
              _searchController.clear();
              setState(() {
                _searchResult.clear();
              });
            },
            icon: Icon(
              Icons.search,
              color: _isSearching ? Colors.red : null,
            ),
            color: context.theme.colorScheme.primary));
  }

  List<Todo> _onSearch(String query) {
    return _todos.where((t) => t.content.contains(query)).toList();
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
              prefixIcon: FIcon(FAssets.icons.circle),
              onPress: () {
                setState(() {
                  _todos.removeWhere((t) => !t.isFinished);
                  _refreshCache();
                });
                pop();
              },
            ),
            FTile(
              title: const Text('清除已完成'),
              prefixIcon: FIcon(FAssets.icons.check),
              onPress: () {
                setState(() {
                  _todos.removeWhere((t) => t.isFinished);
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
              prefixIcon: FIcon(
                FAssets.icons.trash2,
                color: Colors.red,
              ),
              onPress: () {
                setState(() {
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
            icon: FIcon(FAssets.icons.trash),
            color: context.theme.colorScheme.primary));
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
        setState(() => _isEditingUuid = todo.uuid);
      },
      onFinish: () => _finishTodo(todo),
    );
  }

  List<Widget> _buildUnfinishedList() {
    final unfinished =
        (_isSearching ? _searchResult : _todos).where((t) => !t.isFinished);
    return [
      // Padding(
      //     padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      //     child: unfinished.isEmpty
      //         ? const Center(
      //             child: Text('~这里什么都木有~'),
      //           )
      //         : const Opacity(
      //             opacity: 0.5,
      //             child: DividerWithText(
      //               child: Text(
      //                 '未完成',
      //                 style: TextStyle(color: Colors.grey),
      //               ),
      //             ),
      //           )),
      ...unfinished.map((todo) => _buildItem(todo))
    ];
  }

  List<Widget> _buildFinishedList() {
    final finished =
        (_isSearching ? _searchResult : _todos).where((t) => t.isFinished);
    return finished.isEmpty
        ? []
        : [
            // const Opacity(
            //     opacity: 0.5,
            //     child: Padding(
            //         padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
            //         child: DividerWithText(
            //           child: Text(
            //             '已完成',
            //             style: TextStyle(color: Colors.grey),
            //           ),
            //         ))),
            ...finished.map((todo) => Opacity(
                  opacity: 0.4,
                  child: _buildItem(todo),
                ))
          ];
  }
}
