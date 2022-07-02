import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Mysql.dart';

class Database extends StatefulWidget {
  const Database({Key? key}) : super(key: key);

  @override
  State<Database> createState() => _DatabaseState();
}

class _DatabaseState extends State<Database> {
  var db = Mysql();
  List<dynamic> temp = [];
  List<dynamic> sunny = [];
  List<dynamic> wet = [];
  List<dynamic> data = [];
  List<dynamic> time = [];
  List<Map> all = [];
  int _currentSortColumn = 0;
  bool _isSortAsc = true;

  Future<List<dynamic>> _selectTemp() async {
    await db.getConnection().then((conn) {
      String sql = 'select val from nodemcu_table';
      conn.query(sql).then((results) {
        temp.clear();
        for (var row in results) {
          temp.add(row[0]);
        }
      });
    });
    return temp;
  }

  Future<List<dynamic>> _selectSunny() async {
    await db.getConnection().then((conn) {
      String sql = 'select val3 from nodemcu_table';
      conn.query(sql).then((results) {
        sunny.clear();
        for (var row in results) {
          sunny.add(row[0]);
        }
      });
    });
    return sunny;
  }

  Future<List<dynamic>> _selectWet() async {
    await db.getConnection().then((conn) {
      String sql = 'select val2 from nodemcu_table';
      conn.query(sql).then((results) {
        wet.clear();
        for (var row in results) {
          wet.add(row[0]);
        }
      });
    });
    return wet;
  }

  Future<List<dynamic>> _selectData() async {
    await db.getConnection().then((conn) {
      String sql = 'select data from nodemcu_table';
      conn.query(sql).then((results) {
        data.clear();
        for (var row in results) {
          var date = DateFormat('yyyy-MM-dd').format(row[0]);
          data.add(date);
        }
      });
    });
    return data;
  }

  Future<List<dynamic>> _selectTime() async {
    await db.getConnection().then((conn) {
      String sql = 'select time from nodemcu_table';
      conn.query(sql).then((results) {
        time.clear();
        for (var row in results) {
          Duration times = row[0];
          String hours = times.inHours.toString().padLeft(2, '0');
          String minutes =
              times.inMinutes.remainder(60).toString().padLeft(2, '0');
          String seconds =
              times.inSeconds.remainder(60).toString().padLeft(2, '0');

          time.add('$hours:$minutes:$seconds');
        }
      });
    });
    return data;
  }

  void makeList() {
    all.clear();
    for (int i = 0; i < temp.length; i++) {
      Map something = {
        'id': i + 1,
        'temp': temp[i],
        'wilg': wet[i],
        'nasl': sunny[i],
        'data': data[i],
        'czas': time[i],
      };
      all.add(something);
    }
  }

  Future<dynamic> dataSelect() async {
    final data1 = await _selectTemp();
    final data2 = await _selectWet();
    final data3 = await _selectSunny();
    final data4 = await _selectData();
    final data5 = await _selectTime();
    var data6 = makeList();
    await Future.delayed(const Duration(seconds: 2));
    return [data1, data2, data3, data4, data5, data6];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: dataSelect(),
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
                      Text(',${snapshot.error}. Try refresh'),
                      ElevatedButton(
                        onPressed: () => dataSelect(),
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
                      onPressed: () => dataSelect(),
                      child: const Text('Refresh'),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    const Text("No data"),
                    ElevatedButton(
                      onPressed: () => dataSelect(),
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
              DataCell(Text(measure['data'])),
              DataCell(Text(measure['czas']))
            ]))
        .toList();
  }
}
