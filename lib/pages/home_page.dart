import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../components/bottom_appbar.dart';
import '../components/my_tasklist.dart';
import '../data/data.dart';
Future<List<Task>> loadTasks() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/task_data.json';
    final file = File(filePath);

    if (await file.exists()) {
      final String response = await file.readAsString();
      final List<dynamic> data = json.decode(response);


      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      print('File not found: $filePath');

      await createTestTasks();
      return await loadTasks();
    }
  } catch (e) {
    print("Error loading tasks: $e");
    return [];
  }
}

Future<void> saveTasks(List<Task> tasks) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/task_data.json';
    final file = File(filePath);
    final jsonData = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await file.writeAsString(jsonData);
    print("Tasks saved successfully at $filePath");
  } catch (e) {
    print("Error saving tasks: $e");
  }
}

Future<void> createTestTasks() async {
  List<Task> testTasks = [];
  DateTime taskDay = DateTime.now();

  for (int i = 1; i <= 10; i++) {
    String taskName = 'Test Task $i';
    String formattedTime = '${(8 + i) % 24}:00';

    Task newTask = Task(
      name: taskName,
      hour: formattedTime,
      status: false,
      day: taskDay,
    );

    testTasks.add(newTask);
  }

  await saveTasks(testTasks);
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String formattedTime = '';

  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks().then((loadedTasks) {
      setState(() {
        tasks = loadedTasks;
      });
      print("Loaded Tasks:");
      for (var task in loadedTasks) {
        print(task);
      }
    });
  }

  dynamic add_task(DateTime day) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    labelText: 'Enter task name',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Select Time: '),
                    TextButton(
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _selectedTime = pickedTime;
                            formattedTime = _selectedTime.format(context);
                          });
                        }
                      },
                      child: Text(formattedTime.isEmpty
                          ? 'Pick Time'
                          : 'Time: $formattedTime'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_taskController.text.isNotEmpty &&
                      formattedTime.isNotEmpty) {
                    tasks.add(Task(
                      name: _taskController.text,
                      hour: formattedTime,
                      status: false,
                      day: day,
                    ));
                  }
                });
                _taskController.clear();
                saveTasks(tasks);

                formattedTime = '';
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayName = DateFormat('MMMM, yyyy').format(_selectedDay);

    final showTasks = tasks
        .where((task) => isSameDay(task.day, _selectedDay))
        .toList()
      ..sort((a, b) {
        // Convert to 24-hour format
        final aParts = a.hour.split(':');
        final aHour = int.parse(aParts[0]) % 12 + (a.hour.contains('PM') ? 12 : 0);
        final aMinute = int.parse(aParts[1].split(' ')[0]); // Remove AM/PM before parsing

        final bParts = b.hour.split(':');
        final bHour = int.parse(bParts[0]) % 12 + (b.hour.contains('PM') ? 12 : 0);
        final bMinute = int.parse(bParts[1].split(' ')[0]); // Remove AM/PM before parsing

        final aTime = TimeOfDay(hour: aHour, minute: aMinute);
        final bTime = TimeOfDay(hour: bHour, minute: bMinute);

        return aTime.hour == bTime.hour
            ? aTime.minute.compareTo(bTime.minute)
            : aTime.hour.compareTo(bTime.hour);
      });


    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Container(
              padding: const EdgeInsets.only(top: 12),
              alignment: Alignment.center,
              child: Text(
                dayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromRGBO(22, 71, 147, 1.0),
                  fontSize: 25,
                ),
              ),
            ),
            backgroundColor: const Color.fromRGBO(219, 226, 252, 1.0),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: TableCalendar(
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekendStyle:
                  TextStyle(color: Color.fromRGBO(30, 76, 168, 1.0)),
                  weekdayStyle:
                  TextStyle(color: Color.fromRGBO(30, 76, 168, 1.0)),
                ),
                calendarStyle: const CalendarStyle(
                  todayTextStyle: TextStyle(
                    color: Color.fromRGBO(30, 76, 168, 1.0),
                    fontWeight: FontWeight.bold,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color.fromRGBO(136, 13, 13, 0),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle:
                  TextStyle(color: Color.fromRGBO(30, 76, 168, 1.0)),
                  selectedDecoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1.0),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle:
                  TextStyle(color: Color.fromRGBO(30, 76, 168, 1.0)),
                  weekendTextStyle:
                  TextStyle(color: Color.fromRGBO(30, 76, 168, 1.0)),
                ),
                headerVisible: false,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.week,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedDay = focusedDay;
                  });
                },
                availableGestures: AvailableGestures.horizontalSwipe,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (showTasks.isNotEmpty) {
                  final task = showTasks[index];

                  return Dismissible(
                    key: Key(task.name), // Ключ для ідентифікації елемента
                    direction: DismissDirection.endToStart, // Свайп вправо
                    onDismissed: (direction) {
                      // Видалення задачі з показаного списку
                      setState(() {
                        showTasks.removeAt(index);
                        tasks.remove(task); // Також видаляємо із загального списку
                        saveTasks(tasks); // Зберігаємо зміни
                      });

                    },
                    background: Container(
                      color: const Color.fromRGBO(
                          200, 71, 71, 0.8941176470588236), // Колір фону під час свайпу
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white), // Іконка для видалення
                    ),
                    child: TaskListCard(
                      theme: theme,
                      name: task.name,
                      hour: task.hour,
                      isChecked: task.status,
                      saveChecked: () {
                        // Оновлюємо статус задачі
                        setState(() {
                          task.status = !task.status; // Інвертуємо статус
                        });
                        // Зберігаємо зміни
                        saveTasks(tasks); // Зберігаємо всі задачі
                      },
                    ),
                  );
                } else {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Center(
                        child: Text(
                          'Немає завдань',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
              childCount: showTasks.isNotEmpty ? showTasks.length : 1,
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        elevation: 14.0,
        onPressed: () => add_task(_selectedDay),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: MyBottomAppBar(),
    );
  }
}
