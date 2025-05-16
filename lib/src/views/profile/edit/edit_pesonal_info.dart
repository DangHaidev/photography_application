import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino for iOS icons

class EditPersonalInfoPage extends StatefulWidget {
  const EditPersonalInfoPage({super.key});

  @override
  State<StatefulWidget> createState() => _EditPersonalInfoPageState();
}

class _EditPersonalInfoPageState extends State<EditPersonalInfoPage> {
  int _selectedIndex = 4;
  final TextEditingController _firstNameController = TextEditingController(text: "Thuân");
  final TextEditingController _lastNameController = TextEditingController(text: "Pham");
  final TextEditingController _bioController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.black), // iOS-style back icon
              padding: const EdgeInsets.only(left: 0),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Row(
                children: [
                  Text("Profile", style: TextStyle(color: Colors.grey[400], fontSize: 22)),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                  const Text("Personal Info", style: TextStyle(color: Colors.black, fontSize: 22)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Avatar",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.black,
                    backgroundImage: const AssetImage('assets/images/Thuan.png'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "First Name",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Last Name",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Short Bio",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Text(
                    "0/130",
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 130,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    counterText: "",
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Save profile changes logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Undo changes logic here
                  },
                  child: Text(
                    "Undo",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
