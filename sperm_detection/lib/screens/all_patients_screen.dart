import 'package:flutter/material.dart';
import 'patient_details_screen.dart';

class AllPatientsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> patients;

  const AllPatientsScreen({super.key, required this.patients});

  @override
  _AllPatientsScreenState createState() => _AllPatientsScreenState();
}

class _AllPatientsScreenState extends State<AllPatientsScreen> {
  List<Map<String, dynamic>> filteredPatients = [];
  String searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPatients = widget.patients;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filterPatients(String query) {
    setState(() {
      searchQuery = query.trim().toLowerCase();
      if (searchQuery.isEmpty) {
        filteredPatients = widget.patients;
      } else {
        filteredPatients = widget.patients.where((p) {
          final name = (p['name'] ?? '').toString().toLowerCase();
          final id = (p['patient_id'] ?? '').toString().toLowerCase();
          final contact = (p['contact'] ?? '').toString().toLowerCase();
          return name.contains(searchQuery) || id.contains(searchQuery) || contact.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F274A),
        elevation: 0,
        title: Text(
          'Patient Registry (${widget.patients.length})',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              // Search Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: Colors.white,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _filterPatients,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Search patients by name, ID, or phone...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF64748B)),
                            onPressed: () {
                              _searchCtrl.clear();
                              _filterPatients('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Patient List
              Expanded(
                child: filteredPatients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.person_search_rounded, size: 48, color: Color(0xFF94A3B8)),
                            SizedBox(height: 12),
                            Text('No matching patient records found', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = filteredPatients[index];
                          final name = (patient['name'] ?? 'Unknown').toString();
                          final id = (patient['patient_id'] ?? 'N/A').toString();
                          final age = (patient['age'] ?? '-').toString();
                          final contact = (patient['contact'] ?? 'No phone').toString();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFEFF6FF),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'P',
                                  style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w700),
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              subtitle: Text(
                                'UID: $id  ·  Age: $age  ·  $contact',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientDetailsScreen(patient: patient),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
