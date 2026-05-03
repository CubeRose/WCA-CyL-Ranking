class Cuber {
  String id;
  String name;
  Map<String, int> singles;
  Map<String, int> averages;

  Cuber({
    required this.id,
    required this.name,
    Map<String, int>? singles,
    Map<String, int>? averages,
  }) : singles = singles ?? {},
       averages = averages ?? {};

  /// Crea un objeto tipo Cuber a partir del json recibido de Unofficial WCA Public API
  factory Cuber.fromJson(Map<String, dynamic> personJson, String name) {
    final id = personJson['id'] ?? personJson['personId'] ?? '';

    final Map<String, int> singlesMap = {};
    final Map<String, int> averagesMap = {};

    if (personJson.containsKey('rank') && personJson['rank'] is Map) {
      final rank = personJson['rank'] as Map<String, dynamic>;

      if (rank['singles'] is List) {
        for (final item in rank['singles'] as List) {
          if (item is Map<String, dynamic>) {
            final ev = item['eventId'] as String? ?? item['event'] as String?;
            final best = item['best'];
            if (ev != null && best is num) {
              singlesMap[ev] = best.toInt();
            }
          }
        }
      }

      if (rank['averages'] is List) {
        for (final item in rank['averages'] as List) {
          if (item is Map<String, dynamic>) {
            final ev = item['eventId'] as String? ?? item['event'] as String?;
            final best = item['best'];
            if (ev != null && best is num) {
              averagesMap[ev] = best.toInt();
            }
          }
        }
      }
    }

    return Cuber(
      id: id as String,
      name: name,
      singles: singlesMap,
      averages: averagesMap,
    );
  }
}
