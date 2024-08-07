import 'package:flutter/material.dart';
import 'package:potato/features/homepage/homepage.dart';
import 'package:potato/features/homepage/none_page.dart';
import 'package:potato/features/resource/resources_page.dart'; // 导入新页面

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const BrowseResourcesPage(), // 新页面
    const NonePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isNonePage = _currentIndex == 2; // 判断是否为公告栏页面

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor:
            isNonePage ? Colors.grey[200] : Colors.grey[200], // 动态背景色
        selectedItemColor:
            isNonePage ? Colors.grey : Theme.of(context).primaryColor,
        unselectedItemColor: isNonePage ? Colors.grey : Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: '资源',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: '公告栏',
          ),
        ],
      ),
    );
  }
}
