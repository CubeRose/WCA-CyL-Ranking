import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wca_cyl_ranking/cuber.dart';
import 'package:wca_cyl_ranking/get_CyL_ranking.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: cubersAppBar(context),
        body: cubersBody(),
      ),
    );
  }

  /// Muestra la appBar de la aplicación, conteniendo el título
  /// y un botón de información de la app
  AppBar cubersAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text(
        'WCA-CyL-Ranking',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.info),
          color: Colors.white,
          tooltip: 'App information',
          onPressed: () => showInfoDialog(context),
        ),
      ],
    );
  }

  /// Dialogo mostrado al picar en el botón "i" de la appBar
  Future<String?> showInfoDialog(BuildContext context) {
    const String appVersion = '1.0.0+1';
    final Uri githubUrl = Uri.parse(
      'https://github.com/CubeRose/WCA-CyL-Ranking',
    );

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/icon/icon.png'),
              ),
            ),
            const SizedBox(width: 15),
            Flexible(
              child: Text(
                'Sobre la app',
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                'WCA-CyL-Ranking muestra un ranking no oficial de los speedcubers de Castilla y León.\n\nDatos obtenidos de la Unofficial WCA API',
              ),
              const SizedBox(height: 16),

              const Text(
                'Versión',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(appVersion),
              const SizedBox(height: 8),

              TextButton(
                onPressed: () =>
                    launchUrl(githubUrl, mode: LaunchMode.externalApplication),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('GitHub del proyecto'),
              ),
              const SizedBox(height: 8),

              const Text(
                'Autor',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Text('Héctor Voces Prieto | CubeRose'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
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

          return buildListChips(displayList);
        },
      ),
    );
  }

  ListView buildListChips(List<Cuber> displayList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final cuber = displayList[index];
        final rankColor = _getRankColor(index);
        final bool useCompactLayout =
            MediaQuery.textScaleFactorOf(context) >= 1.2;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: useCompactLayout
                  // en caso de que el nombre del competidor desborde
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            // POSICIÓN EN CAJA
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (index < 3)
                                    Container(
                                      width: 19,
                                      height: 19,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: rankColor.withOpacity(0.06),
                                        boxShadow: [
                                          BoxShadow(
                                            color: rankColor.withOpacity(0.35),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: rankColor,
                                    ),
                                  ),
                                ],
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
                                    softWrap: true,
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
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Builder(
                            builder: (_) {
                              final int raw = (rankingType == 'average'
                                  ? cuber.averages[eventType]
                                  : cuber.singles[eventType])!;

                              final String display = (raw > 0)
                                  ? _formatSeconds(raw)
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
                        ),
                      ],
                    )
                  // si no desborda el nombre del competidor
                  : Row(
                      children: [
                        // POSICIÓN EN CAJA
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (index < 3)
                                Container(
                                  width: 19,
                                  height: 19,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: rankColor.withOpacity(0.06),
                                    boxShadow: [
                                      BoxShadow(
                                        color: rankColor.withOpacity(0.35),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: rankColor,
                                ),
                              ),
                            ],
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
                                softWrap: true,
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
                                ? _formatSeconds(raw)
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
  }

  String _formatSeconds(int time) {
    // Convertir centisegundos a segundos
    double totalSeconds = time / 100;

    // Si es menos de 60 segundos, mostrar solo los segundos
    if (totalSeconds < 60) {
      return totalSeconds.toStringAsFixed(2);
    }

    // Calcular minutos y segundos restantes
    int minutes = (totalSeconds ~/ 60).toInt();
    double remainingSeconds = totalSeconds % 60;

    // Formatear como M:SS.CC, asegurando que los segundos tengan al menos 2 dígitos antes del punto decimal
    String formatted = remainingSeconds.toStringAsFixed(2).padLeft(5, '0');
    return "$minutes:$formatted";
  }

  /// Devuelve el color para la numeración de la lista de competidores, tal que:
  /// - Primer puesto: color oro
  /// - Segundo puesto: color plata
  /// - Tercer puesto: color bronce
  /// - Siguientes: negro
  Color _getRankColor(int index) {
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
