import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mooring/controllers/tasks_controller.dart';

import 'data/moor_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    Get.put(TasksController());
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quick Tasks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Quick Tasks'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TasksController _tasksController = Get.find<TasksController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: _tasksController.tasks.length,
          itemBuilder: (context, index) {
            final task = _tasksController.tasks[index];
            return _buildListItem(task);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildListItem(Task task) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            onPressed: (context) {
              _editTask(task);
            },
            icon: Icons.edit,
            label: 'Modifier',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            onPressed: (context) {
              _tasksController.deleteTask(task);
            },
            icon: Icons.delete,
            label: 'Supprimer',
          ),
        ],
      ),
      child: CheckboxListTile(
          title: Text(task.name),
          subtitle: Text(task.dueDate != null
              ? DateFormat("dd-MM-yyy").format(task.dueDate!)
              : 'No due date'),
          value: task.completed,
          onChanged: (value) {
            _tasksController.updateTask(task.copyWith(completed: value));
          }),
    );
  }

  _addTask() {
    String tName = '';
    DateTime tDueDate = DateTime.now();
    Get.bottomSheet(IntrinsicHeight(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Task name',
                    ),
                    onChanged: (value) {
                      tName = value;
                    },
                  ),
                ),
                _buildDateButton(context, oldDate: tDueDate,
                    onDateChanged: (date) {
                  tDueDate = date;
                }),
              ],
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                _tasksController.addTask(Task(
                    name: tName,
                    completed: false,
                    dueDate: tDueDate,
                    id: DateTime.now().millisecondsSinceEpoch));
                Get.back();
              },
            ),
          ],
        ),
      ),
    ));
  }

  _editTask(Task task) {
    String tName = task.name;
    DateTime tDueDate = task.dueDate ?? DateTime.now();
    Get.bottomSheet(IntrinsicHeight(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: tName,
                    decoration: const InputDecoration(
                      labelText: 'Task name',
                    ),
                    onChanged: (value) {
                      tName = value;
                    },
                  ),
                ),
                _buildDateButton(context, oldDate: tDueDate,
                    onDateChanged: (date) {
                  tDueDate = date;
                }),
              ],
            ),
            ElevatedButton(
              child: const Text('Edit'),
              onPressed: () {
                _tasksController.updateTask(task.copyWith(
                  name: tName,
                  dueDate: tDueDate,
                ));
                Get.back();
              },
            ),
          ],
        ),
      ),
    ));
  }

  IconButton _buildDateButton(BuildContext context,
      {DateTime? oldDate, required Function(DateTime) onDateChanged}) {
    return IconButton(
      icon: const Icon(Icons.calendar_today),
      onPressed: () async {
        DateTime? newTaskDate = await showDatePicker(
          context: context,
          initialDate: oldDate ?? DateTime.now(),
          firstDate: DateTime(2010),
          lastDate: DateTime(2050),
        );
        onDateChanged(newTaskDate ?? DateTime.now());
      },
    );
  }
}
