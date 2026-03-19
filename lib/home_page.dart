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
  String rankingType = 'single';
  String eventType = '333';

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
          children: const [
            Text('Single'),
            Text('Average'),
          ],
        ),
      ),
    );
  }

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
        spacing: 8,
        runSpacing: 8,
        children: events.map((event) {
          final isSelected = (eventType == event['code']);
          return ChoiceChip(
            label: SvgPicture.asset(
              'assets/icons/${event['code']}.svg',
              height: 22,
              width: 22,
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

  Expanded listCubers() {
    return Expanded(
      child: FutureBuilder<List<Cuber>>(
        future: getCyLranking(eventType, rankingType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cuber = snapshot.data![index];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
                          horizontal: 14, vertical: 12),
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
                          Text(
                            '${cuber.time.toStringAsFixed(2)}s',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }

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