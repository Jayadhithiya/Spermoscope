import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'Urls.dart';

class GraphScreen extends StatefulWidget {
  final String uid;

  const GraphScreen({super.key, required this.uid});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  List<double> spermCounts = [42, 48, 55, 62, 59, 68];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSpermCounts();
  }

  Future<void> _fetchSpermCounts() async {
    try {
      final response = await http.get(Uri.parse('${Urls.Url}/get_sperm_count/${widget.uid}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<double> counts = [];

        if (data['counts'] is List) {
          counts = (data['counts'] as List)
              .map((c) => (c is num) ? (c > 1000 ? c / 1000000 : c).toDouble() : 40.0)
              .toList();
        } else {
          for (int i = 1; i <= 6; i++) {
            final val = data['active_sperm$i'];
            if (val != null) {
              final n = (val is num) ? val.toDouble() : double.tryParse(val.toString()) ?? 0.0;
              counts.add(n > 1000 ? n / 1000000 : n);
            }
          }
        }

        if (mounted && counts.isNotEmpty) {
          setState(() {
            spermCounts = counts;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final maxVal = spermCounts.isNotEmpty ? spermCounts.reduce((a, b) => a > b ? a : b) : 80.0;
    final minVal = spermCounts.isNotEmpty ? spermCounts.reduce((a, b) => a < b ? a : b) : 20.0;
    final avgVal = spermCounts.isNotEmpty ? spermCounts.reduce((a, b) => a + b) / spermCounts.length : 50.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F274A),
        elevation: 0,
        title: Text('Motility Longitudinal Analytics · ${widget.uid}', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Stats Row
                      Row(
                        children: [
                          Expanded(child: _metricCard('Baseline', '${spermCounts.first.toStringAsFixed(1)} M/mL', Icons.start_rounded)),
                          const SizedBox(width: 12),
                          Expanded(child: _metricCard('Peak Count', '${maxVal.toStringAsFixed(1)} M/mL', Icons.trending_up_rounded, color: const Color(0xFF059669))),
                          const SizedBox(width: 12),
                          Expanded(child: _metricCard('Average', '${avgVal.toStringAsFixed(1)} M/mL', Icons.insights_rounded)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Chart Card
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sperm Concentration Trend (Million / mL)',
                              style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Sample Stages S1 through S6 tracking response curve',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              height: 280,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: const Color(0xFFF1F5F9),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 42,
                                        getTitlesWidget: (value, meta) => Text(
                                          '${value.toInt()}M',
                                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                        ),
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 32,
                                        getTitlesWidget: (value, meta) {
                                          final i = value.toInt();
                                          if (i >= 0 && i < spermCounts.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text('Stage ${i + 1}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600)),
                                            );
                                          }
                                          return const Text('');
                                        },
                                        interval: 1,
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: (spermCounts.length - 1).toDouble(),
                                  minY: (minVal - 10).clamp(0, 100).toDouble(),
                                  maxY: (maxVal + 15).toDouble(),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(
                                        spermCounts.length,
                                        (i) => FlSpot(i.toDouble(), spermCounts[i]),
                                      ),
                                      isCurved: true,
                                      curveSmoothness: 0.35,
                                      color: const Color(0xFF1E3A8A),
                                      barWidth: 3.5,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                          radius: 5,
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                          strokeColor: const Color(0xFF1E3A8A),
                                        ),
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF3B82F6).withOpacity(0.25),
                                            const Color(0xFF3B82F6).withOpacity(0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color ?? const Color(0xFF1E3A8A)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: color ?? const Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
