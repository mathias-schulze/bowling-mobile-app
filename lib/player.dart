import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class PlayerTab extends StatefulWidget {
  const PlayerTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerTabState();
}

class _PlayerTabState extends State<PlayerTab> {

  late Query _playerQuery;
  late DatabaseReference _playerRef;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _playerRef = FirebaseDatabase.instance.ref().child('spieler');
    _playerQuery = _playerRef.orderByChild("name");
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: _playerQuery,
          itemBuilder: (context, snapshot, animation, index) {
            final json = snapshot.value as Map<dynamic, dynamic>;
            final player = Player.fromJson(snapshot.key, json);
            return ListTile(
              title: Text(player.name),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final name = await _showAddPlayerDialog();
          _addPlayer(name);
        },
        tooltip: 'Spieler anlegen',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Future<String?> _showAddPlayerDialog() => showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Spieler hinzufügen"),
      content: TextField(
        autofocus: true,
        decoration: const InputDecoration(label: Text("Name")),
        controller: _controller,
        onSubmitted: (_) => _closeAddPlayerDialog,
      ),
      actions: [
        TextButton(
          child: const Text("Hinzufügen"),
          onPressed: _closeAddPlayerDialog,
        )
      ],
    ),
  );

  void _closeAddPlayerDialog() {
    Navigator.of(context).pop(_controller.text);
    _controller.clear();
  }

  void _addPlayer(String? name) {

    if (name == null || name.isEmpty) {
      return;
    }

    _playerRef.push().set(Player(name).toJson());
  }
}

Future<Map<String, Player>> getAllPlayers() async {

  var playerSnapshot = await FirebaseDatabase.instance.ref().child('spieler').get();

  Map<String, Player> players = {};
  for (var dbPlayer in playerSnapshot.children) {
    var player = Player.fromJson(
        dbPlayer.key, dbPlayer.value as Map<dynamic, dynamic>);
    players[player.key!] = player;
  }

  return players;
}

class Player {

  String? key;
  final String name;

  Player(this.name);

  Player.fromJson(this.key, Map<dynamic, dynamic> json)
      : name = json['name'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'name': name,
  };
}
