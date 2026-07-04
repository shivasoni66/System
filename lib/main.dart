import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/game_provider.dart';
import 'services/notification_service.dart';
import 'screens/navigation_holder.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/hud_components.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.init();
  
  // Schedule a daily task reminder (e.g. 9:00 PM)
  await notificationService.scheduleDailyReminder(hour: 21, minute: 0);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        return const Color(0xFF00D2FF); // Neon Cyan / Midnight Cobalt
    }
  }

  Color _getThemeBgColor(int themeIdx) {
    switch (themeIdx) {
      case 1:
        return const Color(0xFF02111E); // Deep Ocean
      case 2:
        return const Color(0xFF05171B); // Electric Cyan
      case 3:
        return const Color(0xFF070B1D); // Sapphire Knight
      case 4:
        return const Color(0xFF0B141C); // Neon Ice
      default:
        return const Color(0xFF0A0F24); // Midnight Cobalt / Deep Navy
    }
  }

  Color _getThemeCardColor(int themeIdx) {
    switch (themeIdx) {
      case 1:
        return const Color(0xFF072136); // Deep Ocean
      case 2:
        return const Color(0xFF0D2C33); // Electric Cyan
      case 3:
        return const Color(0xFF111735); // Sapphire Knight
      case 4:
        return const Color(0xFF152636); // Neon Ice
      default:
        return const Color(0xFF121B3A); // Midnight Cobalt / Slate Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameProvider>(
      create: (_) => GameProvider(),
      child: Consumer<GameProvider>(
        builder: (context, provider, child) {
          final primaryColor = _getThemePrimaryColor(provider.activeThemeIndex);
          final scaffoldBg = _getThemeBgColor(provider.activeThemeIndex);
          final cardBg = _getThemeCardColor(provider.activeThemeIndex);

          return MaterialApp(
            title: 'SYSTEM',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: scaffoldBg,
              primaryColor: primaryColor,
              colorScheme: ColorScheme.dark(
                primary: primaryColor,
                secondary: const Color(0xFF2979FF), // Electric Blue
                surface: cardBg,
                error: Colors.redAccent,
              ),
              textTheme: GoogleFonts.exo2TextTheme(
                ThemeData.dark().textTheme.copyWith(
                  bodyLarge: const TextStyle(color: Colors.white),
                  bodyMedium: const TextStyle(color: Colors.white70),
                ),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: cardBg.withOpacity(0.85),
                elevation: 0,
                titleTextStyle: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryColor,
                  letterSpacing: 3.0,
                ),
              ),
            ),
            home: provider.playerName.isEmpty
                ? const OnboardingScreen()
                : const NavigationHolderPage(),
          );
        },
      ),
    );
  }
}

class NavigationHolderPage extends StatelessWidget {
  const NavigationHolderPage({super.key});

  Color _getThemePrimaryColor(int themeIdx) {
    switch (themeIdx) {
      case 1:
        return const Color(0xFF00B0FF);
      case 2:
        return const Color(0xFF18FFFF);
      case 3:
        return const Color(0xFF448AFF);
      case 4:
        return const Color(0xFF80D8FF);
      default:
        return const Color(0xFF00D2FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final primaryColor = _getThemePrimaryColor(gameProvider.activeThemeIndex);

    return BlueprintBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Transparent to allow Blueprint grid to show
        appBar: AppBar(
          backgroundColor: const Color(0xFF121B3A).withOpacity(0.6),
          title: Text(
            'THE SYSTEM',
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.w900,
              letterSpacing: 4.0,
              fontSize: 16,
              color: primaryColor,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline, color: primaryColor),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF0A0F24).withOpacity(0.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: primaryColor, width: 1.5),
                    ),
                    title: Text(
                      'SYSTEM DIRECTORY',
                      style: GoogleFonts.orbitron(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Text(
                        'Welcome Shiva to the SYSTEM!\n\n'
                        '1. Complete quests to gain stat XP. Leveling stats automatically increases your Overall Level!\n\n'
                        '2. Unlock new ranks (Novice -> Disciplined -> Elite -> Legend) and titles (Beginner -> Warrior -> Knight -> Champion -> Legend -> Mythic) as you level up.\n\n'
                        '3. Track consecutive completions with the STREAK system. Breaking streaks triggers XP & stat penalties.\n\n'
                        '4. Equip cosmetic items from your Equipment Inventory to receive XP boost multipliers.\n\n'
                        '5. Defeat the Daily Boss or Sunday Weekly Boss for massive XP rewards.\n\n'
                        '6. Track your performance with the Statistics page and contribution matrix.',
                        style: GoogleFonts.exo2(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'LOGGED',
                          style: GoogleFonts.orbitron(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: const NavigationHolder(),
      ),
    );
  }
}
