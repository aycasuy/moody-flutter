import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untitled8/MainScreens/spalsh_screens.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('tr_TR', null);

  runApp(const MoodyApp());
}

class MoodyApp extends StatelessWidget {

  const MoodyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moody',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
