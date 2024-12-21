import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miaomiaoswust/entity/todo.dart';

class TodoRow extends StatefulWidget {
  const TodoRow({super.key, required this.todo});

  final Todo todo;

  @override
  State<StatefulWidget> createState() => _TodoRowState();
}

class _TodoRowState extends State<TodoRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(widget.todo.color),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: [
          Transform(
              transform: Matrix4.translationValues(0, 2, 0),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                    color: widget.todo.isFinished ? Colors.black : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                    border: Border.all(color: Colors.black, width: 2)),
                child: widget.todo.isFinished
                    ? FIcon(
                        FAssets.icons.check,
                        color: Colors.white,
                      )
                    : null,
              )),
          const SizedBox(
            width: 8,
          ),
          Expanded(
              child: Text(
            widget.todo.title,
            style: TextStyle(color: Colors.black.withOpacity(0.8)),
          ))
        ],
      ),
    );
  }
}
