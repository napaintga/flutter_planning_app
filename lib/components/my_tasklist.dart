import 'package:flutter/material.dart';


class TaskListCard extends StatefulWidget {
  const TaskListCard({
    super.key,
    required this.theme,
    required this.name,
    required this.hour,
    required this.isChecked,
    required this.saveChecked,
    required this.CustomDialog,

  });

  final ThemeData theme;
  final String name;
  final String hour;
  final bool isChecked;
  final Function() saveChecked;
  final Function(BuildContext) CustomDialog;


  @override
  State<TaskListCard> createState() => _TaskListCardState();
}

class _TaskListCardState extends State<TaskListCard> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90,
      padding: const EdgeInsets.all(13),
      margin: const EdgeInsets.only(bottom: 13, left: 5, right: 5),
      decoration: BoxDecoration(
        color: _isChecked ? Colors.grey.shade200 : Colors.white,
        border: Border.all(
          color: Colors.grey.shade600,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => widget.CustomDialog(context),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.name,
                style: TextStyle(
                  decoration: _isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
              Text(
                widget.hour,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Spacer(),
          Checkbox(
            value: _isChecked,
            checkColor: Colors.white,
            activeColor: _isChecked ? const Color.fromRGBO(30, 76, 168, 1.0) : null,
            side: BorderSide(
              color: Colors.grey.shade900,
              width: 2,
            ),
            onChanged: (bool? value) {
              setState(() {
                _isChecked = value!;
                widget.saveChecked();
              });
            },
          ),
        ],
      ),
    );
  }
}
