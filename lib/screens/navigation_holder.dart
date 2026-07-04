import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import 'dashboard_screen.dart';
import 'quest_board_screen.dart';
import 'punishment_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class NavigationHolder extends StatefulWidget {
  const NavigationHolder({super.key});

  @override
  State<NavigationHolder> createState() => _NavigationHolderState();
}

class _NavigationHolderState extends State<NavigationHolder> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const QuestBoardScreen(),
    const PunishmentScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  Color _getThemePrimaryColor(int themeIdx) {
    switch (themeIdx) {
      case 1:
        return const Color(0xFF00B0FF); // Deep Ocean
      case 2:
        return const Color(0xFF18FFFF); // Electric Cyan
      case 3:
        return const Color(0xFF448AFF); // Sapphire Knight
      case 4:
        return const Color(0xFF80D8FF); // Neon Ice
      default:
        return const Color(0xFF00D2FF); // Neon Cyan
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).checkDailyReset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final unreadCount = gameProvider.unreadNotificationsCount;
    final activePunishmentsCount = gameProvider.activePunishments.length;
    final primaryColor = _getThemePrimaryColor(gameProvider.activeThemeIndex);

    return Scaffold(
      backgroundColor: Colors.transparent, // Background grid is rendered by parent BlueprintBackground
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F24).withOpacity(0.9),
          border: Border(
            top: BorderSide(
              color: primaryColor.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 9,
            letterSpacing: 1.0,
          ),
          unselectedLabelStyle: GoogleFonts.orbitron(
            fontSize: 8,
            letterSpacing: 0.5,
          ),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_pin, size: 20),
              label: 'HERO',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.assignment, size: 20),
              label: 'QUESTS',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.gavel, size: 20),
                  if (activePunishmentsCount > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$activePunishmentsCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'DEBUFFS',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_on, size: 20),
              label: 'MATRIX',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.settings, size: 20),
                  if (unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'SYSTEM',
            ),
          ],
        ),
      ),
    );
  }
}
