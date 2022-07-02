import 'package:flutter/material.dart';
import 'package:pogodynka_am/Mysql.dart';

class Chart extends StatefulWidget {
  const Chart({Key? key}) : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  var db = Mysql();
  List<dynamic> temp = [];
  List<dynamic> sunny = [];
  List<dynamic> wet = [];
  List<dynamic> data = [];
  List<dynamic> time = [];

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
          data.add(row[0]);
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
          time.add(row[0]);
        }
      });
    });
    return data;
  }

  Future<dynamic> dataSelect() async {
    final data1 = await _selectTemp();
    final data2 = await _selectWet();
    final data3 = await _selectSunny();
    final data4 = await _selectData();
    final data5 = await _selectTime();
    await Future.delayed(const Duration(seconds: 1));
    return [data1, data2, data3, data4, data5];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dataSelect(),
      builder: ((context, snapshot) {
        return const SafeArea(
          child: Scaffold(body: Text('data')),
        );
      }),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: dataSelect(),
//         builder: ((context, snapshot) {
//           return LineChart(
//             LineChartData(minX: 0, maxX: 11, minY: 0, maxY: 45, lineBarsData: [
//               LineChartBarData(spots: [
//                 const FlSpot(0, 3),
//                 const FlSpot(2.6, 2),
//                 const FlSpot(4.9, 5),
//                 const FlSpot(6.8, 2.5),
//                 const FlSpot(8, 4),
//                 const FlSpot(9.5, 3),
//                 const FlSpot(11, 4),
//               ])
//             ]),
//           );
//         }));
//   }
// }
