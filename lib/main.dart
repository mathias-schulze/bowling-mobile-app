import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
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
        length: 3,
        child: MyHomePage(title: 'Bowling'),
      )
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
              Tab(icon: Icon(Icons.calendar_month)),
              Tab(icon: Icon(Icons.people)),
            ],
        ),
      ),
      body: const TabBarView(
          children: [
            ResultTab(),
            DateTab(),
            PlayerTab(),
          ]
      ),
    );
  }
}

class ResultTab extends StatefulWidget {
  const ResultTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResultTabState();
}

class _ResultTabState extends State<ResultTab> {

  final NumberFormat numberFormat = NumberFormat("###.0#", "de_De");

  final _results = <_Result>[
    _Result("Mathias", 200.0),
    _Result("Norbert", 150.0),
    _Result("Fahd", 145.0),
    _Result("Christian", 140.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: _results.length,
          itemBuilder: (context, index) {
            var result = _results[index];
            return ListTile(
              title: Text(result._player + " " + numberFormat.format(result._score)),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => () {},
        tooltip: 'Spieler hinzufügen',
        child: const Icon(Icons.group_add),
      ),
    );
  }
}

class _Result {
  final String _player;
  final double _score;

  _Result(this._player, this._score);
}

class DateTab extends StatefulWidget {
  const DateTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DateTabState();
}

class _DateTabState extends State<DateTab> {

  final DateFormat dateFormat = DateFormat("dd.MM.yyyy");

  final _dates = <_Date>[
    _Date(DateTime.parse("2020-02-04"), "XXL Bowling 117"),
    _Date(DateTime.parse("2020-03-03"), "XXL Bowling 118"),
    _Date(DateTime.parse("2022-05-03"), "XXL Bowling 119"),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: _dates.length,
          itemBuilder: (context, index) {
            var date = _dates[index];
            return ListTile(
              title: Text(dateFormat.format(date._date) + " " + date._desc),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => () {},
        tooltip: 'Termin anlegen',
        child: const Icon(Icons.insert_invitation),
      ),
    );
  }
}

class _Date {
  final DateTime _date;
  final String _desc;

  _Date(this._date, this._desc);
}

class PlayerTab extends StatefulWidget {
  const PlayerTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerTabState();
}

class _PlayerTabState extends State<PlayerTab> {

  final _player = <_Player>[
    _Player("Christian"),
    _Player("Fahd"),
    _Player("Mathias"),
    _Player("Norbert"),
  ];

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: ListView.builder(
        itemCount: _player.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_player[index]._name),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => () {},
        tooltip: 'Spieler anlegen',
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _Player {
  final String _name;

  _Player(this._name);
}
