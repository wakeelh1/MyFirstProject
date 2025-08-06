import 'package:hive/hive.dart';

class TodoDataBase {
  List todoList = [];

  final myBox = Hive.box('myBox');

  // run this when user is opening the app first time ever
  void createInitialData() {
    todoList = [
      ["Code an App", false],
      ["Do exercise", false],
      ["Touch grass", false],
    ];
  }

  //Load the data from database
  void loadData() {
    todoList = myBox.get("TODOLIST");
  }

  //Update database
  void updateData() {
    myBox.put("TODOLIST", todoList);
  }
}
