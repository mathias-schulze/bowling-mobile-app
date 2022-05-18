import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

final DateFormat uiDateFormat = DateFormat("dd.MM.yyyy");
final DateFormat dbDateFormat = DateFormat("yyyy-MM-dd");

class EventTab extends StatefulWidget {
  const EventTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EventTabState();
}

class _EventTabState extends State<EventTab> {

  late DatabaseReference _eventRef;
  late Query _eventQuery;
  late DatabaseReference _currentEventRef;
  late TextEditingController _descriptionController;
  late DateRangePickerController _dateController;

  @override
  void initState() {
    super.initState();
    _eventRef = FirebaseDatabase.instance.ref().child('termin');
    _eventQuery = _eventRef.orderByChild("datum");
    _currentEventRef = FirebaseDatabase.instance.ref().child('aktuellerTermin');
    _descriptionController = TextEditingController();
    _dateController = DateRangePickerController();
    _dateController.displayDate = _dateController.selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: _eventQuery,
          itemBuilder: (context, snapshot, animation, index) {
            final json = snapshot.value as Map<dynamic, dynamic>;
            final event = _Event.fromJson(json);
            return ListTile(
              title: Text(uiDateFormat.format(event._date) + " " + event._description),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final event = await _showAddEventDialog();
          _addEvent(event);
        },
        tooltip: 'Termin anlegen',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<_Event?> _showAddEventDialog() => showDialog<_Event>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Termin hinzufügen"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(label: Text("Beschreibung")),
            controller: _descriptionController,
          ),
          const SizedBox(height: 10.0,),
          SizedBox(
            width: 240.0,
            height: 240.0,
            child: SfDateRangePicker(
              view: DateRangePickerView.month,
              controller: _dateController,
              monthViewSettings: const DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
            ),
          )
        ]
      ),
      actions: [
        TextButton(
          child: const Text("Hinzufügen"),
          onPressed: _closeAddEventDialog,
        )
      ],
    ),
  );

  void _closeAddEventDialog() {
    var selectedDate = _dateController.selectedDate ?? DateTime.now();
    Navigator.of(context).pop(_Event(_descriptionController.text, selectedDate));
    _descriptionController.clear();
  }

  void _addEvent(_Event? event) {

    if (event == null || event._description.isEmpty) {
      return;
    }

    var newEventRef = _eventRef.push();
    newEventRef.set(event.toJson());
    _currentEventRef.set(newEventRef.key);
  }
}

class _Event {

  final String _description;
  final DateTime _date;

  _Event(this._description, this._date);

  _Event.fromJson(Map<dynamic, dynamic> json)
      : _description = json['beschreibung'] as String,
        _date =  DateTime.parse(json['datum'] as String);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'beschreibung': _description,
    'datum': dbDateFormat.format(_date),
  };
}
