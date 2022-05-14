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
            final player = _Player.fromJson(json);
            return ListTile(
              title: Text(player._name),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final name = await _showAddPlayerDialog();
          addPlayer(name);
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
        onSubmitted: (_) => _closeAddPlayerDialog(),
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

  void addPlayer(String? name) {

    if (name == null || name.isEmpty) {
      return;
    }

    _playerRef.push().set(_Player(name).toJson());
  }
}

class _Player {

  final String _name;

  _Player(this._name);

  _Player.fromJson(Map<dynamic, dynamic> json)
      : _name = json['name'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'name': _name,
  };
}