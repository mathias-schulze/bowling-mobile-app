import 'package:firebase_database/firebase_database.dart';

Future<List<Game>> getAllGames() async {

  var gameSnapshot = await FirebaseDatabase.instance.ref().child('spiel').get();
  return gameSnapshot.children
      .map((game) => Game.fromJson(game.value as Map<dynamic, dynamic>))
      .toList();
}

class Game {

  final int score;
  final String event;
  final String player;
  final int timestamp;

  Game(this.score, this.event, this.player, this.timestamp);

  Game.fromJson(Map<dynamic, dynamic> json)
      : score = json['ergebnis'] as int,
        event = json['termin'] as String,
        player = json['spieler'] as String,
        timestamp = json['timestamp'] as int;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'ergebnis': score,
    'termin': event,
    'spieler': player,
    'timestamp': timestamp
  };
}