import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models.dart';
import '../widgets/hud_components.dart';
import 'achievements_screen.dart';
import 'laser_divider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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

  Color _getStatColor(StatType type) {
    switch (type) {
      case StatType.stamina:
        return const Color(0xFF00D2FF); 
      case StatType.strength:
        return const Color(0xFF2979FF); 
      case StatType.immunity:
        return const Color(0xFF26A69A); 
      case StatType.intelligence:
        return const Color(0xFF42A5F5); 
      case StatType.discipline:
        return const Color(0xFFFFD54F); 
    }
  }

  IconData _getStatIcon(StatType type) {
    switch (type) {
      case StatType.stamina:
        return Icons.directions_run;
      case StatType.strength:
        return Icons.fitness_center;
      case StatType.immunity:
        return Icons.shield;
      case StatType.intelligence:
        return Icons.psychology;
      case StatType.discipline:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final double xpPercent = provider.characterXp / provider.characterNextLevelXp;
    final primaryColor = _getThemePrimaryColor(provider.activeThemeIndex);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Holographic Hero Diagnostic Card
          GlassHudCard(
            borderColor: primaryColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    // Glowing HUD Scan Circle
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ],
                        color: primaryColor.withOpacity(0.06),
                      ),
                      child: Icon(
                        Icons.bolt,
                        size: 32,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.playerName.toUpperCase(),
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            provider.playerClass.toUpperCase(),
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildProfileBadge(provider.playerRank.toUpperCase(), primaryColor),
                              const SizedBox(width: 6),
                              _buildProfileBadge(provider.playerTitle.toUpperCase(), Colors.white60),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                
                // Animated overall level progress bar
                HudProgressBar(
                  progress: xpPercent,
                  label: 'OVERALL LEVEL ${provider.characterLevel}',
                  valueText: '${provider.characterXp.toStringAsFixed(0)} / ${provider.characterNextLevelXp.toStringAsFixed(0)} XP',
                  color: primaryColor,
                ),
                
                const SizedBox(height: 16),
                
                // High-tech Achievements Button
                HudButton(
                  label: 'SYSTEM LOG ACHIEVEMENTS',
                  isSecondary: true,
                  icon: Icons.workspace_premium,
                  color: primaryColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Neon Laser Divider
          const LaserDivider(height: 16, thickness: 1.5),
          const SizedBox(height: 4),

          // HUD Tabs Selection
          DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  indicatorColor: primaryColor,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: GoogleFonts.orbitron(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                  tabs: const [
                    Tab(text: 'ATTRIBUTES'),
                    Tab(text: 'EQUIPMENT'),
                  ],
                ),
                SizedBox(
                  height: 410,
                  child: TabBarView(
                    children: [
                      // Attributes List inside Glass Cards
                      ListView.separated(
                        padding: const EdgeInsets.only(top: 14, bottom: 24),
                        itemCount: provider.stats.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final statType = StatType.values[index];
                          final stat = provider.stats[statType]!;
                          final color = _getStatColor(statType);
                          final icon = _getStatIcon(statType);
                          final double statXpPercent = stat.xp / stat.nextLevelXp;

                          return GlassHudCard(
                            borderColor: color.withOpacity(0.5),
                            cornerRadius: 6.0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: color.withOpacity(0.5), width: 1.0),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(icon, size: 16, color: color),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            statType.name.toUpperCase(),
                                            style: GoogleFonts.orbitron(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            statType.description,
                                            style: GoogleFonts.rajdhani(
                                              fontSize: 10,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'LVL ${stat.level}',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                HudProgressBar(
                                  progress: statXpPercent,
                                  label: 'SUB-XP PROGRESSION',
                                  valueText: '${(statXpPercent * 100).toStringAsFixed(0)}%',
                                  color: color,
                                  height: 6.0,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Equipment Inventory Cards
                      ListView.separated(
                        padding: const EdgeInsets.only(top: 14, bottom: 24),
                        itemCount: provider.equipment.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final eq = provider.equipment[index];
                          final isLocked = provider.characterLevel < eq.unlockedLevel;

                          return GlassHudCard(
                            borderColor: eq.isEquipped ? primaryColor : Colors.grey.shade900,
                            padding: const EdgeInsets.all(12),
                            cornerRadius: 6,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isLocked
                                          ? Colors.grey.shade800
                                          : (eq.isEquipped ? primaryColor : Colors.white24),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    color: eq.isEquipped
                                        ? primaryColor.withOpacity(0.08)
                                        : Colors.transparent,
                                  ),
                                  child: Icon(
                                    isLocked ? Icons.lock : Icons.shield_moon_outlined,
                                    color: isLocked ? Colors.grey : primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        eq.name.toUpperCase(),
                                        style: GoogleFonts.orbitron(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isLocked ? Colors.grey : Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isLocked
                                            ? 'Unlocks at Level ${eq.unlockedLevel}'
                                            : '${eq.description} (${eq.statBonusDescription})',
                                        style: GoogleFonts.rajdhani(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isLocked ? Colors.grey.shade600 : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLocked)
                                  HudButton(
                                    label: eq.isEquipped ? 'REMOVE' : 'EQUIP',
                                    isSecondary: !eq.isEquipped,
                                    color: eq.isEquipped ? Colors.redAccent : primaryColor,
                                    onPressed: () {
                                      provider.toggleEquipment(eq.id);
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.8),
      ),
      child: Text(
        text,
        style: GoogleFonts.orbitron(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
