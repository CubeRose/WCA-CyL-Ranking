import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:wca_cyl_ranking/cuber.dart';

/// Devuelve una lista ordenada de objetos Cuber, creada a partir de la informacion de la
/// Unofficial WCA Public API, tomando solo aquellos competidores que sean de CyL.
Future<List<Cuber>> getCyLranking(String event, String rankingType) async {
  final all = await getAllCubers();

  final List<Cuber> filtered = all.where((c) {
    final int? val = rankingType == 'average'
        ? c.averages[event]
        : c.singles[event];
    return val != null && val > 0;
  }).toList();

  filtered.sort((a, b) {
    final int va = (rankingType == 'average'
        ? a.averages[event]
        : a.singles[event])!;
    final int vb = (rankingType == 'average'
        ? b.averages[event]
        : b.singles[event])!;
    return va.compareTo(vb);
  });

  return filtered;
}

Future<List<Cuber>> getAllCubers() async {
  // ID y nombre de competidores de CyL
  final Map<String, String> cylFilter = {};
  final fileUrl = Uri.parse(
    'https://raw.githubusercontent.com/CubeRose/WCA-CyL-Ranking/main/assets/data/cyl_cubers.txt',
  );

  final resp = await http.get(fileUrl);
  if (resp.statusCode != 200) {
    throw Exception('Failed to fetch cyl_cubers.txt from GitHub');
  }

  final fileContent = resp.body;

  for (final line in fileContent.split('\n')) {
    final parts = line.trim().split(':');
    if (parts.length == 2) {
      cylFilter[parts[0]] = parts[1];
    }
  }

  // Creamos lista y rellenamos
  final List<Cuber> cubers = [];
  // Iteramos por cada id y construimos Cuber usando el campo `rank`
  for (final id in cylFilter.keys) {
    final personUrl = Uri.parse(
      'https://raw.githubusercontent.com/robiningelbrecht/wca-rest-api/refs/heads/v1/persons/$id.json',
    );

    try {
      final resp = await http.get(personUrl);
      if (resp.statusCode != 200) {
        continue;
      }

      final Map<String, dynamic> person =
          jsonDecode(resp.body) as Map<String, dynamic>;

      final cuber = Cuber.fromJson(person, cylFilter[id]!);
      cubers.add(cuber);
    } catch (e) {
      continue;
    }
  }

  return cubers;
}
