import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Urls.dart';

class PatientDetailsForm extends StatefulWidget {
  final String email;

  const PatientDetailsForm({super.key, required this.email});

  @override
  _PatientDetailsFormState createState() => _PatientDetailsFormState();
}

class _PatientDetailsFormState extends State<PatientDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _coitusFrequencyController = TextEditingController();
  final TextEditingController _sexualDysfunctionController = TextEditingController();

  bool _isAlcoholic = false;
  bool _isSmoker = false;
  bool _isUsingDrugs = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);
  }

  void _calculateBmi() {
    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);
    if (h != null && w != null && h > 0) {
      final bmi = w / (h * h);
      _bmiController.text = bmi.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _contactController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _coitusFrequencyController.dispose();
    _sexualDysfunctionController.dispose();
    super.dispose();
  }

  Future<void> _submitDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${Urls.Url}/patient'),
        body: json.encode({
          'name': _nameController.text.trim(),
          'age': int.tryParse(_ageController.text) ?? 0,
          'occupation': _occupationController.text.trim(),
          'contact': _contactController.text.trim().isEmpty ? '0300-0000000' : _contactController.text.trim(),
          'height': double.tryParse(_heightController.text) ?? 0.0,
          'weight': double.tryParse(_weightController.text) ?? 0.0,
          'bmi': double.tryParse(_bmiController.text) ?? 0.0,
          'foc': int.tryParse(_coitusFrequencyController.text) ?? 0,
          'frequency_of_coitus': int.tryParse(_coitusFrequencyController.text) ?? 0,
          'sexual_dysfunction': _sexualDysfunctionController.text.trim().isEmpty ? 'None' : _sexualDysfunctionController.text.trim(),
          'alcoholic': _isAlcoholic ? 'Yes' : 'No',
          'smoker': _isSmoker ? 'Yes' : 'No',
          'drugs': _isUsingDrugs ? 'Yes' : 'No',
          'doctor_email': widget.email.trim(),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Patient intake recorded successfully!'),
                ],
              ),
              backgroundColor: Color(0xFF059669),
            ),
          );
          _clearFields();
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save patient: ${response.body}'),
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
            content: Text('Connection error: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  void _clearFields() {
    _nameController.clear();
    _ageController.clear();
    _occupationController.clear();
    _contactController.clear();
    _heightController.clear();
    _weightController.clear();
    _bmiController.clear();
    _coitusFrequencyController.clear();
    _sexualDysfunctionController.clear();
    setState(() {
      _isAlcoholic = false;
      _isSmoker = false;
      _isUsingDrugs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F274A),
        elevation: 0,
        title: const Text('New Patient Intake', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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
                  // Form Header Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF1E3A8A), size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient Registration Form',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Enter clinical history & anthropometrics for automated motility evaluation',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 1: Demographics
                  _sectionHeader(Icons.badge_outlined, 'Patient Identification & Demographics'),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDeco(),
                    child: Column(
                      children: [
                        _textField(_nameController, 'Full Legal Name', Icons.person_rounded, (v) => v!.isEmpty ? 'Please enter name' : null),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _textField(_ageController, 'Age (Years)', Icons.cake_outlined, (v) => v!.isEmpty ? 'Enter age' : null, isNumber: true),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _textField(_occupationController, 'Occupation', Icons.work_outline_rounded, (v) => v!.isEmpty ? 'Enter occupation' : null),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _textField(_contactController, 'Phone / Contact Number (Optional)', Icons.phone_outlined, null),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Vitals & Body Metrics
                  _sectionHeader(Icons.straighten_rounded, 'Anthropometrics & Physical Metrics'),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDeco(),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _textField(_heightController, 'Height (meters e.g. 1.75)', Icons.height_rounded, (v) => v!.isEmpty ? 'Enter height' : null, isNumber: true),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _textField(_weightController, 'Weight (kg e.g. 70)', Icons.fitness_center_rounded, (v) => v!.isEmpty ? 'Enter weight' : null, isNumber: true),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _textField(_bmiController, 'Calculated BMI (Auto)', Icons.speed_rounded, null, isNumber: true, readOnly: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 3: Reproductive & Sexual Health
                  _sectionHeader(Icons.favorite_border_rounded, 'Reproductive History & Symptoms'),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDeco(),
                    child: Column(
                      children: [
                        _textField(_coitusFrequencyController, 'Frequency of Coitus (per week)', Icons.repeat_rounded, (v) => v!.isEmpty ? 'Enter frequency' : null, isNumber: true),
                        const SizedBox(height: 14),
                        _textField(_sexualDysfunctionController, 'Sexual Dysfunction / Symptoms (e.g. None)', Icons.medical_information_outlined, null),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 4: Habits & Risk Factors
                  _sectionHeader(Icons.fact_check_outlined, 'Lifestyle & Risk Factors'),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDeco(),
                    child: Column(
                      children: [
                        _switchTile('Alcohol Consumption', _isAlcoholic, (v) => setState(() => _isAlcoholic = v)),
                        const Divider(height: 20),
                        _switchTile('Tobacco / Cigarette Smoker', _isSmoker, (v) => setState(() => _isSmoker = v)),
                        const Divider(height: 20),
                        _switchTile('Substance / Drug Use', _isUsingDrugs, (v) => setState(() => _isUsingDrugs = v)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitDetails,
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
                                Icon(Icons.person_add_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('Save & Register Patient', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
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
