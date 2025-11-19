import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/match_service.dart';
import '../widgets/app_drawer.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final MatchService _matchService = MatchService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _matchService.getMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error leyendo partidas: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Aún no hay partidas para calcular estadísticas.'));
          }

          // Convertir los datos
          final matches = docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            return <String, dynamic>{
              'map': data['map'],
              'kills': (data['kills'] is int)
                  ? data['kills']
                  : int.tryParse('${data['kills']}') ?? 0,
              'deaths': (data['deaths'] is int)
                  ? data['deaths']
                  : int.tryParse('${data['deaths']}') ?? 0,
              'score': data['score'] ?? '',
              'createdAt': data['createdAt'],
            };
          }).toList();

          // Estadísticas básicas
          final totalMatches = matches.length;
          final totalKills = matches.fold<int>(0, (s, m) => s + (m['kills'] as int));
          final totalDeaths = matches.fold<int>(0, (s, m) => s + (m['deaths'] as int));
          final kdRatio = totalDeaths == 0 ? totalKills.toDouble() : totalKills / totalDeaths;
          final avgKills = totalMatches == 0 ? 0.0 : totalKills / totalMatches;
          final avgDeaths = totalMatches == 0 ? 0.0 : totalDeaths / totalMatches;

          // Calcular winrate
          int wins = 0;
          for (final m in matches) {
            final score = (m['score'] ?? '').toString();
            final result = _parseScore(score);
            if (result != null) {
              final myScore = result[0];
              final oppScore = result[1];
              if (myScore > oppScore) wins++;
            }
          }
          final winrate =
              totalMatches == 0 ? 0.0 : (wins / totalMatches) * 100.0;

          // Ordenar por fecha
          matches.sort((a, b) {
            final ta = a['createdAt'];
            final tb = b['createdAt'];
            if (ta is Timestamp && tb is Timestamp) {
              return ta.compareTo(tb);
            }
            return 0;
          });

          final killsList = matches.map<int>((m) => m['kills'] as int).toList();
          final maxKills = killsList.isEmpty
              ? 0
              : killsList.reduce((a, b) => a > b ? a : b).toInt();

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Cards con estadísticas
                Row(
                  children: [
                    _statCard('Partidas', '$totalMatches'),
                    const SizedBox(width: 8),
                    _statCard('Kills', '$totalKills'),
                    const SizedBox(width: 8),
                    _statCard('Deaths', '$totalDeaths'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statCard('K/D', kdRatio.toStringAsFixed(2)),
                    const SizedBox(width: 8),
                    _statCard('Avg Kills', avgKills.toStringAsFixed(2)),
                    const SizedBox(width: 8),
                    _statCard('Winrate', '${winrate.toStringAsFixed(1)}%'),
                  ],
                ),
                const SizedBox(height: 20),

                // Gráfico
                Expanded(
                  child: Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text('Kills por partida (orden cronológico)'),
                          const SizedBox(height: 12),
                          Expanded(
                            child: killsList.isEmpty
                                ? const Center(child: Text('No hay datos para el gráfico'))
                                : BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: (maxKills + 5).toDouble(),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: true),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            getTitlesWidget: (value, meta) {
                                              final idx = value.toInt();
                                              if (idx < 0 ||
                                                  idx >= killsList.length) {
                                                return const SizedBox();
                                              }
                                              return SideTitleWidget(
                                                meta: meta,
                                                child: Text(
                                                  '${idx + 1}',
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      gridData: FlGridData(show: true),
                                      borderData: FlBorderData(show: false),
                                      barGroups: List.generate(killsList.length,
                                          (i) {
                                        return BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: killsList[i].toDouble(),
                                              width: 14,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            )
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Card(
        color: Colors.grey[850],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  List<int>? _parseScore(String score) {
    final cleaned = score.replaceAll(' ', '');
    if (cleaned.isEmpty || !cleaned.contains('-')) return null;
    final parts = cleaned.split('-');
    if (parts.length != 2) return null;
    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    if (a == null || b == null) return null;
    return [a, b];
  }
}
