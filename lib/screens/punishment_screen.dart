import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/hud_components.dart';
import 'laser_divider.dart';

class PunishmentScreen extends StatelessWidget {
  const PunishmentScreen({super.key});

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
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final punishments = provider.activePunishments;
        final primaryColor = _getThemePrimaryColor(provider.activeThemeIndex);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tactical Warning Hologram
              GlassHudCard(
                borderColor: punishments.isNotEmpty ? Colors.redAccent : primaryColor,
                padding: const EdgeInsets.all(16),
                cornerRadius: 6,
                child: Row(
                  children: [
                    Icon(
                      punishments.isNotEmpty ? Icons.warning_amber : Icons.verified_user,
                      color: punishments.isNotEmpty ? Colors.redAccent : primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            punishments.isNotEmpty ? 'CRITICAL SYSTEM CORRUPTION' : 'CORE SYSTEM STABLE',
                            style: GoogleFonts.orbitron(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: punishments.isNotEmpty ? Colors.redAccent : primaryColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            punishments.isNotEmpty
                                ? 'Active debuffs detected: ${punishments.length} protocols compromised. Resolve immediately.'
                                : 'All parameters normal. Willpower framework optimal.',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const LaserDivider(height: 16, thickness: 1.5),
              const SizedBox(height: 8),
              
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 12),
                child: Text(
                  '// SYSTEM PENALTY MATRIX',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF80D8FF),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: punishments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryColor.withOpacity(0.4)),
                                color: primaryColor.withOpacity(0.04),
                              ),
                              child: Icon(
                                Icons.shield_outlined,
                                size: 40,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'ALL PARADIGMS SECURE',
                              style: GoogleFonts.orbitron(
                                color: Colors.grey,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: punishments.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final punishment = punishments[index];

                          return GlassHudCard(
                            borderColor: Colors.redAccent,
                            padding: const EdgeInsets.all(16),
                            cornerRadius: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.gavel,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        punishment.title.toUpperCase(),
                                        style: GoogleFonts.orbitron(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  punishment.description,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 11,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(0.08),
                                        border: Border.all(color: Colors.redAccent.withOpacity(0.4), width: 0.8),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Text(
                                        '-${punishment.penaltyXp.toStringAsFixed(0)} XP INFLICTED',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                    HudButton(
                                      label: 'RESOLVED',
                                      color: Colors.redAccent,
                                      onPressed: () {
                                        provider.completePunishment(punishment.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: primaryColor,
                                            content: Text(
                                              'Debuff cleansed! SYSTEM integrity restored.',
                                              style: GoogleFonts.orbitron(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
