import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pogodynka_am/models/Mysql.dart';
import 'package:pogodynka_am/models/sunny.dart';
import 'package:pogodynka_am/models/temp.dart';
import 'package:pogodynka_am/models/wet.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  List<Temperature> listTemp = [];
  List<Wet> listWet = [];
  List<Sunny> listSunny = [];
  late TooltipBehavior _tooltipBehavior;

  Future<List<dynamic>> _selectTemp() async {
    await db.getConnection().then((conn) {
      String sql = 'select val2 from nodemcu_table';
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
      String sql = 'select val from nodemcu_table';
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

  Future<List<Temperature>> _makeTemperature() async {
    await Future.delayed(const Duration(seconds: 1));
    for (int i = 0; i < temp.length; i++) {
      Duration times = time[i];
      String hours = times.inHours.toString().padLeft(2, '0');
      String minutes = times.inMinutes.remainder(60).toString().padLeft(2, '0');
      String seconds = times.inSeconds.remainder(60).toString().padLeft(2, '0');
      String timeCorecct = '$hours:$minutes:$seconds';
      DateTime datas = data[i];
      String dateCorrect = DateFormat('yyyy-MM-dd').format(datas).toString();
      String measureData = '$dateCorrect  $timeCorecct';
      listTemp.add(Temperature(
        measureData,
        temp[i],
      ));
    }
    return listTemp;
  }

  Future<List<Wet>> _makeWet() async {
    await Future.delayed(const Duration(seconds: 1));
    for (int i = 0; i < temp.length; i++) {
      Duration times = time[i];
      String hours = times.inHours.toString().padLeft(2, '0');
      String minutes = times.inMinutes.remainder(60).toString().padLeft(2, '0');
      String seconds = times.inSeconds.remainder(60).toString().padLeft(2, '0');
      String timeCorecct = '$hours:$minutes:$seconds';
      DateTime datas = data[i];
      String dateCorrect = DateFormat('yyyy-MM-dd').format(datas).toString();
      String measureData = '$dateCorrect  $timeCorecct';
      listWet.add(Wet(
        measureData,
        wet[i],
      ));
    }
    return listWet;
  }

  Future<List<Sunny>> _makeSunny() async {
    await Future.delayed(const Duration(seconds: 1));
    for (int i = 0; i < temp.length; i++) {
      Duration times = time[i];
      String hours = times.inHours.toString().padLeft(2, '0');
      String minutes = times.inMinutes.remainder(60).toString().padLeft(2, '0');
      String seconds = times.inSeconds.remainder(60).toString().padLeft(2, '0');
      String timeCorecct = '$hours:$minutes:$seconds';
      DateTime datas = data[i];
      String dateCorrect = DateFormat('yyyy-MM-dd').format(datas).toString();
      String measureData = '$dateCorrect  $timeCorecct';
      listSunny.add(Sunny(
        measureData,
        sunny[i],
      ));
    }
    return listSunny;
  }

  Future<dynamic> dataSelect() async {
    final data1 = await _selectTemp();
    final data2 = await _selectWet();
    final data3 = await _selectSunny();
    final data4 = await _selectData();
    final data5 = await _selectTime();
    final data6 = await _makeTemperature();
    final data7 = await _makeWet();
    final data8 = await _makeSunny();
    await Future.delayed(const Duration(seconds: 2));
    return [data1, data2, data3, data4, data5, data6, data7, data8];
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dataSelect(),
      builder: ((context, snapshot) {
        return SafeArea(
          child: Scaffold(
            body: SfCartesianChart(
              title: ChartTitle(text: 'Pomiary'),
              tooltipBehavior: _tooltipBehavior,
              series: <ChartSeries>[
                LineSeries<Temperature, String>(
                    dataSource: listTemp,
                    name: 'temperatura',
                    xValueMapper: (Temperature tempTemp, _) => tempTemp.data,
                    yValueMapper: (Temperature tempTemp, _) => tempTemp.temp,
                    enableTooltip: true),
                LineSeries<Wet, String>(
                    name: 'wilgotność',
                    dataSource: listWet,
                    xValueMapper: (Wet wetTemp, _) => wetTemp.data,
                    yValueMapper: (Wet wetTemp, _) => wetTemp.wet,
                    enableTooltip: true),
                LineSeries<Sunny, String>(
                    name: 'nasłonecznienie',
                    dataSource: listSunny,
                    xValueMapper: (Sunny sunTemp, _) => sunTemp.data,
                    yValueMapper: (Sunny sunTemp, _) => sunTemp.sunny,
                    enableTooltip: true)
              ],
              primaryXAxis: CategoryAxis(
                arrangeByIndex: true,
                isVisible: false,
              ),
              legend: Legend(isVisible: true),
            ),
          ),
        );
      }),
    );
  }
}
