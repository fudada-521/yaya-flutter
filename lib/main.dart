import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/feeding_screen.dart';
import 'providers/baby_provider.dart';
import 'providers/records_provider.dart';

void main() {
  runApp(const YayaDiaryApp());
}

class YayaDiaryApp extends StatelessWidget {
  const YayaDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BabyProvider()),
        ChangeNotifierProvider(create: (_) => RecordsProvider()),
      ],
      child: MaterialApp(
        title: '丫丫日记 - 婴儿生活记录',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
            primary: Colors.pink,
            secondary: Colors.pinkAccent,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/feeding': (context) => const FeedingScreen(),
          // 预留其他功能页面的路由
          '/sleep': (context) => const Placeholder(),
          '/diaper': (context) => const Placeholder(),
          '/growth': (context) => const Placeholder(),
          '/baby-profile': (context) => const Placeholder(),
        },
      ),
    );
  }
}
