import 'package:flutter/material.dart';
import 'package:todo/pages/components/my_button.dart';

class DialogueBox extends StatelessWidget {
  final myController;

  final VoidCallback onSave;
  final VoidCallback onCancel;

  const DialogueBox(
      {super.key,
      required this.myController,
      required this.onCancel,
      required this.onSave});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Container(
          height: 130,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
                controller: myController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Add New Task',
                    hintStyle: const TextStyle(color: Colors.grey)),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyButton(
                    text: 'Save',
                    onPressed: onSave,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  MyButton(
                    text: 'Cancel',
                    onPressed: onCancel,
                  )
                ],
              )
            ],
          )),
    );
  }
}
