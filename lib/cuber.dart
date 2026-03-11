class Cuber {
  String id;
  String name;
  double time;

  Cuber({
    required this.id,
    required this.name,
    required this.time,
  });

  factory Cuber.fromJson(Map<String, dynamic> json, String name) {
    return Cuber(
      id: json['personId'],
      time: json['best'] / 100,
      name: name,
    );
  }
}
