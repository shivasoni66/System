import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/hud_components.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

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
    final achievements = gameProvider.achievements;

    return BlueprintBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFF121B3A).withOpacity(0.6),
          title: Text(
            'SYSTEM ARCHIVES',
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.w900,
              letterSpacing: 3.0,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: achievements.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ach = achievements[index];
            final isUnlocked = ach.isUnlocked;

            return GlassHudCard(
              borderColor: isUnlocked ? Colors.green : Colors.grey.shade900,
              padding: const EdgeInsets.all(14),
              cornerRadius: 6,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isUnlocked ? Colors.green : Colors.white10,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: isUnlocked
                          ? Colors.green.withOpacity(0.06)
                          : Colors.transparent,
                    ),
                    child: Icon(
                      isUnlocked ? Icons.workspace_premium : Icons.lock_outline,
                      color: isUnlocked ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ach.title.toUpperCase(),
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.white : Colors.grey,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ach.description,
                          style: GoogleFonts.rajdhani(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isUnlocked ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                        if (isUnlocked && ach.unlockedAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'UNLOCKED: ${ach.unlockedAt!.day}/${ach.unlockedAt!.month}/${ach.unlockedAt!.year}',
                            style: GoogleFonts.orbitron(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
