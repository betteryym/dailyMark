import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/trend_page.dart';
import 'pages/view_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 这个组件是应用程序的根组件。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Mark',
      theme: ThemeData(
        // 这是应用程序的主题配置。
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

// 主页面，包含底部导航栏
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // 当前选中的 tab 索引

  // 四个页面的列表
  final List<Widget> _pages = [
    const HomePage(),
    const TrendPage(),
    const ViewPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // 显示当前选中的页面
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 固定类型，确保四个 tab 都能显示
        currentIndex: _currentIndex, // 当前选中的索引
        onTap: (index) {
          // 当点击底部导航栏时，更新当前索引
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: '趋势',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '查看',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
