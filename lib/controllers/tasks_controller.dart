import 'dart:developer';

import 'package:get/get.dart';

import '../data/drift_database.dart';

class TasksController extends GetxController {
  final db = AppDatabase();
  var tasks = <Task>[].obs;

  updateTask(Task task) async {
    await db.updateTask(task);
  }

  deleteTask(Task task) async {
    await db.deleteTask(task);
  }

  addTask(Task task) async {
    await db.insertTask(task);
  }

  @override
  onInit() async {
    tasks.value = await db.getAllTasks();
    db.watchAllTasks().listen((event) {
      tasks.value = event;
      // log(tasks.value.toString());
    });
    super.onInit();
  }
}
