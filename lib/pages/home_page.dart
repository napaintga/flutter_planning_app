import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';
import '../components/bottom_appbar.dart';
import '../components/my_tasklist.dart';
import '../constants.dart';
import '../data/data.dart';
import 'package:http/http.dart' as http;
import '../service/contract_service.dart';






class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String formattedTime = '';
  List<Task> tasks = [];

  Future<EthPrivateKey> _generateEthereumCredentials() async {
    final rpcUrl = Constants.RPC_URL;
    final ethClient = Web3Client(rpcUrl, http.Client());
    final credentials = await ethClient.credentialsFromPrivateKey(Constants.PRIVATE_KEY);
    return credentials;
  }

  Future<bool> _addTask(String name, String hour, String day) async {
    final contractService = ref.read(ContractService.provider);
    try {
      await contractService.addTask(name, hour, day);
      return true;
    } catch (e) {
      print("Error adding task: $e");
      return false;
    }
  }

  Future<List<Task>> loadTasks() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/user_tasks.json';
      final file = File(filePath);

      if (await file.exists()) {
        final String response = await file.readAsString();
        final List<dynamic> data = json.decode(response);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        print('File not found: $filePath');
        return [];
      }
    } catch (e) {
      print("Error loading tasks: $e");
      return [];
    }
  }

  Future<void> _editTask(Task task) async {
    _taskController.text = task.name;
    formattedTime = task.hour;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
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
                          initialTime: _selectedTime,
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _selectedTime = pickedTime;
                            formattedTime = _selectedTime.format(context);
                          });
                        }
                      },
                      child: Text(
                        formattedTime.isEmpty ? 'Pick Time' : '$formattedTime',
                      ),
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
              child: const Text('Canfcel'),
            ),
            TextButton(
              onPressed: () async {
                if (_taskController.text.isNotEmpty && formattedTime.isNotEmpty) {
                  await _updateTask( task.id,  _taskController.text,  formattedTime,   task.day);
                  await _updateTask( task.id,  _taskController.text,  formattedTime,   task.day);
                  await _refreshTasks();
                }
                _refreshTasks();
                _taskController.clear();
                formattedTime = '';
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }




  Future<void> _sendMessage(Task task) async {
    TextEditingController _keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Надіслати Повідомлення'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _keyController,
                  decoration: const InputDecoration(
                    labelText: 'Введіть приватний ключ',
                  ),
                  obscureText: false,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Скасуватиі'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final isSend = await _assignTask(task.id, _keyController.text);
                  if (isSend ) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:const Text("Sent successfully."),
                        behavior: SnackBarBehavior.fixed,
                        backgroundColor: const Color.fromRGBO(
                            3, 92, 10, 1.0),
                      ),
                    );
                    Navigator.of(context).pop();
                    await _refreshTasks();


                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:const Text("User not found."),
                      behavior: SnackBarBehavior.fixed,
                      backgroundColor: const Color.fromRGBO(
                          136, 13, 13, 1.0),
                    ),
                  );
                }
              },
              child: const Text('Надіслати'),
            ),
          ],
        );
      },
    );
  }





  void _showCustomDialog(BuildContext context, int index,Task task ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Color.fromRGBO(195, 40, 34, 1.0),
                            size: 32,
                          ),
                          onPressed: () async {
                            await _deleteTask(index);
                            await _refreshTasks();
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Видалити',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.message,
                            color: Color.fromRGBO(13, 41, 175, 1.0),
                            size: 32,

                          ),
                          onPressed: () async {
                            await _sendMessage(task);
                            await _refreshTasks();

                          },
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Надіслатки',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.check_sharp,
                            color: Color.fromRGBO(48, 250, 107, 1.0),
                            size: 32,

                          ),
                          onPressed: () async {
                            await _updateTaskStatus(task.id, true);
                            await _updateTaskStatus(task.id, true);

                            setState(() {
                              _updateTaskStatus(task.id, true);
                              print(tasks);

                            });
                            _refreshTasks();
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Викоsнано',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(156, 184, 234, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _editTask(task);
                    _refreshTasks();
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Color.fromRGBO(156, 184, 234, 1.0),
                  ),
                  label: Text(
                    "Редагувати завдання",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Future<bool> _assignTask(int taskId, String recipientAddress) async {
    final contractService = ref.read(ContractService.provider);

    try {
      await contractService.assignTask(taskId, recipientAddress);
      return true;
    } catch (e) {
      print("Error sending : $e");
      throw Exception("Sending failed: $e");
    }
  }

  Future<void> _updateTaskStatus(int taskId, bool status) async {
    final contractService = ref.read(ContractService.provider);
    try {
      await contractService.updateTaskStatus(taskId, status);
      print("Task status updated successfully!");
    } catch (e) {
      print("Error updating task: $e");
    }
  }

  Future<void> _updateTask(int taskId, String newName, String newHour, String newDay) async {
    final contractService = ref.read(ContractService.provider);
    try {
      await contractService.editTask(taskId, newName,newHour,newDay);
      print("Task  updated successfully!");
    } catch (e) {
      print("Error updating task all: $e");
    }
  }

  Future<void> _deleteTask(int taskId) async {
    final contractService = ref.read(ContractService.provider);
    try {
      await contractService.deleteTask(taskId);
      print("Task deleted successfully!");
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  Future<void> _getUserTasks() async {
    final contractService = ref.read(ContractService.provider);
    final credentials = await _generateEthereumCredentials();
    final address = credentials.address;

    try {
      await contractService.fetchTasks(address);
      final loadedTasks = await loadTasks();
      setState(() {
        tasks = loadedTasks;
      });
      print("Tasks updated: $tasks");
    } catch (e) {
      print("Error fetching user tasks: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    try {
      tasks.clear();
      await _getUserTasks();
    } catch (e) {
      print("Error refreshing tasks: $e");
    }
  }

  int formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    String formattedDate = '$day$month$year';
    return int.parse(formattedDate);
  }

  dynamic addTask(DateTime day) {
    _taskController.text = '';
    formattedTime = '';
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
                      child: Text(
                        formattedTime.isEmpty ? 'Pick Time' : 'Time: $formattedTime',
                      ),
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
              onPressed: () async {
                if (_taskController.text.isNotEmpty && formattedTime.isNotEmpty) {
                  await _addTask(
                    _taskController.text,
                    formattedTime,
                    formatDate(day).toString(),
                  );
                  await _refreshTasks();
                }
                _taskController.clear();
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

    List<Task> showTasks = tasks
        .where((task) => int.parse(task.day) == formatDate(_selectedDay))
        .toList()
      ..sort((a, b) {
        final aParts = a.hour.split(':');
        final bParts = b.hour.split(':');
        final aHour = int.tryParse(aParts[0]) ?? 0;
        final aMinute = int.tryParse(aParts[1].split(' ')[0]) ?? 0;

        final bHour = int.tryParse(bParts[0]) ?? 0;
        final bMinute = int.tryParse(bParts[1].split(' ')[0]) ?? 0;
        final aTime = TimeOfDay(hour: aHour % 12 + (a.hour.contains('PM') ? 12 : 0), minute: aMinute);
        final bTime = TimeOfDay(hour: bHour % 12 + (b.hour.contains('PM') ? 12 : 0), minute: bMinute);
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
                  weekendStyle: TextStyle(color: Color.fromRGBO(30, 76, 168, 1.0)),
                  weekdayStyle: TextStyle(color: Color.fromRGBO(30, 76, 168, 1.0)),
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
                  selectedTextStyle: TextStyle(color: Color.fromRGBO(30, 76, 168, 1.0)),
                  selectedDecoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1.0),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Color.fromRGBO(30, 76, 168, 1.0)),
                  weekendTextStyle: TextStyle(color: Color.fromRGBO(30, 76, 168, 1.0)),
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
                    key: Key(task.id.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        tasks.removeWhere((t) => t.id == task.id);
                        showTasks = tasks.where((t) => int.parse(t.day) == formatDate(_selectedDay)).toList();
                      });

                      _deleteTask(task.id);
                    },
                    background: Container(
                      color: const Color.fromRGBO(200, 71, 71, 0.8941176470588236),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: TaskListCard(
                      theme: theme,
                      name: task.name,
                      hour: task.hour,
                      isChecked: task.status,
                      saveChecked: () {
                        setState(() {
                          task.status = !task.status;
                          _updateTaskStatus(task.id, task.status);
                          print(tasks);

                        });},
                        CustomDialog: (BuildContext context) {
                  _showCustomDialog(context,task.id,task);
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
        onPressed: () =>  addTask(_selectedDay),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: MyBottomAppBar(onPressed: _refreshTasks),
    );
  }
}
