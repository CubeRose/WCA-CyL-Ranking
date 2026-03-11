import 'package:flutter/material.dart';
import 'package:wca_cyl_ranking/cuber.dart';
import 'package:wca_cyl_ranking/get_CyL_ranking.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String rankingType = 'single'; // 'single' or 'average'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Ranking Castilla y León'),
      ),
      body: cubersBody(),
    );
  }

  Column cubersBody() {
    return Column(
      children: [
        Padding(
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
        ),
        
        listCubers(),
      ],
    );
  }

  Expanded listCubers() {
    final eventType = '333';
    return Expanded(
      child: FutureBuilder<List<Cuber>>(
        future: getCyLranking(eventType, rankingType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } 
          else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cuber = snapshot.data![index];
                return ListTile(
                  title: Text(cuber.id),
                  subtitle: Text('Tiempo: ${cuber.time.toStringAsFixed(2)}'),
                );
              },
            );
          } 
          else {
            return const Text('No data');
          }
        },
      ),
    );
  }
}
