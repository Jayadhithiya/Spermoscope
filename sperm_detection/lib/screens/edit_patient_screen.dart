import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Urls.dart';

class EditPatientScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const EditPatientScreen({super.key, required this.patient});

  @override
  _EditPatientScreenState createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _occupationController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bmiController;
  late TextEditingController _focController;
  late TextEditingController _sexualDysfunctionController;
  late bool _isAlcoholic;
  late bool _isSmoker;
  late bool _isUsingDrugs;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nameController = TextEditingController(text: p['name']?.toString() ?? '');
    _ageController = TextEditingController(text: p['age']?.toString() ?? '');
    _occupationController = TextEditingController(text: p['occupation']?.toString() ?? '');
    _heightController = TextEditingController(text: p['height']?.toString() ?? '');
    _weightController = TextEditingController(text: p['weight']?.toString() ?? '');
    _bmiController = TextEditingController(text: p['bmi']?.toString() ?? '');
    _focController = TextEditingController(text: (p['frequency_of_coitus'] ?? p['foc'])?.toString() ?? '');
    _sexualDysfunctionController = TextEditingController(text: p['sexual_dysfunction']?.toString() ?? '');

    _isAlcoholic = (p['alcoholic']?.toString().toLowerCase() == 'yes');
    _isSmoker = (p['smoker']?.toString().toLowerCase() == 'yes');
    _isUsingDrugs = (p['drugs']?.toString().toLowerCase() == 'yes');

    // Auto calculate BMI when height and weight change
    _heightController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);
  }

  void _calculateBmi() {
    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);
    if (h != null && w != null && h > 0) {
      final bmiVal = w / (h * h);
      _bmiController.text = bmiVal.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _focController.dispose();
    _sexualDysfunctionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final patientId = widget.patient['patient_id'];
    final updatedPatient = {
      'patient_id': patientId,
      'name': _nameController.text.trim(),
      'age': int.tryParse(_ageController.text) ?? 0,
      'occupation': _occupationController.text.trim(),
      'height': double.tryParse(_heightController.text) ?? 0.0,
      'weight': double.tryParse(_weightController.text) ?? 0.0,
      'bmi': double.tryParse(_bmiController.text) ?? 0.0,
      'foc': int.tryParse(_focController.text) ?? 0,
      'frequency_of_coitus': int.tryParse(_focController.text) ?? 0,
      'sexual_dysfunction': _sexualDysfunctionController.text.trim(),
      'alcoholic': _isAlcoholic ? 'Yes' : 'No',
      'smoker': _isSmoker ? 'Yes' : 'No',
      'drugs': _isUsingDrugs ? 'Yes' : 'No',
    };

    try {
      final response = await http.put(
        Uri.parse('${Urls.Url}/update_patient/$patientId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedPatient),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient record updated successfully'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          Navigator.pop(context, updatedPatient);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update: ${response.body}'),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F274A),
        elevation: 0,
        title: const Text('Edit Patient Record', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1
                  _sectionHeader(Icons.person_outline_rounded, 'Personal Demographics'),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDeco(),
                    child: Column(
                      children: [
                        _textField(_nameController, 'Full Name', Icons.badge_outlined, (v) => v!.isEmpty ? 'Name is required' : null),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _textField(_ageController, 'Age (years)', Icons.cake_outlined, (v) => v!.isEmpty ? 'Required' : null, isNumber: true),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _textField(_occupationController, 'Occupation', Icons.work_outline_rounded, (v) => v!.isEmpty ? 'Required' : null),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 2
                  _sectionHeader(Icons.straighten_rounded, 'Anthropometrics & Vitals'),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDeco(),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _textField(_heightController, 'Height (meters)', Icons.height_rounded, (v) => v!.isEmpty ? 'Required' : null, isNumber: true),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _textField(_weightController, 'Weight (kg)', Icons.fitness_center_rounded, (v) => v!.isEmpty ? 'Required' : null, isNumber: true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _textField(_bmiController, 'Calculated BMI', Icons.speed_rounded, null, isNumber: true, readOnly: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 3
                  _sectionHeader(Icons.favorite_border_rounded, 'Reproductive & Sexual Health'),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDeco(),
                    child: Column(
                      children: [
                        _textField(_focController, 'Frequency of Coitus (per week)', Icons.repeat_rounded, null, isNumber: true),
                        const SizedBox(height: 16),
                        _textField(_sexualDysfunctionController, 'Sexual Dysfunction / Symptoms', Icons.medical_information_outlined, null),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 4
                  _sectionHeader(Icons.fact_check_outlined, 'Lifestyle & Risk Factors'),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDeco(),
                    child: Column(
                      children: [
                        _switchTile('Alcohol Consumption', _isAlcoholic, (v) => setState(() => _isAlcoholic = v)),
                        const Divider(height: 20),
                        _switchTile('Tobacco / Smoker', _isSmoker, (v) => setState(() => _isSmoker = v)),
                        const Divider(height: 20),
                        _switchTile('Substance / Drug Use', _isUsingDrugs, (v) => setState(() => _isUsingDrugs = v)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Save Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 1,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text('Save Changes to Patient Record', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
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

  BoxDecoration _cardDeco() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: const [
        BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2)),
      ],
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    bool isNumber = false,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      readOnly: readOnly,
      validator: validator,
      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 19),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF334155), fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Switch(
          value: value,
          activeThumbColor: const Color(0xFF1E3A8A),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
