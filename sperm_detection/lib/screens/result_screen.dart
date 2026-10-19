import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sperm_detection/screens/graph_screen.dart';
import 'Urls.dart';
import 'upload_sample_screen.dart';
import 'view_result_screen.dart';

class ResultScreen extends StatefulWidget {
  static final List<bool> _sampleUnlocked = [true, false, false, false, false, false];

  const ResultScreen({super.key});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;
  Map<String, dynamic>? _searchedPatient;
  int currentSample = 1;

  @override
  void initState() {
    super.initState();
    // Default search for p001 so screen is immediately useful
    _searchPatient('p001');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetSampleLockStatus() {
    for (int i = 0; i < 6; i++) {
      ResultScreen._sampleUnlocked[i] = (i == 0);
    }
  }

  void _unlockSamples(int currentSampleInt) {
    for (int i = 0; i < 6; i++) {
      ResultScreen._sampleUnlocked[i] = false;
    }
    if (currentSampleInt >= 1 && currentSampleInt <= 6) {
      ResultScreen._sampleUnlocked[currentSampleInt - 1] = true;
    }
    if (mounted) setState(() {});
  }

  Future<void> _searchPatient(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    setState(() {
      _searching = true;
      _resetSampleLockStatus();
    });

    try {
      final response = await http.get(
        Uri.parse('${Urls.Url}/result?uid=$q'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _searchedPatient = data;
            _searching = false;
            currentSample = data['current_sample'] is int
                ? data['current_sample']
                : int.tryParse(data['current_sample']?.toString() ?? '1') ?? 1;
          });
          await _getSampleStatus();
        }
      } else {
        _handleSearchError('Patient record "$q" not found');
      }
    } catch (e) {
      _handleSearchError('Error searching: $e');
    }
  }

  void _handleSearchError(String message) {
    if (!mounted) return;
    setState(() {
      _searching = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
      ),
    );
  }

  Future<void> _getSampleStatus() async {
    final uid = _searchedPatient?['patient']?['uid']?.toString() ?? '';
    if (uid.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${Urls.Url}/get_sample_status/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final sampleStatus = jsonDecode(response.body);
        final int cur = sampleStatus['current_sample'] ?? 1;
        _unlockSamples(cur);
      }
    } catch (e) {
      debugPrint('Error fetching sample status: $e');
    }
  }

  Future<void> _updateCurrentSample() async {
    final uid = _searchedPatient?['patient']?['uid']?.toString() ?? '';
    if (uid.isEmpty) return;

    try {
      final response = await http.put(
        Uri.parse('${Urls.Url}/result/update_current_sample/$uid'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'current_sample': currentSample}),
      );

      if (response.statusCode == 200) {
        setState(() {
          currentSample = (currentSample < 6) ? currentSample + 1 : 6;
        });
        _unlockSamples(currentSample);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final p = _searchedPatient?['patient'];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F274A),
        elevation: 0,
        title: const Text('Diagnostic Results & Motility', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Box Card
                Container(
                  padding: const EdgeInsets.all(18),
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
                        'Patient Search & Look-up',
                        style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Enter Patient ID (e.g. p001) or Name',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                                ),
                              ),
                              onSubmitted: _searchPatient,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () => _searchPatient(_searchController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Search', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          const Text('Quick ID:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          _quickIdChip('p001'),
                          _quickIdChip('p002'),
                          _quickIdChip('p003'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Content
                if (_searching)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A))),
                  )
                else if (p != null) ...[
                  // Patient Info Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Center(
                            child: Text(
                              (p['name']?.toString() ?? 'P')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['name']?.toString() ?? 'Patient',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'UID: ${p['uid'] ?? 'p001'}  ·  Age: ${p['age'] ?? '-'}  ·  Occupation: ${p['occupation'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Testing Samples Pipeline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sample Analysis Stages (1–6)',
                        style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GraphScreen(uid: p['uid']?.toString() ?? 'p001'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.analytics_outlined, size: 18, color: Color(0xFF1E3A8A)),
                        label: const Text('View Motility Graph', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // List of 6 sample tiles
                  ...List.generate(6, (index) {
                    final sampleNum = index + 1;
                    final isUnlocked = ResultScreen._sampleUnlocked[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isUnlocked ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
                          width: isUnlocked ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isUnlocked ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '#$sampleNum',
                                style: TextStyle(
                                  color: isUnlocked ? const Color(0xFF1E3A8A) : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Specimen Sample $sampleNum',
                                  style: TextStyle(
                                    color: isUnlocked ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  isUnlocked ? 'Ready for microscopic analysis' : 'Stage locked until previous is processed',
                                  style: TextStyle(
                                    color: isUnlocked ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: isUnlocked
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UploadSampleScreen(
                                              uid: p['uid'].toString(),
                                              sampleType: sampleNum.toString(),
                                            ),
                                          ),
                                        ).then((_) => _updateCurrentSample());
                                      }
                                    : null,
                                icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                                label: const Text('Upload', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  side: BorderSide(color: isUnlocked ? const Color(0xFF1E3A8A) : const Color(0xFFCBD5E1)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewResultScreen(
                                        sampleType: sampleNum,
                                        uid: p['uid'].toString(),
                                        patientDetails: p,
                                        sampleNumber: sampleNum,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.assessment_outlined, size: 16),
                                label: const Text('Report', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ] else
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Center(
                      child: Text(
                        'No patient record found. Try searching for "p001" or "Ali Raza".',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickIdChip(String id) {
    return InkWell(
      onTap: () {
        _searchController.text = id;
        _searchPatient(id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Text(
          id,
          style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}