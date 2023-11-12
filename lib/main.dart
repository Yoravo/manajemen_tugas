import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      home: TaskManagerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskManagerScreen extends StatefulWidget {
  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  List<Task> tasks = [];
  Task? newTask;
  Task? selectedTask;

  //function load
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  //Function load task
  _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      setState(() {
        tasks = taskList
            .map((task) =>
                Task.fromMap(Map<String, dynamic>.from(json.decode(task))))
            .toList();
      });
    }
  }

  //Function Add Task
  void _addTask(Task newTask) {
    setState(() {
      tasks.add(newTask);
    });

    _saveTasks(); // Panggil _saveTasks setelah menambah tugas
  }

  void _saveTasks() async {
    print("Saving tasks...");
    final prefs = await SharedPreferences.getInstance();
    final taskList = tasks.map((task) => task.toMap()).toList();
    prefs.setStringList(
        'tasks', taskList.map((task) => json.encode(task)).toList());
    print("Tasks saved!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager', textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text('Tidak ada task yang tersedia'),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index].title),
                  subtitle: Text('Waktu: ${tasks[index].formattedDate()}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            selectedTask = tasks[index];
                          });
                          _showEditTaskDialog(selectedTask!);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          _showDeleteConfirmationDialog(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog() {
    DateTime? selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String taskTitle = '';
        return AlertDialog(
          title: Text('Tambah Task Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Tanggal: '),
                  TextButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate!,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate)
                        setState(() {
                          selectedDate = pickedDate;
                        });
                    },
                    child: Text(
                      "${selectedDate!.toLocal()}".split(' ')[0],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Judul Task'),
                onChanged: (text) {
                  setState(() {
                    taskTitle = text;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (taskTitle.isNotEmpty) {
                    setState(() {
                      tasks.add(Task(title: taskTitle, date: selectedDate!));
                      _saveTasks(); // Save tasks after adding a new one
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditTaskDialog(Task task) {
    DateTime? selectedDate = task.date;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String taskTitle = task.title;
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Tanggal: '),
                  TextButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate!,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate)
                        setState(() {
                          selectedDate = pickedDate;
                        });
                    },
                    child: Text(
                      "${selectedDate!.toLocal()}".split(' ')[0],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Judul Task'),
                controller: TextEditingController(text: taskTitle),
                onChanged: (text) {
                  taskTitle = text;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (taskTitle.isNotEmpty) {
                    setState(() {
                      task.title = taskTitle;
                      task.date = selectedDate!;
                      _saveTasks(); // Save tasks after editing
                    });
                    Navigator.of(context).pop();
                    selectedTask = null;
                  }
                },
                child: Text('Simpan Perubahan'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Task?'),
          content: Text('Anda yakin ingin menghapus task ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.removeAt(index);
                  _saveTasks(); // Save tasks after deletion
                });
                Navigator.of(context).pop();
              },
              child: Text('Ya'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }
}

class Task {
  String title;
  DateTime? date;

  Task({required this.title, this.date});

  String formattedDate() {
    return date != null ? '${date!.day}/${date!.month}/${date!.year}' : '-';
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date?.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : null,
    );
  }
}
