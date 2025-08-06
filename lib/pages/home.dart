import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:todo/data/database.dart';
import 'package:todo/pages/components/dialogue_box.dart';
import 'package:todo/pages/components/todo_tiles.dart';

class HomePage1 extends StatefulWidget {
  const HomePage1({super.key});

  @override
  State<HomePage1> createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1> {
  final myBox = Hive.box('myBox');

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  double _headerFontSize = 32;
  final double minFontSize = 24;
  final double maxFontSize = 36;
  TodoDataBase db = TodoDataBase();

  Set<int> _selectedTasks = {};
  bool _showDoneTasks = true;
  bool _selectionMode = false;

  void _handleScroll() {
    final direction = _scrollController.position.userScrollDirection;
    setState(() {
      if (direction == ScrollDirection.reverse) {
        _headerFontSize = (_headerFontSize - 1).clamp(minFontSize, maxFontSize);
      } else if (direction == ScrollDirection.forward) {
        _headerFontSize = (_headerFontSize + 1).clamp(minFontSize, maxFontSize);
      }
    });
  }

  @override
  void initState() {
    // if this is the first time ever openeing the app, create default data
    if (myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      //data already exist
      db.loadData();
    }
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.todoList[index][1] = !db.todoList[index][1];
    });
    db.updateData();
  }

  void deleteTask(int index) {
    setState(() {
      db.todoList.removeAt(index);
    });
    db.updateData();
  }

  void deleteSelectedTasks() {
    setState(() {
      db.todoList = db.todoList
          .asMap()
          .entries
          .where((e) => !_selectedTasks.contains(e.key))
          .map((e) => e.value)
          .toList();
      _selectedTasks.clear();
      _selectionMode = false;
    });
  }

  void saveNewTask() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task cannot be empty')),
      );
      return;
    }

    setState(() {
      db.todoList.add([_controller.text.trim(), false]);
    });

    _controller.clear();
    Navigator.of(context).pop();
    db.updateData();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) => DialogueBox(
        myController: _controller,
        onSave: saveNewTask,
        onCancel: () {
          _controller.clear();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void toggleSelection(int index) {
    setState(() {
      if (_selectedTasks.contains(index)) {
        _selectedTasks.remove(index);
      } else {
        _selectedTasks.add(index);
      }

      if (_selectedTasks.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List activeTasks =
        db.todoList.where((task) => task[1] == false).toList();
    final List doneTasks =
        db.todoList.where((task) => task[1] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('To‑Do List'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFFF2F2F2),
        //foregroundColor: Color(0xFFF2F2F2),
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.cancel_outlined),
                tooltip: 'Cancel Selection',
                onPressed: () {
                  setState(() {
                    _selectedTasks.clear();
                    _selectionMode = false;
                  });
                },
              )
            : null,
        actions: _selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Selected',
                  onPressed: deleteSelectedTasks,
                ),
              ]
            : null,
      ),
      backgroundColor: Colors.white.withOpacity(0.95),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerLeft,
            child: Text(
              "Tasks",
              style: TextStyle(
                fontSize: _headerFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.only(right: 200),
            child: const Text(
              'To Be Completed',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView(
              controller: _scrollController,
              children: [
                ...List.generate(activeTasks.length, (index) {
                  final task = activeTasks[index];
                  final actualIndex = db.todoList.indexOf(task);
                  final isSelected = _selectedTasks.contains(actualIndex);

                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                        _selectionMode = true;
                        toggleSelection(actualIndex);
                      });
                    },
                    onTap: () {
                      if (_selectionMode) {
                        toggleSelection(actualIndex);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: isSelected ? Colors.blue[100] : null,
                      child: TodoTiles(
                        taskname: task[0],
                        taskCompleted: task[1],
                        onChanged: (value) =>
                            checkBoxChanged(value, actualIndex),
                        deleteFunction: (context) => deleteTask(index),
                      ),
                    ),
                  );
                }),

                // Divider with toggle arrow
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _showDoneTasks
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                      ),
                      onPressed: () {
                        setState(() {
                          _showDoneTasks = !_showDoneTasks;
                        });
                      },
                    ),
                    const Text(
                      "Completed Tasks",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Expanded(child: Divider(thickness: 2)),
                  ],
                ),

                if (_showDoneTasks)
                  ...List.generate(doneTasks.length, (index) {
                    final task = doneTasks[index];
                    final actualIndex = db.todoList.indexOf(task);
                    final isSelected = _selectedTasks.contains(actualIndex);

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _selectionMode = true;
                          toggleSelection(actualIndex);
                        });
                      },
                      onTap: () {
                        if (_selectionMode) {
                          toggleSelection(actualIndex);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        color: isSelected ? Colors.blue[50] : null,
                        child: TodoTiles(
                          taskname: task[0],
                          taskCompleted: task[1],
                          onChanged: (value) =>
                              checkBoxChanged(value, actualIndex),
                          deleteFunction: (context) => deleteTask(index),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
