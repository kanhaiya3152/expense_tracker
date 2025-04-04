import 'package:expense_tracker/screen/expense_screen.dart';
import 'package:expense_tracker/screen/summary_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    // final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor:  Color.fromARGB(255, 141, 127, 127),
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(255, 105, 101, 101),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home_rounded),
            icon: Icon(Icons.home_outlined),
            label: 'Expenses',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.summarize_sharp),
            icon: Icon(Icons.summarize_outlined),
            label: 'Summary',
          ),
        ],
      ),
      body: <Widget>[
         ExpenseScreen(),
         SummaryScreen(),
      ][currentPageIndex],
    );
  }
}
