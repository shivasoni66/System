import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/hud_components.dart';
import 'laser_divider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final primaryColor = _getThemePrimaryColor(gameProvider.activeThemeIndex);

    final now = DateTime.now();
    final List<DateTime> dates = [];
    for (int i = 34; i >= 0; i--) {
      dates.add(now.subtract(Duration(days: i)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Holographic contribution matrix card
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 12),
            child: Text(
              '// SYSTEM MATRIX (TACTICAL LOG)',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF80D8FF),
                letterSpacing: 1.5,
              ),
            ),
          ),
          GlassHudCard(
            borderColor: primaryColor,
            padding: const EdgeInsets.all(16),
            cornerRadius: 6,
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final dateStr = _formatDate(date);
                    final status = gameProvider.contributionHistory[dateStr];

                    Color cellColor = const Color(0xFF121B3A).withOpacity(0.5); 
                    if (status == 'completed') {
                      cellColor = primaryColor; 
                    } else if (status == 'partial') {
                      cellColor = const Color(0xFF2979FF); 
                    } else if (status == 'failed') {
                      cellColor = const Color(0xFFB0121E).withOpacity(0.6); 
                    }

                    return Tooltip(
                      message: '${date.day}/${date.month}: ${status ?? "No Records"}',
                      child: Container(
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: status != null ? Colors.white24 : Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('COMPLETED', primaryColor),
                    const SizedBox(width: 12),
                    _buildLegendItem('PARTIAL', const Color(0xFF2979FF)),
                    const SizedBox(width: 12),
                    _buildLegendItem('FAILED', const Color(0xFFB0121E).withOpacity(0.6)),
                    const SizedBox(width: 12),
                    _buildLegendItem('IDLE', const Color(0xFF121B3A).withOpacity(0.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const LaserDivider(height: 16, thickness: 1.5),
          const SizedBox(height: 4),

          // Diagnostic Summary grid
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 12),
            child: Text(
              '// SENSOR ANALYSIS READOUTS',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF80D8FF),
                letterSpacing: 1.5,
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard('TOTAL XP', '${gameProvider.totalXpEarned} XP', Icons.bolt, primaryColor),
              _buildStatCard('RESOLVED', '${gameProvider.questsCompletedCount}', Icons.task_alt, Colors.green),
              _buildStatCard('DEBUFFS CLEANSED', '${gameProvider.punishmentsResolvedCount}', Icons.healing, const Color(0xFF2979FF)),
              _buildStatCard('SUCCESS RATE', '${gameProvider.successRate.toStringAsFixed(1)}%', Icons.show_chart, Colors.teal),
              _buildStatCard('LONGEST STREAK', '🔥 ${gameProvider.longestStreak} D', Icons.local_fire_department, Colors.orange),
              _buildStatCard('DAYS ACTIVE', '${gameProvider.totalDaysPlayed} D', Icons.calendar_month, Colors.amber),
              _buildStatCard('WILLPOWER SCORE', '${gameProvider.disciplineScore}', Icons.workspace_premium, const Color(0xFFFFD54F)),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.orbitron(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassHudCard(
      borderColor: const Color(0xFF1B264A),
      cornerRadius: 6,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
