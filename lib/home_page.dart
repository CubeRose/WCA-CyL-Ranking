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
  // se abre por defecto en 3x3x3 single
  String rankingType = 'single';
  String eventType = '333';
  // obtiene al principio los tiempos y medias de todos
  late Future<List<Cuber>> _initialFetch;
  List<Cuber> _allCubers = [];
  @override
  void initState() {
    super.initState();
    _initialFetch = getAllCubers(); // request de lista de Cubers
    _initialFetch
        .then((list) {
          setState(() {
            _allCubers = list;
          });
        })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Ranking Castilla y León',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: cubersBody(),
    );
  }

  /// Crea el cuerpo de la aplicacion, constando del selector "single|average", selector de evento
  /// y la lista ordenada de competidores
  Column cubersBody() {
    return Column(
      children: [
        rankTypeButton(),
        eventSelector(),
        const SizedBox(height: 8),
        listCubers(),
      ],
    );
  }

  /// Selector del tipo de ranking sobre tiempos de competicion, con opciones:
  /// - Single: mejor tiempo único
  /// - Average: mejor media de 5 tiempos, exluyendo el mejor y el peor de los 5
  Padding rankTypeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ToggleButtons(
          isSelected: [rankingType == 'single', rankingType == 'average'],
          onPressed: (index) {
            setState(() {
              rankingType = index == 0 ? 'single' : 'average';
            });
          },
          borderRadius: BorderRadius.circular(30),
          selectedColor: Colors.white,
          fillColor: Theme.of(context).colorScheme.primary,
          constraints: const BoxConstraints(minWidth: 120, minHeight: 40),
          children: const [Text('Single'), Text('Average')],
        ),
      ),
    );
  }

  /// Selector de evento, permitiendo elegir entre los eventos oficiales reconocidos por la WCA
  Widget eventSelector() {
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: events.map((event) {
          final isSelected = (eventType == event['code']);
          return ChoiceChip(
            label: SvgPicture.asset(
              'assets/icons/${event['code']}.svg',
              height: 16,
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : Colors.black87,
                BlendMode.srcIn,
              ),
            ),
            selected: isSelected,
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (_) {
              setState(() {
                eventType = event['code']!;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  /// Lista de competidores ordenada de mas rapido a mas lento. Se muestran solo aquellos competidores
  /// con tiempos oficiales grabados en la categoria elegida, con su nombre, ID y tiempo.
  Expanded listCubers() {
    return Expanded(
      child: FutureBuilder<List<Cuber>>(
        future: _initialFetch,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _allCubers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError && _allCubers.isEmpty) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final source = _allCubers.isNotEmpty
              ? _allCubers
              : (snapshot.data ?? []);

          final displayList = source.where((cuber) {
            final int? val = rankingType == 'average'
                ? cuber.averages[eventType]
                : cuber.singles[eventType];
            return val != null && val > 0;
          }).toList();

          if (displayList.isEmpty) {
            return const Center(child: Text('No data'));
          }

          displayList.sort((a, b) {
            final int va = (rankingType == 'average'
                ? a.averages[eventType]
                : a.singles[eventType])!;
            final int vb = (rankingType == 'average'
                ? b.averages[eventType]
                : b.singles[eventType])!;
            return va.compareTo(vb);
          });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final cuber = displayList[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // POSICIÓN EN CAJA
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: getRankColor(index),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // NOMBRE + ID
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cuber.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cuber.id,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // TIEMPO
                        Builder(
                          builder: (_) {
                            final int raw = (rankingType == 'average'
                                ? cuber.averages[eventType]
                                : cuber.singles[eventType])!;

                            final String display = (raw > 0)
                                ? '${(raw / 100.0).toStringAsFixed(2)}s'
                                : '-';

                            return Text(
                              display,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Devuelve el color para la numeración de la lista de competidores, tal que:
  /// - Primer puesto: color oro
  /// - Segundo puesto: color plata
  /// - Tercer puesto: color bronce
  /// - Siguientes: negro
  Color getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFB800);
      case 1:
        return const Color(0xFF9E9E9E);
      case 2:
        return const Color(0xFFB87333);
      default:
        return Colors.black87;
    }
  }
}
