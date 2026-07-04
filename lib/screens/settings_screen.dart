import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/hud_components.dart';
import 'laser_divider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

  String _getThemeName(int index) {
    switch (index) {
      case 1:
        return 'DEEP OCEAN';
      case 2:
        return 'ELECTRIC CYAN';
      case 3:
        return 'SAPPHIRE KNIGHT';
      case 4:
        return 'NEON ICE';
      default:
        return 'MIDNIGHT COBALT';
    }
  }

  int _getThemeRequiredLevel(int index) {
    switch (index) {
      case 1:
        return 5;
      case 2:
        return 10;
      case 3:
        return 15;
      case 4:
        return 20;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final notifications = provider.notifications;
    final primaryColor = _getThemePrimaryColor(provider.activeThemeIndex);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Audio effects & Theme Config card
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 12),
            child: Text(
              '// SYSTEM INTERFACE CONFIG',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF80D8FF),
                letterSpacing: 1.5,
              ),
            ),
          ),
          GlassHudCard(
            borderColor: const Color(0xFF1B264A),
            padding: const EdgeInsets.all(16),
            cornerRadius: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.volume_up, color: Colors.grey, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          'SYSTEM AUDIO EFFECTS',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: provider.isSoundEnabled,
                      activeColor: primaryColor,
                      onChanged: (val) {
                        provider.toggleSound(val);
                      },
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF1B264A), height: 24),
                Text(
                  'COMPATIBLE INTERFACES:',
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final themeName = _getThemeName(index);
                    final reqLvl = _getThemeRequiredLevel(index);
                    final isLocked = provider.characterLevel < reqLvl;
                    final isSelected = provider.activeThemeIndex == index;
                    final themeColor = _getThemePrimaryColor(index);

                    return InkWell(
                      onTap: isLocked
                          ? null
                          : () {
                              provider.changeTheme(index);
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? themeColor.withOpacity(0.06)
                              : const Color(0xFF070B1D).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected
                                ? themeColor
                                : isLocked
                                    ? Colors.grey.shade900
                                    : const Color(0xFF1B264A),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLocked ? Icons.lock : Icons.palette_outlined,
                              color: isLocked ? Colors.grey : themeColor,
                              size: 14,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                themeName,
                                style: GoogleFonts.orbitron(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isLocked ? Colors.grey : Colors.white,
                                ),
                              ),
                            ),
                            if (isLocked)
                              Text(
                                'LVL $reqLvl REQUIRED',
                                style: GoogleFonts.orbitron(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              )
                            else if (isSelected)
                              Text(
                                'ACTIVE',
                                style: GoogleFonts.orbitron(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const LaserDivider(height: 16, thickness: 1.5),
          const SizedBox(height: 4),

          // Developer Controls Console
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 12),
            child: Text(
              '// SYSTEM COMMAND CONSOLE (SIMULATION)',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF80D8FF),
                letterSpacing: 1.5,
              ),
            ),
          ),
          GlassHudCard(
            borderColor: const Color(0xFF1B264A),
            padding: const EdgeInsets.all(16),
            cornerRadius: 6,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                HudButton(
                  label: 'FORCE ROLLOVER',
                  color: Colors.redAccent,
                  isSecondary: true,
                  onPressed: () {
                    provider.performDailyReset();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: primaryColor,
                        content: Text(
                          'Day Rollover Triggered! Daily quests reset and penalties computed.',
                          style: GoogleFonts.orbitron(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    );
                  },
                ),
                HudButton(
                  label: 'ROLL BOSS',
                  color: primaryColor,
                  isSecondary: true,
                  onPressed: () {
                    provider.rollDailyBoss();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: primaryColor,
                        content: Text(
                          'New Daily Boss rolled successfully!',
                          style: GoogleFonts.orbitron(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    );
                  },
                ),
                HudButton(
                  label: 'REROLL WEEKLY',
                  color: primaryColor,
                  isSecondary: true,
                  onPressed: () {
                    provider.rollWeeklyQuest();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: primaryColor,
                        content: Text(
                          'New Weekly Boss rolled successfully!',
                          style: GoogleFonts.orbitron(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    );
                  },
                ),
                HudButton(
                  label: 'FACTORY RESET',
                  color: Colors.redAccent,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF0A0F24).withOpacity(0.95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        ),
                        title: Text(
                          'ERASE ALL DATA?',
                          style: GoogleFonts.orbitron(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        content: Text(
                          'This will delete all stat levels, achievements, streaks, and custom quests. Proceed?',
                          style: GoogleFonts.exo2(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('CANCEL', style: GoogleFonts.orbitron(color: Colors.grey, fontSize: 11)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            onPressed: () {
                              provider.developerReset();
                              Navigator.pop(context);
                            },
                            child: Text('DELETE ALL', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // System Diagnostic Logs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '// SYSTEM PROTOCOL READOUTS',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF80D8FF),
                  letterSpacing: 1.5,
                ),
              ),
              if (notifications.isNotEmpty)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                  onPressed: () => provider.clearNotifications(),
                  child: Text(
                    'CLEAR CONSOLE',
                    style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0F24).withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF1B264A),
                width: 1.0,
              ),
            ),
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.terminal, size: 36, color: primaryColor.withOpacity(0.3)),
                        const SizedBox(height: 8),
                        Text(
                          'SYSTEM ALERTS CLEAR',
                          style: GoogleFonts.orbitron(
                            color: Colors.grey,
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final alert = notifications[index];
                      final isLevelUp = alert.title.contains('LEVEL UP');
                      final isFail = alert.title.contains('ERROR') || alert.title.contains('FAILED');

                      Color titleColor = Colors.white;
                      if (isLevelUp) titleColor = Colors.green;
                      if (isFail) titleColor = Colors.redAccent;

                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121B3A).withOpacity(0.4),
                          border: Border.all(color: const Color(0xFF1B264A), width: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  alert.title.toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: titleColor,
                                  ),
                                ),
                                Text(
                                  '${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 8,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alert.message,
                              style: GoogleFonts.exo2(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
