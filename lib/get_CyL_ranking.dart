import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'package:wca_cyl_ranking/cuber.dart';

Future<List<Cuber>> getCyLranking(String event, String rankingType) async {
  final url = Uri.parse(
    'https://raw.githubusercontent.com/robiningelbrecht/wca-rest-api/master/api/rank/ES/$rankingType/$event.json',
  );

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception("No se pudieron cargar los datos");
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;

  final items = data['items'] as List;

  final Map<String, String> cylFilter = {};
  final fileContent = await rootBundle.loadString('assets/data/cyl_cubers.txt');

  for (final line in fileContent.split('\n')) {
    final parts = line.trim().split(':');
    if (parts.length == 2) {
      cylFilter[parts[0]] = parts[1];
    }
  }

  //toma cada persona y guarda los datos que necesita de ellos
  final cubers = items
      .map((item) => Cuber.fromJson(item as Map<String, dynamic>, 
                                  cylFilter[item['personId']]!)) //asumimos que el nombre no es nulo
      .where((cuber) => cylFilter.containsKey(cuber.id))
      .toList();
      

  return cubers;
}
