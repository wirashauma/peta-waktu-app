import 'package:flutter/material.dart';
import 'package:peta_waktu/main.dart';
import 'package:peta_waktu/features/auth/services/user_service.dart';
import 'package:peta_waktu/features/auth/models/user_model.dart';
import 'package:peta_waktu/features/quiz/guru/screens/guru_quiz_list_screen.dart';
import 'package:peta_waktu/features/quiz/user/screens/user_quiz_list_screen.dart';
import 'package:peta_waktu/features/profile/screens/profile_screen.dart';
import 'package:peta_waktu/features/profile/screens/settings_screen.dart';
import 'package:peta_waktu/features/admin/screens/admin_user_list_screen.dart'
    hide textColor;
import '../../core/constants/map_coordinates.dart';
import 'package:peta_waktu/features/quiz/guru/screens/add_event_screen.dart';
import '../models/historical_event.dart';
import '../services/dashboard_service.dart';
import '../widgets/event_info_panel.dart';
import '../widgets/year_filter_bar.dart';

const Color primaryTeal = Color(0xFF00796B);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _service = DashboardService();
  int _selectedYear = 500;
  HistoricalEvent? _selectedEvent;
  Stream<List<HistoricalEvent>>? _eventsStream;
  final UserService _userService = UserService();
  String _userRole = 'user';
  UserModel? _currentUser;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateEventsStream();
    _fetchUserRole();
  }

  void _fetchUserRole() async {
    UserModel? user = await _userService.fetchCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userRole = user.role;
      });
    }
  }

  void _updateEventsStream() {
    setState(() {
      _eventsStream = _service.getEventsStream(_selectedYear);
      _selectedEvent = null;
    });
  }

  void _onYearSelected(int year) {
    setState(() {
      _selectedYear = year;
    });
    _updateEventsStream();
  }

  void _onNavTapped(int index) async {
    if (index == 2) {
      _currentUser ??= await _userService.fetchCurrentUser();
    }
    setState(() => _currentIndex = index);
  }

  Widget _buildPin(HistoricalEvent event) {
    return Align(
      alignment: MapCoordinates.getAlign(event.locationId),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedEvent = event;
          });
        },
        child: Image.asset(
          'assets/images/pin.png',
          width: 40,
          height: 40,
        ),
      ),
    );
  }

  Widget _buildPlaceholderPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 12.0, right: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryTeal.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Lokasi',
            style: TextStyle(
                color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Ketuk pin putih pada peta untuk melihat detail peristiwa sejarah di tahun yang dipilih.',
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 80),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final toolbarHeight = (screenHeight * 0.07).clamp(48.0, 64.0);
    final infoPanelHeight =
        (screenHeight * 0.32).clamp(140.0, screenHeight * 0.45);

    PreferredSizeWidget? appBar;
    if (_currentIndex == 0) {
      appBar = AppBar(
        toolbarHeight: toolbarHeight,
        title: Text('Peta Waktu',
            style: TextStyle(
                color: primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: (screenWidth * 0.05).clamp(16.0, 22.0))),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      );
    }

    Widget body;
    if (_currentIndex == 0) {
      body = Column(children: [
        Expanded(
            child: StreamBuilder<List<HistoricalEvent>>(
                stream: _eventsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: primaryTeal));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  List<HistoricalEvent> events = snapshot.data ?? [];

                  return Stack(fit: StackFit.expand, children: [
                    GestureDetector(
                        onTap: () => setState(() => _selectedEvent = null),
                        child: Container(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                                'assets/images/map_indonesia.png',
                                fit: BoxFit.contain))),
                    if (events.isEmpty && _selectedYear != 0)
                      const Center(
                          child: Text('Tidak ada data sejarah di periode ini.',
                              style: TextStyle(
                                  color: textColor,
                                  backgroundColor: Colors.white70))),
                    ...events.map((event) => _buildPin(event)).toList(),
                  ]);
                })),
        YearFilterBar(
            selectedYear: _selectedYear, onYearSelected: _onYearSelected),
        SizedBox(
            height: infoPanelHeight,
            child: Stack(
              children: [
                SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _selectedEvent != null
                        ? EventInfoPanel(event: _selectedEvent!)
                        : _buildPlaceholderPanel()),
                if (_userRole == 'guru' && _selectedEvent != null)
                  Positioned(
                    top: 10,
                    right: 20,
                    child: FloatingActionButton.small(
                      backgroundColor: Colors.orange,
                      child: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEventScreen(
                              eventToEdit: _selectedEvent,
                            ),
                          ),
                        );
                        _updateEventsStream();
                        setState(() {
                          _selectedEvent = null;
                        });
                      },
                    ),
                  ),
              ],
            )),
      ]);
    } else if (_currentIndex == 1) {
      if (_userRole == 'admin') {
        body = const AdminUserListScreen();
      } else if (_userRole == 'guru') {
        body = const GuruQuizListScreen();
      } else {
        body = const UserQuizListScreen();
      }
    } else {
      if (_currentUser == null) {
        body = const Center(child: CircularProgressIndicator());
      } else {
        body = SettingsScreen(user: _currentUser!);
      }
    }

    return Scaffold(
      appBar: appBar,
      body: SafeArea(child: body),
      floatingActionButton: (_userRole == 'guru' && _currentIndex == 0)
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEventScreen(),
                  ),
                );
                _updateEventsStream();
              },
              backgroundColor: primaryTeal,
              icon: const Icon(Icons.add_location_alt_outlined,
                  color: Colors.white),
              label: const Text("Tambah Peristiwa",
                  style: TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 6,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Peta'),
          BottomNavigationBarItem(
            icon: Icon(_userRole == 'admin' ? Icons.people_alt : Icons.quiz),
            label: _userRole == 'admin' ? 'Pengguna' : 'Kuis',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan')
        ],
      ),
    );
  }
}