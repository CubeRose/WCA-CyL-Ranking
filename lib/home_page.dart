import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wca_cyl_ranking/cuber.dart';
import 'package:wca_cyl_ranking/get_CyL_ranking.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String rankingType = 'single'; // 'single' or 'average'
  String eventType = '333';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Ranking | Castilla y León',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: cubersBody(),
    );
  }

  ///Contenido principal de la aplicación. Involucra los selectores
  ///de evento y de tipo de ranking (single/media), así como la lista
  ///ordenada de competidores
  Column cubersBody() {
    return Column(children: [rankTypeButton(), eventSelector(), listCubers()]);
  }

  ///Botón de decisión binaria. Permite elegir ranking de tipo
  ///single o de tipo media.
  Padding rankTypeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: ToggleButtons(
          isSelected: [rankingType == 'single', rankingType == 'average'],
          onPressed: (index) {
            setState(() {
              rankingType = index == 0 ? 'single' : 'average';
            });
          },
          borderRadius: BorderRadius.circular(8),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('Single'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('Media'),
            ),
          ],
        ),
      ),
    );
  }

  /*  Column eventSelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(height:30, width: 200, color: Theme.of(context).colorScheme.primaryContainer,),
        Container(height:30, width: 200, color: Theme.of(context).colorScheme.primaryContainer,),
        Container(height:30, width: 200, color: Theme.of(context).colorScheme.primaryContainer,),
      ],
    );
  } */

  Widget eventSelector() {
    // Lista de eventos WCA populares (puedes modificar los códigos y nombres)
    final events = [
      {'code': '333'},
      {'code': '222'},
      {'code': '444'},
      {'code': '555'},
      {'code': '666'},
      {'code': '777'},
      {'code': '333oh'},
      {'code': '333bf'},
      {'code': '333fm'},
      {'code': '333mbf'},
      {'code': 'clock'},
      {'code': 'minx'},
      {'code': 'pyram'},
      {'code': 'skewb'},
      {'code': 'sq1'},
      {'code': '444bf'},
      {'code': '555bf'},
    ];

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 10,
        children: events.map((event) {
          final isSelected = eventType == event['code'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: SvgPicture.asset(
                'assets/icons/${event['code']}.svg',
                height: 25,
                width: 25,
              ),
              selected: isSelected,
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) {
                setState(() {
                  eventType = event['code']!;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  ///Contiene la lista scrolleable de competidores ordenados,
  ///representados como contenedores con posición, nombre, ID y tiempo.
  Expanded listCubers() {
    return Expanded(
      child: FutureBuilder<List<Cuber>>(
        future: getCyLranking(eventType, rankingType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cuber = snapshot.data![index];
                return ListTile(
                  title: Text("${cuber.id} | ${cuber.name}"),
                  subtitle: Text('Tiempo: ${cuber.time.toStringAsFixed(2)}'),
                );
              },
            );
          } else {
            return const Text('No data');
          }
        },
      ),
    );
  }
}
