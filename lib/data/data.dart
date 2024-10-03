import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class Task {
  String name;
  String hour;
  bool status;
  DateTime day;

  Task(
      {required this.name, required this.hour, required this.status, required this.day});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'],
      hour: json['hour'],
      status: json['status'],
      day: DateTime.parse(json['day']),
    );
  }

  @override
  String toString() {
    return 'Task{name: $name, hour: $hour, status: $status, day: $day}';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hour': hour,
      'status': status,
      'day': day.toIso8601String(),
    };
  }

  Future<void> createTestTasks() async {
    List<Task> tasks = List.generate(10, (index) {
      return Task(
        name: 'Task ${index + 1}',
        hour: '${(index % 12) + 1}:00 ${index % 2 == 0 ? "AM" : "PM"}',
        // Час чергується між AM і PM
        status: true,
        day: DateTime.now(),
      );
    });

    try {
      // Отримуємо директорію для документів додатка
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory
          .path}/task_data.json'; // Вказуємо шлях до файлу
      final file = File(filePath);

      // Записуємо список завдань у JSON файл
      await file.writeAsString(
          json.encode(tasks.map((task) => task.toJson()).toList()));
      print('Test tasks created and saved to $filePath');
    } catch (e) {
      print("Error creating test tasks: $e");
    }
  }


}
