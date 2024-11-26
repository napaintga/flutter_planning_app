
class Task {
  int id;
  String name;
  String hour;
  bool status;
  String day;

  Task(
      {required this.id,required this.name, required this.hour, required this.status, required this.day});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      hour: json['hour'] ?? '',
      status: json['status'] ?? false,
      day: json['day'] ?? '',
    );
  }



  @override
  String toString() {
    return 'Task{id: $id name: $name, hour: $hour, status: $status, day: $day}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hour': hour,
      'status': status,
      'day': day,
    };
  }
}
