import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sperm_detection/screens/Urls.dart';
import 'package:sperm_detection/screens/patient_details_screen.dart';
import 'package:sperm_detection/screens/result_screen.dart';
import 'package:sperm_detection/screens/all_patients_screen.dart';
import 'about.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';
import 'patient_details_form.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Timer? _timer;
  final List<String> images = [
    'assets/image1.jpeg',
    'assets/image2.jpeg',
    'assets/image3.jpeg',
    'assets/image4.jpeg',
  ];
  late PageController _pageController;
  int _currentImageIndex = 0;
  List<Map<String, dynamic>> _recentPatients = [];
  bool _loadingPatients = true;
  String _username = '';
  String _role = 'Physician';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % images.length;
      });
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentImageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    _fetchRecentPatients();
    _fetchUsername();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecentPatients() async {
    setState(() => _loadingPatients = true);
    try {
      final emailParam = Uri.encodeComponent(widget.email.trim());
      final response = await http.get(Uri.parse('${Urls.Url}/recent_patients?email=$emailParam'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (mounted && decoded is List) {
          setState(() {
            _recentPatients = List<Map<String, dynamic>>.from(decoded);
            _loadingPatients = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingPatients = false);
  }

  Future<void> _fetchUsername() async {
    try {
      final response = await http.get(
        Uri.parse('${Urls.Url}/get_profile?email=${widget.email}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _username = data['name'] ?? widget.email;
            _role = (data['role'] ?? 'doctor').toString();
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _username = widget.email);
    }
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      final res = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PatientDetailsForm(email: widget.email)),
      );
      if (res == true) _fetchRecentPatients();
    } else if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  void _logoff() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(email: ''),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _fetchRecentPatients,
        color: const Color(0xFF1E3A8A),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Carousel
                  _buildCarousel(),
                  const SizedBox(height: 20),

                  // Diagnostic Stats
                  _buildStatsRow(),
                  const SizedBox(height: 24),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _quickActionButton(
                          Icons.person_add_alt_1_rounded,
                          'New Patient Intake',
                          'Register demographic profile',
                          const Color(0xFF1E3A8A),
                          () => _onItemTapped(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _quickActionButton(
                          Icons.biotech_rounded,
                          'Diagnostic Center',
                          'Specimens & Motility tests',
                          const Color(0xFF2563EB),
                          () => _onItemTapped(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Patient List Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline_rounded, color: Color(0xFF1E3A8A), size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Active Patient Records',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AllPatientsScreen(patients: _recentPatients),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF1E3A8A)),
                        label: const Text(
                          'View All Roster',
                          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Patient Cards
                  if (_loadingPatients)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A))),
                    )
                  else if (_recentPatients.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Text(
                          'No patients currently in roster. Tap "New Patient Intake" to add one.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                    )
                  else
                    ..._recentPatients.asMap().entries.map((entry) {
                      return _buildPatientCard(entry.value, entry.key);
                    }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F274A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.biotech_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'SPERMOSCOPE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: 'Refresh Roster',
          onPressed: _fetchRecentPatients,
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          tooltip: 'Sign Out',
          onPressed: _logoff,
        ),
      ],
    );
  }

  Widget _buildCarousel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              itemBuilder: (_, index) => Image.asset(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F274A), Color(0xFF1E3A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.biotech_rounded, color: Colors.white70, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Computer-Assisted Sperm Analysis (CASA)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Automated Motility & Morphology',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Real-time Computer Vision Tracking Engine · WHO 6th Ed.',
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 16,
            child: Row(
              children: List.generate(
                images.length,
                (i) => Container(
                  width: _currentImageIndex == i ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _currentImageIndex == i ? const Color(0xFF60A5FA) : Colors.white38,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.people_alt_outlined,
            '${_recentPatients.length}',
            'Active Patients',
            const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.track_changes_rounded,
            '60 FPS',
            'AI Tracking',
            const Color(0xFF059669),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.verified_outlined,
            '98.6%',
            'Accuracy',
            const Color(0xFF7C3AED),
          ),
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient, int index) {
    final name = patient['name']?.toString() ?? 'Unknown Patient';
    final id = patient['patient_id']?.toString() ?? 'p00$index';
    final age = patient['age']?.toString() ?? '-';
    final contact = patient['contact']?.toString() ?? 'No phone';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'P',
                style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w700, fontSize: 17),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _badge(Icons.fingerprint_rounded, id),
                      const SizedBox(width: 8),
                      _badge(Icons.cake_outlined, '$age yrs'),
                      const SizedBox(width: 8),
                      _badge(Icons.phone_outlined, contact),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PatientDetailsScreen(patient: patient)),
                ).then((_) => _fetchRecentPatients());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('View Record', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF64748B)),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: const Color(0xFF94A3B8),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_rounded),
            label: 'New Intake',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Results & Motility',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final displayName = _username.isNotEmpty ? _username : (widget.email.isNotEmpty ? widget.email : 'Attending Physician');

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F274A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'D',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _role.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _drawerItem(Icons.lock_outline_rounded, 'Security & Password', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChangePasswordScreen(email: widget.email)),
            );
          }),
          _drawerItem(Icons.info_outline_rounded, 'About Spermoscope Platform', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutScreen()),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
                label: const Text('Sign Out', style: TextStyle(color: Color(0xFFDC2626))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _logoff,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
      title: Text(title, style: const TextStyle(color: Color(0xFF334155), fontSize: 14, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
