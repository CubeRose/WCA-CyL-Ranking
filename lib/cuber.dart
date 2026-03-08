class Cuber {
  String name;
  double time;

  Cuber({
    required this.name, 
    required this.time
  });

  factory Cuber.fromJson(Map<String, dynamic> json) {
    return Cuber(
      name: json['personId'],
      time: json['best'] / 100,
    );
  }
}
