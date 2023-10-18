import 'package:flutter/material.dart';
import 'package:gallery/utils/outline_input_border.dart';
import 'package:gallery/utils/colors.dart';
import 'package:gallery/views/bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeTitle extends StatefulWidget {
  const ChangeTitle({super.key, required this.title});

  final String title;

  @override
  State<ChangeTitle> createState() => _ChangeTitleState();
}

class _ChangeTitleState extends State<ChangeTitle> {
  TextEditingController titleTextEditingController = TextEditingController();

  updateTitle() async {
    titleTextEditingController.text = widget.title;
  }

  @override
  void initState() {
    super.initState();
    updateTitle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'Update Title',
              style: TextStyle(
                fontSize: 24,
                color: red,
                fontFamily: 'dotmatrix',
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
              child: TextField(
                controller: titleTextEditingController,
                maxLength: 10,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                  enabledBorder: outlineInputBorder,
                  focusedBorder: outlineInputBorder,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString(
                    'title', titleTextEditingController.text.trim());

                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BottomNavBar()),
                    (route) => false);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.fromLTRB(50, 15, 50, 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Update',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
