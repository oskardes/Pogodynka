import 'package:flutter/material.dart';

class Database extends StatefulWidget {
  const Database({Key? key}) : super(key: key);

  @override
  State<Database> createState() => _DatabaseState();
}

class _DatabaseState extends State<Database> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Table'),
    );
  }
}
