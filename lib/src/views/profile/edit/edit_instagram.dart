import 'package:flutter/material.dart';
import '../../layout/edit_layout.dart';

class EditInstagramPage extends StatefulWidget {
  const EditInstagramPage({super.key});

  @override
  State<EditInstagramPage> createState() => _EditInstagramPageState();
}

class _EditInstagramPageState extends State<EditInstagramPage> {
  final TextEditingController _instagramController = TextEditingController();
  late String _originalValue;

  @override
  void initState() {
    super.initState();
    _originalValue = "your_instagram_username";
    _instagramController.text = _originalValue;
  }

  void _handleSave() {
    print("Saved: ${_instagramController.text}");
  }

  void _handleUndo() {
    setState(() {
      _instagramController.text = _originalValue;
    });
  }

  @override
  void dispose() {
    _instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditInfoLayout(
      title: "Instagram",
      fieldLabel: "Instagram",
      controller: _instagramController,
      onSave: _handleSave,
      onUndo: _handleUndo,
    );
  }
}
