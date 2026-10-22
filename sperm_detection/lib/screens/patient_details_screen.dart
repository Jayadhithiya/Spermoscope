import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Urls.dart';
import 'edit_patient_screen.dart';
import 'result_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  bool _isRefreshing = false;

  Future<void> _refreshPatientDetails() async {
    final patientId = widget.patient['patient_id'];
    if (patientId == null) return;

    setState(() => _isRefreshing = true);
    final url = '${Urls.Url}/get_patient/$patientId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final updatedPatient = json.decode(response.body);
        if (updatedPatient is Map<String, dynamic>) {
          setState(() {
            widget.patient.addAll(updatedPatient);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching patient details: $e');
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _navigateToEditScreen() async {
    final updatedPatient = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPatientScreen(patient: widget.patient),
      ),
    );

    if (updatedPatient != null && updatedPatient is Map<String, dynamic>) {
      setState(() {
        widget.patient['patient_id'] = updatedPatient['patient_id'] ?? widget.patient['patient_id'];
        widget.patient.addAll(updatedPatient);
      });
    }
  }

  String _val(String key, [String fallback = 'Not specified']) {
    final v = widget.patient[key];
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  @override
  Widget build(BuildContext context) {
    final name = _val('name', 'Patient Record');
    final patientId = _val('patient_id', 'ID-Pending');
    final contact = _val('contact', 'No contact recorded');
    final occupation = _val('occupation', 'Not specified');

    final age = _val('age', '-');
    final height = _val('height', '-');
    final weight = _val('weight', '-');
    final bmi = _val('bmi', '-');
    final foc = widget.patient['frequency_of_coitus'] ?? widget.patient['foc'] ?? '-';
    final sexualDysfunction = _val('sexual_dysfunction', 'None reported');

    final alcoholic = _val('alcoholic', 'No');
    final smoker = _val('smoker', 'No');
    final drugs = _val('drugs', 'No');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F274A),
        elevation: 0,
        title: const Text(
          'Patient Record',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _refreshPatientDetails,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit Patient',
            onPressed: _navigateToEditScreen,
          ),
        ],
      ),
      body: _isRefreshing
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : RefreshIndicator(
              onRefresh: _refreshPatientDetails,
              color: const Color(0xFF1E3A8A),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Patient Summary Card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: Center(
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'P',
                                    style: const TextStyle(
                                      color: Color(0xFF1E3A8A),
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        _badge(Icons.fingerprint_rounded, 'ID: $patientId', const Color(0xFF3B82F6)),
                                        _badge(Icons.badge_outlined, occupation, const Color(0xFF64748B)),
                                        _badge(Icons.phone_outlined, contact, const Color(0xFF059669)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section 1: Biometric & Anthropometric Vitals
                        _sectionTitle(Icons.monitor_heart_outlined, 'Biometrics & Physical Measurements'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _metricTile('Age', '$age yrs', Icons.cake_outlined)),
                                  const SizedBox(width: 14),
                                  Expanded(child: _metricTile('Height', '$height m', Icons.height_rounded)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(child: _metricTile('Weight', '$weight kg', Icons.fitness_center_rounded)),
                                  const SizedBox(width: 14),
                                  Expanded(child: _metricTile('BMI Index', '$bmi', Icons.speed_rounded)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 2: Clinical & Reproductive History
                        _sectionTitle(Icons.medical_services_outlined, 'Clinical & Reproductive Profile'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              _infoRow('Occupation', occupation),
                              const Divider(color: Color(0xFFF1F5F9), height: 24),
                              _infoRow('Frequency of Coitus', '$foc / week'),
                              const Divider(color: Color(0xFFF1F5F9), height: 24),
                              _infoRow('Sexual Dysfunction', sexualDysfunction),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 3: Lifestyle & Social Risk Factors
                        _sectionTitle(Icons.health_and_safety_outlined, 'Lifestyle & Risk Factors'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              _statusRow(Icons.no_drinks_outlined, 'Alcohol Consumption', alcoholic),
                              const Divider(color: Color(0xFFF1F5F9), height: 24),
                              _statusRow(Icons.smoking_rooms_outlined, 'Tobacco / Smoking Habit', smoker),
                              const Divider(color: Color(0xFFF1F5F9), height: 24),
                              _statusRow(Icons.medication_outlined, 'Substance / Drug Use', drugs),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ResultScreen(
                                        initialUid: patientId,
                                        doctorEmail: widget.patient['doctor_email']?.toString(),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.biotech_rounded, size: 20),
                                label: const Text('Specimens & Motility Stages', style: TextStyle(fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                onPressed: _navigateToEditScreen,
                                icon: const Icon(Icons.edit_note_rounded, size: 20),
                                label: const Text('Update Profile'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  side: const BorderSide(color: Color(0xFF1E3A8A)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1E3A8A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _badge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _statusRow(IconData icon, String label, String value) {
    final isYes = value.toLowerCase() == 'yes';
    final chipColor = isYes ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final chipBg = isYes ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);

    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF334155), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: chipColor.withOpacity(0.3)),
          ),
          child: Text(
            isYes ? 'YES / Positive' : 'NO / Negative',
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
