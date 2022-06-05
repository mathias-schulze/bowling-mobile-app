import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'result.dart';
import 'stats.dart';
import 'event.dart';
import 'player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bowling',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DefaultTabController(
        length: 4,
        child: MyHomePage(title: 'Bowling'),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de', ''),
      ],
      locale: const Locale('de'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.format_list_numbered)),
              Tab(icon: Icon(Icons.bar_chart)),
              Tab(icon: Icon(Icons.calendar_month)),
              Tab(icon: Icon(Icons.people)),
            ],
        ),
      ),
      body: const TabBarView(
          children: [
            ResultTab(),
            StatsTab(),
            EventTab(),
            PlayerTab(),
          ]
      ),
    );
  }
}
