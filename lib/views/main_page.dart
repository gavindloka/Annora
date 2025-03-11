import 'package:annora_survey/views/account_page.dart';
import 'package:annora_survey/views/history_task_page.dart';
import 'package:annora_survey/views/new_task_page.dart';
import 'package:annora_survey/widgets/top_bar.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final String username;
  final String email;
  final String phone;
  final String regional;
  const MainPage({
    super.key,
    required this.username,
    required this.email,
    required this.phone,
    required this.regional,
  });

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
      const NewTaskPage(),
      const HistoryTaskPage(),
      AccountPage(
        username: widget.username,
        email: widget.email,
        phone: widget.phone,
        regional: widget.regional,
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
      appBar: TopBar(username: widget.username),
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
