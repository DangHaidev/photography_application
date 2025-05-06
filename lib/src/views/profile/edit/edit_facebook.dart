import 'package:flutter/material.dart';
import '../../layout/edit_layout.dart';

class EditFacebookPage extends StatefulWidget {
  const EditFacebookPage({super.key});

  @override
  State<EditFacebookPage> createState() => _EditFacebookPageState();
}

class _EditFacebookPageState extends State<EditFacebookPage> {
  final TextEditingController _facebookController = TextEditingController();
  late String _originalValue;

  @override
  void initState() {
    super.initState();
    _originalValue = "your_facebook_username";
    _facebookController.text = _originalValue;
  }

  void _handleSave() {
    print("Saved: ${_facebookController.text}");
  }

  void _handleUndo() {
    setState(() {
      _facebookController.text = _originalValue;
    });
  }

  @override
  void dispose() {
    _facebookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditInfoLayout(
      title: "Facebook",
      fieldLabel: "Facebook",
      controller: _facebookController,
      onSave: _handleSave,
      onUndo: _handleUndo,
    );
  }
}
