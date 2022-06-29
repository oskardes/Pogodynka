import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pogodynka_am/Mysql.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime time = DateTime.now();
  int currentIndex = 0;
  var db = Mysql();
  double temp = 0;
  double sunny = 0;
  double wet = 0;
  var something = '';
  Future? _future;

  Future<double> _getTemp() async {
    await db.getConnection().then((conn) {
      String sql = 'select val from nodemcu_table order by id desc limit 1';
      conn.query(sql).then((results) {
        for (var row in results) {
          temp = row[0];
        }
      });
    });
    return temp;
  }

  Future<double> _getWet() async {
    await db.getConnection().then((conn) {
      String sql = 'select val2 from nodemcu_table order by id desc limit 1';
      conn.query(sql).then((results) {
        for (var row in results) {
          wet = row[0];
        }
      });
    });
    return wet;
  }

  Future<double> _getSunny() async {
    await db.getConnection().then((conn) {
      String sql = 'select val3 from nodemcu_table order by id desc limit 1';
      conn.query(sql).then((results) {
        for (var row in results) {
          sunny = row[0];
        }
      });
    });
    return sunny;
  }

  Future<dynamic> dataFuture() async {
    final data1 = await _getTemp();
    final data2 = await _getWet();
    final data3 = await _getSunny();
    await Future.delayed(const Duration(seconds: 2));
    return [data1, data2, data3];
  }

  @override
  void initState() {
    super.initState();
    _future = dataFuture();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat("yyyy-MM-dd kk:mm").format(time);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'PogodynkaAM',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: FutureBuilder(
            future: _future,
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const CircularProgressIndicator();
                case ConnectionState.done:
                default:
                  if (snapshot.hasError) {
                    return Text(':( ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          formattedDate,
                          style: GoogleFonts.oxygen(
                            fontSize: 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Temperatura : $temp°C ',
                          style: GoogleFonts.oxygen(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Wilgotność: $wet% ',
                          style: GoogleFonts.oxygen(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Nasłonecznienie: $sunny lm ',
                          style: GoogleFonts.oxygen(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              time = DateTime.now();
                              _future;
                            });
                          },
                          child: const Text('Refresh'),
                        ),
                      ],
                    );
                  } else {
                    return const Text("No data");
                  }
              }
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.sunny),
              label: 'Weather',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Chart',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.table_chart,
              ),
              label: 'Table',
            ),
          ],
          currentIndex: currentIndex,
          onTap: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
