import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

final FirebaseDatabase database = FirebaseDatabase.instance;
final DateFormat dbDateFormat = DateFormat("yyyy-MM-dd");

class Event {

  final DateTime date;
  final String description;

  Event(this.date, this.description);

  Event.fromJson(Map<dynamic, dynamic> json)
      : date =  DateTime.parse(json['datum'] as String),
        description = json['beschreibung'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'datum': dbDateFormat.format(date),
    'beschreibung': description,
  };
}

class EventDao {

  final Query _eventRef = database.ref().child('termin').orderByChild("datum");

  Query getEventQuery() {
    return _eventRef;
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