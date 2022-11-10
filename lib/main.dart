import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tdd_widget_integration_test_mocktail/news_change_notifier.dart';
import 'package:flutter_tdd_widget_integration_test_mocktail/news_page.dart';
import 'package:flutter_tdd_widget_integration_test_mocktail/news_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(NewsService()),
        child: const NewsPage(),
      ),
    );
  }
}
