import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sperm_detection/screens/graph_screen.dart';
import 'Urls.dart';
import 'patient_details_form.dart';
import 'upload_sample_screen.dart';
import 'view_result_screen.dart';

class ResultScreen extends StatefulWidget {
  final String? initialUid;
  final String? doctorEmail;

  const ResultScreen({super.key, this.initialUid, this.doctorEmail});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;
  Map<String, dynamic>? _searchedPatient;
  int currentSample = 1;
  Set<int> _uploadedSamples = <int>{};
  List<String> _quickPatientIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialUid != null && widget.initialUid!.trim().isNotEmpty) {
      _searchController.text = widget.initialUid!.trim();
      _searchPatient(widget.initialUid!.trim());
    } else if (widget.doctorEmail != null && widget.doctorEmail!.trim().isNotEmpty) {
      _loadDoctorLatestPatient();
    } else {
      _searchPatient('p001');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorLatestPatient() async {
    setState(() => _searching = true);
    try {
      final emailParam = Uri.encodeComponent(widget.doctorEmail!.trim());
      final res = await http.get(Uri.parse('${Urls.Url}/recent_patients?email=$emailParam'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List && data.isNotEmpty) {
          final ids = data
              .map<String>((p) => p['patient_id']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .take(5)
              .toList();

          if (mounted) {
            setState(() {
              _quickPatientIds = ids;
            });
          }

          final firstPid = data.first['patient_id']?.toString() ?? '';
          if (firstPid.isNotEmpty) {
            _searchController.text = firstPid;
            await _searchPatient(firstPid);
            return;
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _searching = false;
        _searchedPatient = null;
      });
    }
  }

  Future<void> _searchPatient(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    setState(() {
      _searching = true;
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
          await _getSampleStatus(q);
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

  Future<void> _getSampleStatus(String uid) async {
    if (uid.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${Urls.Url}/get_sample_status/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final sampleStatus = jsonDecode(response.body);
        final int cur = sampleStatus['current_sample'] is int
            ? sampleStatus['current_sample']
            : int.tryParse(sampleStatus['current_sample']?.toString() ?? '1') ?? 1;

        final Set<int> uploaded = {};
        if (sampleStatus['uploaded_samples'] is List) {
          for (final item in sampleStatus['uploaded_samples']) {
            if (item is int) {
              uploaded.add(item);
            } else if (item is String && int.tryParse(item) != null) {
              uploaded.add(int.parse(item));
            }
          }
        }

        if (mounted) {
          setState(() {
            currentSample = cur;
            _uploadedSamples = uploaded;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching sample status: $e');
    }
  }

  Future<void> _openUploadScreen(String uid, int sampleNum) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadSampleScreen(
          uid: uid,
          sampleType: sampleNum.toString(),
        ),
      ),
    );

    // Refresh immediately on return so stage status and charts reflect new specimen
    if (mounted) {
      await _getSampleStatus(uid);
      await _searchPatient(uid);
    }
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
                                hintText: 'Enter Patient ID or Name',
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
                        runSpacing: 6,
                        children: [
                          const Text('Quick ID:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          if (_quickPatientIds.isNotEmpty)
                            ..._quickPatientIds.map((id) => _quickIdChip(id))
                          else ...[
                            _quickIdChip('p001'),
                            _quickIdChip('p002'),
                            _quickIdChip('p003'),
                          ],
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
                                'UID: ${p['uid'] ?? 'ID-Pending'}  ·  Age: ${p['age'] ?? '-'}  ·  Occupation: ${p['occupation'] ?? 'N/A'}',
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

                  // List of 6 sample tiles (ALL upload buttons active and responsive)
                  ...List.generate(6, (index) {
                    final sampleNum = index + 1;
                    final isUploaded = _uploadedSamples.contains(sampleNum);
                    final isCurrent = sampleNum == currentSample;

                    Color circleBg = const Color(0xFFF1F5F9);
                    Color circleTextColor = const Color(0xFF64748B);
                    Color borderColor = const Color(0xFFE2E8F0);
                    String subtitleText = 'Ready for microscopic analysis';
                    Color subtitleColor = const Color(0xFF059669);

                    if (isUploaded) {
                      circleBg = const Color(0xFFECFDF5);
                      circleTextColor = const Color(0xFF059669);
                      borderColor = const Color(0xFFA7F3D0);
                      subtitleText = 'Analysis recorded · Ready for review or re-upload';
                      subtitleColor = const Color(0xFF059669);
                    } else if (isCurrent) {
                      circleBg = const Color(0xFFEFF6FF);
                      circleTextColor = const Color(0xFF1E3A8A);
                      borderColor = const Color(0xFF93C5FD);
                      subtitleText = 'Active stage · Ready for microscopic analysis';
                      subtitleColor = const Color(0xFF2563EB);
                    } else {
                      subtitleText = 'Stage $sampleNum available for specimen capture';
                      subtitleColor = const Color(0xFF64748B);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: borderColor,
                          width: (isCurrent || isUploaded) ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: circleBg,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isUploaded
                                  ? const Icon(Icons.check_rounded, color: Color(0xFF059669), size: 18)
                                  : Text(
                                      '#$sampleNum',
                                      style: TextStyle(
                                        color: circleTextColor,
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
                                Row(
                                  children: [
                                    Text(
                                      'Specimen Sample $sampleNum',
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (isUploaded) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Recorded',
                                          style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitleText,
                                  style: TextStyle(
                                    color: subtitleColor,
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
                                onPressed: () => _openUploadScreen(p['uid'].toString(), sampleNum),
                                icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                                label: Text(
                                  isUploaded ? 'Re-upload' : 'Upload',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.2),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                                label: const Text('Report', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.person_search_rounded, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 14),
                        const Text(
                          'No Patient Selected',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Search for an existing patient ID above, or register a new intake to begin microscopic sample analysis.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PatientDetailsForm(email: widget.doctorEmail ?? '')),
                            );
                            if (res == true && widget.doctorEmail != null) {
                              _loadDoctorLatestPatient();
                            }
                          },
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                          label: const Text('Register New Patient Intake', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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