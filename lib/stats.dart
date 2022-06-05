import 'package:flutter/material.dart';
import 'player.dart';
import 'game.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {

  Map<String?, Player> _allPlayers = {};
  List<Game> _allGames = [];
  int sortColumn = 2;
  bool sortAsc = false;
  List<_PlayerStats> stats = [];

  @override
  void initState() {
    super.initState();
    getAllPlayers().then((value) {
      setState(() => _allPlayers = value);
      getAllGames().then((value) {
        setState(() => _allGames = value);
        stats = getStats();
      });
    });
  }

  List<_PlayerStats> getStats() {

    Map<String, _PlayerStats> stats =
        _allPlayers.map((key, value) => MapEntry(key!, _PlayerStats(value.name)));

    for (var game in _allGames) {
      var playerStats = stats[game.player];
      if (playerStats != null) {
        playerStats.games++;
        playerStats.total += game.score;
        if (game.score > playerStats.max) {
          playerStats.max = game.score;
        }
        playerStats.avg = playerStats.total / playerStats.games;
      }
    }

    var statsSorted = stats.values.toList();
    statsSorted.sort((s1, s2) => s2.max.compareTo(s1.max));

    return statsSorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 45,
          sortColumnIndex: sortColumn,
          sortAscending: sortAsc,
          columns: [
            DataColumn(
              label: const Text(""),
              onSort: (columnIndex, ascending) {
                setState(() {
                  if (sortColumn == columnIndex) {
                    sortAsc = ascending;
                  } else {
                    sortColumn = columnIndex;
                    sortAsc = true;
                  }

                  stats.sort((s1, s2) => sortAsc
                      ? s1.player.compareTo(s2.player)
                      : s2.player.compareTo(s1.player));
                });
              },
            ),
            DataColumn(
              label: const Icon(Icons.functions),
              onSort: (columnIndex, ascending) {
                setState(() {
                  if (sortColumn == columnIndex) {
                    sortAsc = ascending;
                  } else {
                    sortColumn = columnIndex;
                    sortAsc = false;
                  }

                  stats.sort((s1, s2) => sortAsc
                      ? s1.games.compareTo(s2.games)
                      : s2.games.compareTo(s1.games));
                });
              },
            ),
            DataColumn(
              label: const Icon(Icons.vertical_align_top),
              onSort: (columnIndex, ascending) {
                setState(() {
                  if (sortColumn == columnIndex) {
                    sortAsc = ascending;
                  } else {
                    sortColumn = columnIndex;
                    sortAsc = false;
                  }

                  stats.sort((s1, s2) => sortAsc
                      ? s1.max.compareTo(s2.max)
                      : s2.max.compareTo(s1.max));
                });
              },
            ),
            DataColumn(
              label: const Icon(Icons.vertical_align_center),
              onSort: (columnIndex, ascending) {
                setState(() {
                  if (sortColumn == columnIndex) {
                    sortAsc = ascending;
                  } else {
                    sortColumn = columnIndex;
                    sortAsc = false;
                  }

                  stats.sort((s1, s2) => sortAsc
                      ? s1.avg.compareTo(s2.avg)
                      : s2.avg.compareTo(s1.avg));
                });
              },
            ),
          ],
          rows: stats.map((playerStat) =>
              DataRow(cells: [
                DataCell(Text(playerStat.player)),
                DataCell(Align(
                    alignment: Alignment.centerRight,
                    child: Text(playerStat.games.toString()))
                ),
                DataCell(Align(
                    alignment: Alignment.centerRight,
                    child: Text(playerStat.max.toString()))
                ),
                DataCell(Align(
                    alignment: Alignment.centerRight,
                    child: Text(playerStat.avg.toStringAsFixed(1)))
                ),
              ]))
              .toList(),
        ),
      ),
    );
  }
}

class _PlayerStats {
  final String player;
  int games = 0;
  int total = 0;
  int max = 0;
  double avg = 0.0;

  _PlayerStats(this.player);
}