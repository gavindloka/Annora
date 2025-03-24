import 'package:annora_survey/models/user.dart';
import 'package:annora_survey/views/account_page.dart';
import 'package:annora_survey/views/history_page.dart';
import 'package:annora_survey/views/new_task_page.dart';
import 'package:annora_survey/widgets/top_bar.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final User user;
  const MainPage({super.key, required this.user});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      NewTaskPage(user:widget.user),
      HistoryPage(user:widget.user ),
      AccountPage(
        user:widget.user
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(username: widget.user.name, email: widget.user.email),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'New Task'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Account'),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
