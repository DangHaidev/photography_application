import 'package:flutter/material.dart';
import '../../layout/edit_layout.dart';
class EditEmailPage extends StatefulWidget {
  const EditEmailPage({super.key});

  @override
  State<EditEmailPage> createState() => _EditEmailPageState();
}

class _EditEmailPageState extends State<EditEmailPage> {
  final TextEditingController _emailController =
  TextEditingController(text: "thuan23082004@gmail.com");

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditInfoLayout(
      title: "Email",
      fieldLabel: "Email",
      controller: _emailController,
      onSave: () {
      },
      onUndo: () {
        setState(() {
          _emailController.text = "thuan23082004@gmail.com";
        });
      },
    );
  }
}
