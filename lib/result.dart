import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:select_dialog/select_dialog.dart';
import 'player.dart';
import 'game.dart';

class ResultTab extends StatefulWidget {
  const ResultTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResultTabState();
}

class _ResultTabState extends State<ResultTab> {

  final NumberFormat numberFormat = NumberFormat("###.0#", "de_De");

  StreamSubscription? _currentEventListener;
  late DatabaseReference _playersForEventRef;
  StreamSubscription? _playersForEventListener;
  late DatabaseReference _gamesRef;
  StreamSubscription? _gamesListener;

  late String _currentEventKey;
  Map<String?, Player> _allPlayers = {};
  final Set<String?> _playersForEvent = {};
  final List<Game> _games = [];

  late TextEditingController _gameScoreController;

  @override
  void initState() {
    super.initState();
    _readCurrentEventKey();
    _gameScoreController = TextEditingController();
  }

  void _readCurrentEventKey() {
    _currentEventListener = FirebaseDatabase.instance.ref()
      .child('aktuellerTermin')
      .onValue.listen((event) {
        setState(() => _currentEventKey = event.snapshot.value as String);
        getAllPlayers().then((value) => setState(() => _allPlayers = value));
        _readPlayersForEvent();
        _readGames();
      });
  }

  void _readPlayersForEvent() {
    _playersForEventListener?.cancel();
    _playersForEventRef = FirebaseDatabase.instance.ref()
        .child('termin/$_currentEventKey/spieler');
    _playersForEventListener = _playersForEventRef.onChildAdded.listen((event) {
        setState(() => _playersForEvent.add(event.snapshot.key));
    });
  }

  void _readGames() {
    _gamesListener?.cancel();
    _games.clear();
    _gamesRef = FirebaseDatabase.instance.ref().child('spiel');
    _gamesListener = _gamesRef.orderByChild("timestamp")
      .onChildAdded.listen((event) {
        var game = Game.fromJson(event.snapshot.value as Map<dynamic, dynamic>);
        if (game.event == _currentEventKey) {
          setState(() => _games.add(game));
        }
      });
  }

  @override
  void dispose() {
    _currentEventListener?.cancel();
    _playersForEventListener?.cancel();
    _gamesListener?.cancel();
    super.dispose();
  }

  List<_Result> getResults() {

    Map<String?, _Result> results = {};

    for (var playerKey in _playersForEvent) {
      var player = _allPlayers[playerKey];
      if (player != null) {
        results[playerKey] = _Result(playerKey!, player.name);
      }
    }

    for (var game in _games) {
      var playerResults = results[game.player];
      if (playerResults != null) {
        var games = playerResults._games;
        games.add(game);
        int sum = games.map((game) => game.score)
            .reduce((value, element) => value + element);
        playerResults._avg = sum / games.length;
      }
    }

    var resultSorted = results.values.toList();
    resultSorted.sort((resultPlayerA, resultPlayerB) {
      int compareAvg = resultPlayerB._avg.compareTo(resultPlayerA._avg);
      if (compareAvg == 0) {
        return resultPlayerA._playerName.compareTo(resultPlayerB._playerName);
      }
      return compareAvg;
    });

    return resultSorted;
  }

  @override
  Widget build(BuildContext context) {

    var results = getResults();

    return Scaffold(
      body: ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            var result = results[index];
            return ListTile(
              title: Text(result._playerName + " / "
                  + result._games.map((game) => game.score)
                      .join(",") + " / "
                  + numberFormat.format(result._avg)),
              onTap: () async {
                final score = await _showAddGameDialog();
                if (score != null && score.isNotEmpty) {
                  _addGame(result._playerKey, int.parse(score));
                }
              },
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlayersToEventDialog(context),
        tooltip: 'Spieler hinzuf??gen',
        child: const Icon(Icons.group_add),
      ),
    );
  }

  Future<String?> _showAddGameDialog() => showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Ergebnis erfassen"),
      content: TextField(
        autofocus: true,
        decoration: const InputDecoration(labelText: "Ergebnis"),
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          TextInputFormatter.withFunction((oldValue, newValue) =>
            (newValue.text.isEmpty ? newValue
            : (int.parse(newValue.text) > 300) ? oldValue : newValue)
          ),
        ],
        controller: _gameScoreController,
        onSubmitted: (_) => _closeAddGameDialog,
      ),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: _closeAddGameDialog,
        )
      ],
    ),
  );

  void _closeAddGameDialog() {
    Navigator.of(context).pop(_gameScoreController.text);
    _gameScoreController.clear();
  }

  void _addGame(String playerKey, int score) {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    _gamesRef.push().set(
        Game(score, _currentEventKey, playerKey, timestamp).toJson());
  }

  Future _showAddPlayersToEventDialog(context) {

    List<Player> players = _allPlayers.values
        .where((player) => !_playersForEvent.contains(player.key))
        .toList();
    players.sort((p1, p2) => p1.name.compareTo(p2.name));

    return SelectDialog.showModal<Player>(
      context,
      label: "Spieler ausw??hlen",
      showSearchBox: false,
      multipleSelectedValues: [],
      items: players,
      itemBuilder: (context, item, isSelected) {
        return ListTile(
          trailing: isSelected ? const Icon(Icons.check) : null,
          title: Text(item.name),
          selected: isSelected,
        );
      },
      onMultipleItemsChange: (List<Player> selectedPlayers) {
        _addPlayersToEvent(selectedPlayers);
      },
      okButtonBuilder: (context, onPressed) {
        return Align(
          alignment: Alignment.bottomRight,
          child: TextButton(
            child: const Text("Hinzuf??gen"),
            onPressed: onPressed,
          ),
        );
      },
    );
  }

  void _addPlayersToEvent(List<Player> players) {
    for (var player in players) {
      _playersForEventRef.child(player.key!).set(true);
    }
  }
}

class _Result {
  final String _playerKey;
  final String _playerName;
  final List<Game> _games = [];
  double _avg = 0;

  _Result(this._playerKey, this._playerName);
}
