import 'package:annora_survey/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';

class HistoryTaskPage extends StatefulWidget {
  const HistoryTaskPage({super.key});

  @override
  State<HistoryTaskPage> createState() => _HistoryTaskPageState();
}

class _HistoryTaskPageState extends State<HistoryTaskPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("History Task Page"),
    );
  }
}