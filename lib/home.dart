import 'package:flutter/material.dart';
import 'package:pogodynka_am/Mysql.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var db = Mysql();
  Map all = {};
  double temp = 0;
  double sunny = 0;
  double wet = 0;

  DateTime time = DateTime.now();
  var something = '';

  Future? _future;
  Future? _future2;

  Future<Map> _getAll() async {
    await db.getConnection().then((conn) {
      String sql =
          'select val, val2, val3 from nodemcu_table order by id desc limit 1';
      conn.query(sql).then((results) {
        all.clear();
        for (var row in results) {
          all = {
            'temp': row[0],
            'wilg': row[1],
            'nasl': row[2],
          };
        }
        temp = all['temp'];
        wet = all['wilg'];
        sunny = all['nasl'];
      });
    });
    return all;
  }

  Future<dynamic> dataFuture() async {
    final all = await _getAll();
    await Future.delayed(const Duration(seconds: 2));
    return [all];
  }

  @override
  void initState() {
    super.initState();
    _future = dataFuture();
  }

  void updateFuture() {
    setState(() {
      _future2 = dataFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat("yyyy-MM-dd kk:mm").format(time);
    return Center(
      child: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return Column(
                  children: [
                    Text('${snapshot.error} Try refresh'),
                    ElevatedButton(
                        onPressed: () {
                          setState(() async {
                            _future2;
                            await Future.delayed(const Duration(seconds: 2));
                            time = DateTime.now();
                          });
                        },
                        child: const Text("Refresh"))
                  ],
                );
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
                      'Temperatura : $temp',
                      style: GoogleFonts.oxygen(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'Wilgotność: $wet % ',
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
                          dataFuture();
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
    );
  }
}
