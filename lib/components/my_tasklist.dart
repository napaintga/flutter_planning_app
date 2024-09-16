


import 'package:flutter/material.dart';

class TaskListCard extends StatefulWidget {
  const TaskListCard({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  State<TaskListCard> createState() => _TaskListCardState();
}

class _TaskListCardState extends State<TaskListCard> {


  bool _isChecked = false;
  bool _isTask = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 90,
      padding: const EdgeInsets.all( 13),
      margin: const EdgeInsets.only(bottom: 13,left: 5,right: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade600,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(_isTask ? Icons.checklist_outlined : Icons.call_outlined),
          const SizedBox(width: 10,),


          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Завдання",
                style: TextStyle(
                  decoration: _isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                ),),
              const Text("година",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Spacer(),
          Checkbox(value: _isChecked,
            checkColor:Colors.white ,
            activeColor: _isChecked ? const Color.fromRGBO(30, 76, 168, 1.0) : null,
            side: BorderSide(
              color:Colors.grey.shade900 ,
              width: 2,
            ),
            onChanged:(bool? value){
              setState((){
                _isChecked = value!;

              });

            },
          ),
        ],
      ),
    );
  }
}
