import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models.dart';
import '../widgets/hud_components.dart';
import 'laser_divider.dart';

class QuestBoardScreen extends StatefulWidget {
  const QuestBoardScreen({super.key});

  @override
  State<QuestBoardScreen> createState() => _QuestBoardScreenState();
}

class _QuestBoardScreenState extends State<QuestBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  Color _getDifficultyColor(QuestDifficulty diff) {
    switch (diff) {
      case QuestDifficulty.easy:
        return const Color(0xFF26A69A);
      case QuestDifficulty.medium:
        return const Color(0xFF29B6F6);
      case QuestDifficulty.hard:
        return const Color(0xFF2979FF);
      case QuestDifficulty.legendary:
        return const Color(0xFF00D2FF);
    }
  }

  void _showAddQuestBottomSheet(BuildContext context, Color primaryColor) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    StatType selectedStat = StatType.discipline;
    QuestDifficulty selectedDifficulty = QuestDifficulty.medium;
    QuestType questType = QuestType.daily;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Allow glass blur to draw
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GlassHudCard(
              borderColor: primaryColor,
              cornerRadius: 16.0,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'FORGE CUSTOM QUEST',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: GoogleFonts.exo2(color: Colors.white),
                        decoration: _buildInputDecoration('QUEST TITLE', Icons.edit, primaryColor),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Enter quest title' : null,
                        onSaved: (value) => title = value!.trim(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        style: GoogleFonts.exo2(color: Colors.white),
                        maxLines: 2,
                        decoration: _buildInputDecoration('QUEST DESCRIPTION', Icons.description, primaryColor),
                        onSaved: (value) => description = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<QuestType>(
                        dropdownColor: const Color(0xFF0A0F24),
                        value: questType,
                        decoration: _buildInputDecoration('QUEST TYPE', Icons.layers, primaryColor),
                        items: [
                          DropdownMenuItem(
                            value: QuestType.daily,
                            child: Text('Daily Habit (Resets daily)', style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          DropdownMenuItem(
                            value: QuestType.custom,
                            child: Text('One-time Custom Quest', style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              questType = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<StatType>(
                        dropdownColor: const Color(0xFF0A0F24),
                        value: selectedStat,
                        decoration: _buildInputDecoration('TARGET ATTRIBUTE', Icons.bar_chart, primaryColor),
                        items: StatType.values.map((stat) {
                          return DropdownMenuItem(
                            value: stat,
                            child: Text(
                              stat.name.toUpperCase(),
                              style: GoogleFonts.orbitron(color: _getStatColor(stat), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedStat = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<QuestDifficulty>(
                        dropdownColor: const Color(0xFF0A0F24),
                        value: selectedDifficulty,
                        decoration: _buildInputDecoration('DIFFICULTY LEVEL', Icons.bolt, primaryColor),
                        items: QuestDifficulty.values.map((diff) {
                          return DropdownMenuItem(
                            value: diff,
                            child: Text(
                              '${diff.name.toUpperCase()} (+${diff.xpReward.toStringAsFixed(0)} XP)',
                              style: GoogleFonts.orbitron(color: _getDifficultyColor(diff), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedDifficulty = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      HudButton(
                        label: 'SUMMON QUEST',
                        color: primaryColor,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            
                            Provider.of<GameProvider>(context, listen: false).addCustomQuest(
                              title: title,
                              description: description,
                              selectedStat: selectedStat,
                              difficulty: selectedDifficulty,
                              type: questType,
                            );

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: primaryColor,
                                content: Text(
                                  'Quest "$title" forged successfully in the SYSTEM!',
                                  style: GoogleFonts.orbitron(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon, Color primaryColor) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.orbitron(
        color: Colors.grey,
        fontSize: 10,
        letterSpacing: 1.0,
      ),
      prefixIcon: Icon(icon, color: primaryColor, size: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.2), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _buildQuestList(List<Quest> quests, Color primaryColor, GameProvider provider, {bool isSpecial = false, bool isDailies = false}) {
    Quest? strengthTrainingQuest;
    List<Quest> filteredQuests = [];

    if (isDailies) {
      for (var q in quests) {
        if (q.id == 'default_strength_training') {
          strengthTrainingQuest = q;
        } else {
          filteredQuests.add(q);
        }
      }
    } else {
      filteredQuests = quests;
    }

    if (quests.isEmpty && strengthTrainingQuest == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 48, color: primaryColor.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'NO ACTIVE OBJECTIVES DETECTED',
              style: GoogleFonts.orbitron(
                color: Colors.grey,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (strengthTrainingQuest != null)
            _buildStrengthTrainingCard(strengthTrainingQuest, primaryColor, provider),
          
          if (strengthTrainingQuest != null && filteredQuests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    '// OTHER SUB-HABITS',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: LaserDivider(height: 8, thickness: 1)),
                ],
              ),
            ),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: filteredQuests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final quest = filteredQuests[index];
              final isCompleted = quest.isCompleted;
              final isBoss = quest.isBoss;
              final diffColor = _getDifficultyColor(quest.difficulty);

              return GlassHudCard(
                borderColor: isCompleted
                    ? Colors.green
                    : (isBoss ? primaryColor : primaryColor.withOpacity(0.35)),
                padding: const EdgeInsets.all(0),
                cornerRadius: 6,
                child: Theme(
                  data: ThemeData.dark().copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    collapsedIconColor: isCompleted ? Colors.green : primaryColor,
                    iconColor: isCompleted ? Colors.green : primaryColor,
                    title: Row(
                      children: [
                        // Holographic checkbox
                        InkWell(
                          onTap: () {
                            if (isCompleted) {
                              provider.undoQuestCompletion(quest.id);
                            } else {
                              final ok = provider.completeQuest(quest.id);
                              if (ok) {
                                _showLevelUpBanner(context, quest, primaryColor);
                              }
                            }
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green.withOpacity(0.12) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isCompleted ? Colors.green : primaryColor,
                                width: 1.8,
                              ),
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.green,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isBoss) ...[
                                    const Icon(Icons.security, size: 10, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      'BOSS ',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: diffColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: diffColor.withOpacity(0.5), width: 0.5),
                                    ),
                                    child: Text(
                                      quest.difficulty.name.toUpperCase(),
                                      style: GoogleFonts.orbitron(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: diffColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (quest.type == QuestType.daily && quest.streak > 0)
                                    Text(
                                      '🔥 ${quest.streak} STREAK',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                quest.title.toUpperCase(),
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? Colors.grey : Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                children: quest.rewards.entries.map((entry) {
                                  final sType = entry.key;
                                  final sVal = entry.value;
                                  final sColor = _getStatColor(sType);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: sColor.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_getStatIcon(sType), size: 10, color: sColor),
                                        const SizedBox(width: 3),
                                        Text(
                                          '+${sVal.toStringAsFixed(0)} ${sType.name.toUpperCase()}',
                                          style: GoogleFonts.rajdhani(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: sColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Divider(color: Color(0xFF1B264A)),
                            const SizedBox(height: 6),
                            Text(
                              'QUEST MISSION:',
                              style: GoogleFonts.orbitron(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              quest.description.isNotEmpty ? quest.description : 'No quest files available.',
                              style: GoogleFonts.exo2(fontSize: 12, color: Colors.white70),
                            ),
                            if (quest.badgeReward != null) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.workspace_premium, size: 14, color: Colors.amber),
                                  const SizedBox(width: 6),
                                  Text(
                                    'SPECIAL UNLOCK: ${quest.badgeReward}',
                                    style: GoogleFonts.orbitron(fontSize: 9, color: Colors.amber, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                            if (quest.type == QuestType.custom) ...[
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                  onPressed: () {
                                    provider.deleteQuest(quest.id);
                                  },
                                  icon: const Icon(Icons.delete, size: 16),
                                  label: Text('DISMANTLE', style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ],
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
    );
  }

  Widget _buildStrengthTrainingCard(Quest quest, Color primaryColor, GameProvider provider) {
    final pushups = quest.pushupsProgress ?? 0;
    final situps = quest.situpsProgress ?? 0;
    final squats = quest.squatsProgress ?? 0;
    final running = quest.runningProgress ?? 0.0;

    return GlassHudCard(
      borderColor: primaryColor,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      cornerRadius: 6.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryColor, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'MISSION INFO',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              '[Daily Quest: Strength Training has arrived.]',
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                shadows: [
                  Shadow(color: primaryColor.withOpacity(0.4), blurRadius: 4)
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const LaserDivider(height: 12, thickness: 1),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'OBJECTIVES',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildWorkoutGoalItem('Push-ups', pushups, 100, 'pushups', provider, primaryColor),
          const SizedBox(height: 10),
          _buildWorkoutGoalItem('Sit-ups', situps, 100, 'situps', provider, primaryColor),
          const SizedBox(height: 10),
          _buildWorkoutGoalItem('Squats', squats, 100, 'squats', provider, primaryColor),
          const SizedBox(height: 10),
          _buildWorkoutGoalItem('Running', running, 10.0, 'running', provider, primaryColor, isKm: true),
          const SizedBox(height: 16),
          const LaserDivider(height: 12, thickness: 1),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'WARNING: Failure to complete the daily quest will result in an appropriate penalty.',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 9,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutGoalItem(
    String title,
    num current,
    num target,
    String type,
    GameProvider provider,
    Color primaryColor, {
    bool isKm = false,
  }) {
    final isDone = current >= target;
    final displayVal = isKm ? '${current.toStringAsFixed(0)}/${target.toStringAsFixed(0)}km' : '$current/$target';

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.remove_circle_outline, size: 16, color: primaryColor.withOpacity(0.6)),
              onPressed: () => provider.incrementStrengthTrainingGoal(type, isKm ? -1.0 : -10.0),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.add_circle_outline, size: 16, color: primaryColor),
              onPressed: () => provider.incrementStrengthTrainingGoal(type, isKm ? 1.0 : 10.0),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: Text(
            '[$displayVal]',
            textAlign: TextAlign.right,
            style: GoogleFonts.orbitron(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDone ? Colors.green : primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isDone ? Colors.green.withOpacity(0.12) : Colors.transparent,
            border: Border.all(
              color: isDone ? Colors.green : primaryColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: isDone
              ? const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.green,
                )
              : null,
        ),
      ],
    );
  }

  void _showLevelUpBanner(BuildContext context, Quest quest, Color primaryColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.stars, color: Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'QUEST RESOLVED: +${quest.rewards.values.fold(0.0, (prev, val) => prev + val).toStringAsFixed(0)} XP allocated.',
                style: GoogleFonts.orbitron(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final primaryColor = _getThemePrimaryColor(gameProvider.activeThemeIndex);

    final dailyAndBossList = [
      ...gameProvider.bossQuests.where((q) => q.type == QuestType.daily),
      ...gameProvider.dailyQuests,
    ];

    final specialAndBossList = [
      ...gameProvider.bossQuests.where((q) => q.type == QuestType.weekly || q.type == QuestType.monthly),
      ...gameProvider.specialQuests,
    ];

    return Column(
      children: [
        // Tactical Protocol Quote Card
        GlassHudCard(
          borderColor: primaryColor.withOpacity(0.5),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(12),
          cornerRadius: 6.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '// RADAR CONSOLE PROTOCOL',
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '"${gameProvider.dailyQuote}"',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
          tabs: const [
            Tab(text: 'DAILIES'),
            Tab(text: 'CUSTOMS'),
            Tab(text: 'SPECIALS'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildQuestList(dailyAndBossList, primaryColor, gameProvider, isDailies: true),
              _buildQuestList(gameProvider.customQuests, primaryColor, gameProvider),
              _buildQuestList(specialAndBossList, primaryColor, gameProvider, isSpecial: true),
            ],
          ),
        ),
        // Forge button using HudButton
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: HudButton(
            label: 'FORGE CUSTOM QUEST',
            icon: Icons.add_circle_outline,
            color: primaryColor,
            onPressed: () => _showAddQuestBottomSheet(context, primaryColor),
          ),
        ),
      ],
    );
  }
}
