class Temperature {
  final String data;
  final double temp;

  Temperature(
    this.data,
    this.temp,
  );

  @override
  String toString() {
    return '$temp $data';
  }
}
