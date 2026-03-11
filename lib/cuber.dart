class Cuber {
  String id;
  double time;

  Cuber({
    required this.id,
    required this.time
  });

  factory Cuber.fromJson(Map<String, dynamic> json) {
    return Cuber(
      id: json['personId'],
      time: json['best'] / 100,
    );
  }
}
