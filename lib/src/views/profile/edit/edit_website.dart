import 'package:flutter/material.dart';
import '../../layout/edit_layout.dart';

class EditWebsitePage extends StatefulWidget {
  const EditWebsitePage({super.key});

  @override
  State<StatefulWidget> createState() => _EditWebsitePageState();
}

class _EditWebsitePageState extends State<EditWebsitePage> {
  final TextEditingController _websiteController = TextEditingController();
  String _originalValue = '';

  @override
  void initState() {
    super.initState();
    _originalValue = ".com";
    _websiteController.text = _originalValue;
  }

  void _handleSave() {
    final newValue = _websiteController.text;
    print("Đã lưu Paypal: $newValue");
  }

  void _handleUndo() {
    setState(() {
      _websiteController.text = _originalValue;
    });
  }

  @override
  void dispose() {
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditInfoLayout(
      title: "Website",
      fieldLabel: "Website",
      controller: _websiteController,
      onSave: _handleSave,
      onUndo: _handleUndo,
    );
  }
}
