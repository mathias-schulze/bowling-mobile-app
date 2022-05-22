import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'player.dart';

class ResultTab extends StatefulWidget {
  const ResultTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ResultTabState();
}

class _ResultTabState extends State<ResultTab> {

  final NumberFormat numberFormat = NumberFormat("###.0#", "de_De");

  StreamSubscription? _currentEventListener;
  StreamSubscription? _allPlayersListener;
  StreamSubscription? _playersForEventListener;
  StreamSubscription? _gamesListener;

  late String _currentEventKey;
  final Map<String?, Player> _allPlayers = {};
  final Set<String?> _playersForEvent = {};
  final List<_Game> _games = [];

  @override
  void initState() {
    super.initState();
    _readCurrentEventKey();
  }

  void _readCurrentEventKey() {
    _currentEventListener = FirebaseDatabase.instance.ref()
      .child('aktuellerTermin')
      .onValue.listen((event) {
        setState(() => _currentEventKey = event.snapshot.value as String);
        _readAllPlayers();
        _readPlayersForEvent();
        _readGames();
      });
  }

  void _readAllPlayers() {
    _allPlayersListener?.cancel();
    _allPlayersListener = FirebaseDatabase.instance.ref()
      .child('spieler')
      .onValue.listen((event) {
        Map<String?, Player> newPlayers = {};
        for (var dbPlayer in event.snapshot.children) {
          if (_allPlayers.containsKey(dbPlayer.key)) {
            continue;
          }
          var player = Player.fromJson(dbPlayer.value as Map<dynamic, dynamic>);
          newPlayers[dbPlayer.key] = player;
        }
        setState(() => _allPlayers.addAll(newPlayers));
      });
  }

  void _readPlayersForEvent() {
    _playersForEventListener?.cancel();
    _playersForEventListener = FirebaseDatabase.instance.ref()
      .child('termin/$_currentEventKey/spieler')
      .onValue.listen((event) {
        Set<String?> newPlayersForEvent = {};
        for (var dbEventPlayer in event.snapshot.children) {
          newPlayersForEvent.add(dbEventPlayer.key);
        }
        setState(() => _playersForEvent.addAll(newPlayersForEvent));
      });
  }

  void _readGames() {
    _gamesListener?.cancel();
    _games.clear();
    _gamesListener = FirebaseDatabase.instance.ref()
      .child('spiel').orderByChild("timestamp")
      .onValue.listen((event) {
        List<_Game> newGames = [];
        for (var dbGame in event.snapshot.children) {
          var game = _Game.fromJson(dbGame.value as Map<dynamic, dynamic>);
          if (game._event != _currentEventKey) {
            continue;
          }
          newGames.add(game);
        }
        newGames.sort((gameA, gameB) => gameA._timestamp.compareTo(gameB._timestamp));
        setState(() => _games.addAll(newGames));
      });
  }

  @override
  void dispose() {
    _currentEventListener?.cancel();
    _allPlayersListener?.cancel();
    _playersForEventListener?.cancel();
    _gamesListener?.cancel();
    super.dispose();
  }

  List<_Result> getResults() {

    Map<String?, _Result> results = {};

    for (var playerId in _playersForEvent) {
      var player = _allPlayers[playerId];
      if (player != null) {
        results[playerId] = _Result(player.name);
      }
    }

    for (var game in _games) {
      var playerResults = results[game._player];
      if (playerResults != null) {
        var games = playerResults._games;
        games.add(game);
        int sum = games.map((game) => game._score)
            .reduce((value, element) => value + element);
        playerResults._avg = sum / games.length;
      }
    }

    var resultSorted = results.values.toList();
    resultSorted.sort((resultPlayerA, resultPlayerB) {
      int compareAvg = resultPlayerB._avg.compareTo(resultPlayerA._avg);
      if (compareAvg == 0) {
        return resultPlayerA._player.compareTo(resultPlayerB._player);
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
              title: Text(result._player + " / "
                  + result._games.map((game) => game._score)
                      .join(",") + " / "
                  + numberFormat.format(result._avg)),
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
  final List<_Game> _games = [];
  double _avg = 0;

  _Result(this._player);
}

class _Game {

  final int _score;
  final String _event;
  final String _player;
  final int _timestamp;

  _Game(this._score, this._event, this._player, this._timestamp);

  _Game.fromJson(Map<dynamic, dynamic> json)
      : _score = json['ergebnis'] as int,
        _event = json['termin'] as String,
        _player = json['spieler'] as String,
        _timestamp = json['timestamp'] as int;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'ergebnis': _score,
    'termin': _event,
    'spieler': _player,
    'timestamp': _timestamp
  };
}