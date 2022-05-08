import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

final FirebaseDatabase database = FirebaseDatabase.instance;
final DateFormat dbDateFormat = DateFormat("yyyy-MM-dd");

class PlayDate {

  final DateTime date;
  final String description;

  PlayDate(this.date, this.description);

  PlayDate.fromJson(Map<dynamic, dynamic> json)
      : date =  DateTime.parse(json['datum'] as String),
        description = json['beschreibung'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'datum': dbDateFormat.format(date),
    'beschreibung': description,
  };
}

class PlayDateDao {

  final Query _dateRef = database.ref().child('termin').orderByChild("datum");

  Query getDateQuery() {
    return _dateRef;
  }
}

class Player {

  final String name;

  Player(this.name);

  Player.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'name': name,
  };
}

class PlayerDao {

  final Query _playerRef = database.ref().child('spieler').orderByChild("name");

  Query getPlayerQuery() {
    return _playerRef;
  }
}