import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/Mysql.dart';

class Database extends StatefulWidget {
  const Database({Key? key}) : super(key: key);

  @override
  State<Database> createState() => _DatabaseState();
}

class _DatabaseState extends State<Database> {
  var db = Mysql();
  List<Map> all = [];
  int _currentSortColumn = 0;
  bool _isSortAsc = true;
  Future? _future;

  Future<List<Map>> _selectMap() async {
    await db.getConnection().then((conn) {
      String sql = 'select id, val, val2, val3, data, time from nodemcu_table';
      conn.query(sql).then((results) {
        all.clear();
        for (var row in results) {
          Map something = {
            'id': row[0],
            'temp': row[1],
            'wilg': row[2],
            'nasl': row[3],
            'data': row[4],
            'czas': row[5],
          };
          all.add(something);
        }
      });
    });
    await Future.delayed(const Duration(seconds: 2));
    return all;
  }

  Future<dynamic> _dataSelect() async {
    final data1 = await _selectMap();
    //await Future.delayed(const Duration(seconds: 1));
    return [data1];
  }

  void updateData() {
    setState(() {
      _future = _dataSelect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _dataSelect(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      Text(' ${snapshot.error}. Try refresh'),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _future;
                        }),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasData) {
                return ListView(
                  children: [
                    _createDataTable(),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _future;
                      }),
                      child: const Text('Refresh'),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    const Text("No data"),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _future;
                      }),
                      child: const Text('Refresh'),
                    ),
                  ],
                );
              }
          }
        });
  }

  DataTable _createDataTable() {
    return DataTable(
      columns: _createColumns(),
      rows: _createRows(),
      border: TableBorder.all(),
      columnSpacing: 10,
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isSortAsc,
    );
  }

  List<DataColumn> _createColumns() {
    return <DataColumn>[
      DataColumn(
          label: const Text('ID'),
          onSort: (columnIndex, _) {
            setState(() {
              _currentSortColumn = columnIndex;
              if (_isSortAsc) {
                all.sort((a, b) => b['id'].compareTo(a['id']));
              } else {
                all.sort((a, b) => a['id'].compareTo(b['id']));
              }
              _isSortAsc = !_isSortAsc;
            });
          }),
      const DataColumn(label: Text('Temp')),
      const DataColumn(label: Text('Wilg')),
      const DataColumn(label: Text('Nasł')),
      const DataColumn(label: Text('Data')),
      const DataColumn(label: Text('Czas')),
    ];
  }

  List<DataRow> _createRows() {
    return all
        .map((measure) => DataRow(cells: [
              DataCell(Text(measure['id'].toString())),
              DataCell(Text(measure['temp'].toString())),
              DataCell(Text(measure['wilg'].toString())),
              DataCell(Text(measure['nasl'].toString())),
              DataCell(Text(
                  DateFormat('yyyy-MM-dd').format(measure['data']).toString())),
              DataCell(Text(_formatTime(measure['czas'])))
            ]))
        .toList();
  }
}

String _formatTime(Duration time) {
  Duration times = time;
  String hours = times.inHours.toString().padLeft(2, '0');
  String minutes = times.inMinutes.remainder(60).toString().padLeft(2, '0');
  String seconds = times.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
