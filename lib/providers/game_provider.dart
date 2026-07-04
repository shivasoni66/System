import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';

class GameProvider extends ChangeNotifier {
  // Stats
  final Map<StatType, Stat> _stats = {
    StatType.stamina: Stat(type: StatType.stamina),
    StatType.strength: Stat(type: StatType.strength),
    StatType.immunity: Stat(type: StatType.immunity),
    StatType.intelligence: Stat(type: StatType.intelligence),
    StatType.discipline: Stat(type: StatType.discipline),
  };

  // Profile Details
  String _playerName = 'Shiva';
  String _playerClass = 'Self Improver';
  int _characterLevel = 8; 
  double _characterXp = 2350.0; 

  // Quests, Punishments, and Notifications
  List<Quest> _quests = [];
  List<Punishment> _punishments = [];
  List<NotificationAlert> _notifications = [];

  // Achievements
  List<Achievement> _achievements = [];

  // Equipment
  List<Equipment> _equipment = [];

  // Calendar Contribution Graph (YYYY-MM-DD -> status)
  Map<String, String> _contributionHistory = {};

  // Settings
  bool _isSoundEnabled = true;
  int _activeThemeIndex = 0; // 0: Midnight Cobalt, 1: Deep Ocean, 2: Electric Cyan, 3: Sapphire Knight, 4: Neon Ice
  String _serverAddress = 'system-5jlk.onrender.com'; // Deployed Render backend server host

  // Metrics/Statistics
  int _totalXpEarned = 2350;
  int _questsCompletedCount = 0;
  int _punishmentsResolvedCount = 0;
  int _longestStreak = 0;
  int _totalDaysPlayed = 1;
  int _consecutiveCleanDays = 0;

  // Date of last reset check
  DateTime? _lastResetDate;

  // Async Initialization & Sync Service
  late Future<void> initialization;
  late SyncService _syncService;
  bool _isRemoteConnected = false;

  GameProvider() {
    _syncService = SyncService(
      getHost: () => _serverAddress,
      getPlayerName: () => _playerName,
      onStateReceived: (remoteState) {
        final remoteTotalXp = remoteState['totalXpEarned'] as int? ?? _totalXpEarned;
        if (remoteTotalXp != _totalXpEarned) {
          _parseStateFromJson(remoteState);
          _saveState(syncToRemote: false);
          notifyListeners();
        }
      },
      onConnectionStateChanged: (connected) {
        _isRemoteConnected = connected;
        if (connected) {
          _addNotification('SYSTEM DATALINK ACTIVE', 'Holographic WebSocket synchronization established.');
        } else {
          _addNotification('SYSTEM DATALINK OFFLINE', 'Running in Local Cache mode. Syncing on reconnect.');
        }
        notifyListeners();
      },
    );
    initialization = _loadState();
  }

  @override
  void dispose() {
    _syncService.disconnect();
    super.dispose();
  }

  // Sound triggering helper
  void _playSystemSound(SystemSoundType type) {
    if (_isSoundEnabled) {
      SystemSound.play(type);
    }
  }

  // Notification helpers
  void _addNotification(String title, String message) {
    final alert = NotificationAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + Random().nextInt(100).toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, alert);
    
    // Dispatch native system notification
    NotificationService().showInstantNotification(title: title, body: message);

    if (_notifications.length > 50) {
      _notifications.removeLast();
    }
  }

  void markAllNotificationsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    _saveState();
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _saveState();
    notifyListeners();
  }

  // Getters
  Map<StatType, Stat> get stats => _stats;
  String get playerName => _playerName;
  String get playerClass => _playerClass;
  int get characterLevel => _characterLevel;
  double get characterXp => _characterXp;
  double get characterNextLevelXp => _characterLevel * 300.0; 
  List<Quest> get quests => _quests;
  List<Punishment> get punishments => _punishments;
  List<NotificationAlert> get notifications => _notifications;
  List<Achievement> get achievements => _achievements;
  List<Equipment> get equipment => _equipment;
  Map<String, String> get contributionHistory => _contributionHistory;
  bool get isSoundEnabled => _isSoundEnabled;
  int get activeThemeIndex => _activeThemeIndex;
  String get serverAddress => _serverAddress;
  bool get isRemoteConnected => _isRemoteConnected;

  // Statistics getters
  int get totalXpEarned => _totalXpEarned;
  int get questsCompletedCount => _questsCompletedCount;
  int get punishmentsResolvedCount => _punishmentsResolvedCount;
  int get longestStreak => _longestStreak;
  int get totalDaysPlayed => _totalDaysPlayed;
  double get successRate {
    final totalDailyPossible = dailyQuests.length;
    if (totalDailyPossible == 0) return 100.0;
    final completedDaily = dailyQuests.where((q) => q.isCompleted).length;
    return (completedDaily / totalDailyPossible) * 100.0;
  }
  int get disciplineScore {
    final disciplineLvl = _stats[StatType.discipline]?.level ?? 1;
    final unlockedAchievementsCount = _achievements.where((a) => a.isUnlocked).length;
    return (disciplineLvl * 10) + (unlockedAchievementsCount * 15);
  }

  // Filtered Quests
  List<Quest> get dailyQuests =>
      _quests.where((q) => q.type == QuestType.daily && !q.isBoss).toList();
  List<Quest> get customQuests =>
      _quests.where((q) => q.type == QuestType.custom).toList();
  List<Quest> get specialQuests =>
      _quests.where((q) => (q.type == QuestType.weekly || q.type == QuestType.monthly) && !q.isBoss).toList();
  List<Quest> get bossQuests =>
      _quests.where((q) => q.isBoss).toList();
  List<Punishment> get activePunishments =>
      _punishments.where((p) => !p.isCleared).toList();
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).toList().length;

  // Dynamic Profile Computations
  String get playerRank {
    if (_characterLevel >= 30) return 'Legend';
    if (_characterLevel >= 15) return 'Elite';
    if (_characterLevel >= 5) return 'Disciplined';
    return 'Novice';
  }

  String get playerTitle {
    if (_characterLevel >= 50) return 'Mythic';
    if (_characterLevel >= 30) return 'Legend';
    if (_characterLevel >= 20) return 'Champion';
    if (_characterLevel >= 10) return 'Knight';
    if (_characterLevel >= 5) return 'Warrior';
    return 'Beginner';
  }

  // Multipliers from Equipped Gear
  double get _overallXpMultiplier {
    double mult = 1.0;
    for (var eq in _equipment) {
      if (eq.isEquipped) {
        if (eq.id == 'sword_of_discipline') mult += 0.10;
        if (eq.id == 'golden_armor') mult += 0.20;
      }
    }
    return mult;
  }

  double _getStatXpMultiplier(StatType type) {
    double mult = 1.0;
    for (var eq in _equipment) {
      if (eq.isEquipped) {
        if (type == StatType.intelligence && eq.id == 'scholars_book') mult += 0.10;
        if (type == StatType.immunity && eq.id == 'dragon_shield') mult += 0.15;
      }
    }
    return mult;
  }

  // Inspiring Quotes Pool
  final List<String> _quotes = [
    "The pain of discipline is less than the pain of regret.",
    "He who has a why to live can bear almost any how.",
    "First we make our habits, then our habits make us.",
    "You do not rise to the level of your goals. You fall to the level of your systems.",
    "Discipline is choosing between what you want now and what you want most.",
    "Great things are done by a series of small things brought together.",
    "Your future is created by what you do today, not tomorrow.",
    "Consistency is the true foundation of strength.",
    "Focus on the process, not the outcome.",
    "No man is free who cannot command himself."
  ];

  String get dailyQuote {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }

  // Updates the server endpoint address and reconnects the sync service
  void updateServerAddress(String newAddress) {
    if (newAddress.trim().isEmpty) return;
    _serverAddress = newAddress.trim();
    _saveState();
    
    // Re-establish WebSocket datalink connection
    _syncService.disconnect();
    _syncService.connect();
    notifyListeners();
  }

  // Initializes a new player profile on first start
  Future<void> initializePlayerProfile(String name, String chosenClass) async {
    _playerName = name.trim();
    _playerClass = chosenClass.trim();
    _characterLevel = 1; // Start at Level 1 on first initialization
    _characterXp = 0.0;
    _totalXpEarned = 0;
    
    // Reset all attributes
    _stats.forEach((key, value) {
      value.level = 1;
      value.xp = 0.0;
    });
    _quests.clear();
    _punishments.clear();
    _notifications.clear();
    _contributionHistory.clear();

    _setupDefaultQuests();
    _initializeAchievements();
    _initializeEquipment();
    _lastResetDate = DateTime.now();

    _addNotification('SYSTEM INITIALIZED', 'Welcome $_playerName! Specialization $_playerClass registered.');
    
    // Re-establish WebSocket datalink connection under the new name
    _syncService.disconnect();
    _syncService.connect();
    
    await _saveState();
    notifyListeners();
  }

  // Core Progression Loops
  void _addCharacterXp(double amount) {
    final boostedAmount = amount * _overallXpMultiplier;
    _characterXp += boostedAmount;
    _totalXpEarned += boostedAmount.round();

    while (_characterXp >= characterNextLevelXp) {
      _characterXp -= characterNextLevelXp;
      _characterLevel++;
      _playSystemSound(SystemSoundType.click); 
      _addNotification(
        'CHARACTER LEVEL UP!',
        'SYSTEM notification: Shiva Leveled up to Level $_characterLevel! Custom titles updated.',
      );
      _checkAchievements();
    }
  }

  // Daily workout sub-goal completion increments
  void incrementStrengthTrainingGoal(String goalType, double amount) {
    final index = _quests.indexWhere((q) => q.id == 'default_strength_training');
    if (index == -1) return;

    final quest = _quests[index];
    if (quest.isCompleted) return;

    quest.pushupsProgress ??= 0;
    quest.situpsProgress ??= 0;
    quest.squatsProgress ??= 0;
    quest.runningProgress ??= 0.0;

    if (goalType == 'pushups') {
      quest.pushupsProgress = (quest.pushupsProgress! + amount.toInt()).clamp(0, 100);
    } else if (goalType == 'situps') {
      quest.situpsProgress = (quest.situpsProgress! + amount.toInt()).clamp(0, 100);
    } else if (goalType == 'squats') {
      quest.squatsProgress = (quest.squatsProgress! + amount.toInt()).clamp(0, 100);
    } else if (goalType == 'running') {
      quest.runningProgress = (quest.runningProgress! + amount).clamp(0.0, 10.0);
    }

    if (quest.pushupsProgress == 100 &&
        quest.situpsProgress == 100 &&
        quest.squatsProgress == 100 &&
        quest.runningProgress! >= 10.0) {
      completeQuest('default_strength_training');
    } else {
      _saveState();
      notifyListeners();
    }
  }

  // Check Quests
  bool completeQuest(String id) {
    final index = _quests.indexWhere((q) => q.id == id);
    if (index == -1 || _quests[index].isCompleted) return false;

    final quest = _quests[index];
    quest.isCompleted = true;
    quest.completedAt = DateTime.now();

    if (id == 'default_strength_training') {
      quest.pushupsProgress = 100;
      quest.situpsProgress = 100;
      quest.squatsProgress = 100;
      quest.runningProgress = 10.0;
    }

    if (quest.type == QuestType.daily) {
      quest.streak++;
      if (quest.streak > _longestStreak) {
        _longestStreak = quest.streak;
      }
    }

    _questsCompletedCount++;
    _playSystemSound(SystemSoundType.click);

    double totalRewardXp = 0;
    quest.rewards.forEach((statType, xpAmount) {
      final stat = _stats[statType]!;
      final boostedStatXp = xpAmount * _getStatXpMultiplier(statType);
      final statLeveledUp = stat.addXp(boostedStatXp);
      totalRewardXp += boostedStatXp;

      if (statLeveledUp) {
        _addNotification(
          'STAT LEVEL UP!',
          'Your ${statType.name} reached Level ${stat.level}!',
        );
      }
    });

    _addCharacterXp(totalRewardXp * 0.5);

    _checkAchievements();
    _saveState();
    notifyListeners();
    return true;
  }

  void undoQuestCompletion(String id) {
    final index = _quests.indexWhere((q) => q.id == id);
    if (index == -1 || !_quests[index].isCompleted) return;

    final quest = _quests[index];
    quest.isCompleted = false;
    quest.completedAt = null;

    if (id == 'default_strength_training') {
      quest.pushupsProgress = 0;
      quest.situpsProgress = 0;
      quest.squatsProgress = 0;
      quest.runningProgress = 0.0;
    }

    if (quest.type == QuestType.daily && quest.streak > 0) {
      quest.streak--;
    }

    if (_questsCompletedCount > 0) _questsCompletedCount--;

    double totalDeductXp = 0;
    quest.rewards.forEach((statType, xpAmount) {
      final stat = _stats[statType]!;
      final boostedStatXp = xpAmount * _getStatXpMultiplier(statType);
      stat.xp -= boostedStatXp;
      if (stat.xp < 0) {
        if (stat.level > 1) {
          stat.level--;
          stat.xp = (stat.level * 100.0) + stat.xp;
        } else {
          stat.xp = 0.0;
        }
      }
      totalDeductXp += boostedStatXp;
    });

    _characterXp -= (totalDeductXp * 0.5);
    if (_characterXp < 0) {
      if (_characterLevel > 1) {
        _characterLevel--;
        _characterXp = (_characterLevel * 300.0) + _characterXp;
      } else {
        _characterXp = 0.0;
      }
    }

    _saveState();
    notifyListeners();
  }

  // Create Custom Quest
  void addCustomQuest({
    required String title,
    required String description,
    required StatType selectedStat,
    required QuestDifficulty difficulty,
    required QuestType type,
  }) {
    final xpReward = difficulty.xpReward;
    final Map<StatType, double> rewards = {
      selectedStat: xpReward,
    };
    if (selectedStat != StatType.discipline) {
      rewards[StatType.discipline] = (xpReward * 0.2).roundToDouble();
    }

    final quest = Quest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      difficulty: difficulty,
      rewards: rewards,
      createdAt: DateTime.now(),
    );
    _quests.add(quest);
    _addNotification('NEW QUEST ADDED', 'Quest "${quest.title}" forged in the SYSTEM.');
    _saveState();
    notifyListeners();
  }

  void deleteQuest(String id) {
    _quests.removeWhere((q) => q.id == id);
    _saveState();
    notifyListeners();
  }

  // Resolve Penalty
  void completePunishment(String id) {
    final index = _punishments.indexWhere((p) => p.id == id);
    if (index == -1 || _punishments[index].isCleared) return;

    final punishment = _punishments[index];
    punishment.isCleared = true;
    _punishmentsResolvedCount++;

    _addCharacterXp(punishment.penaltyXp * 0.25);
    _addNotification('DEBUFF CLEANSED', 'Resolved: ${punishment.title}!');

    _saveState();
    notifyListeners();
  }

  // Equip Gear
  void toggleEquipment(String id) {
    final index = _equipment.indexWhere((eq) => eq.id == id);
    if (index == -1) return;

    final eq = _equipment[index];
    if (eq.isEquipped) {
      eq.isEquipped = false;
      _addNotification('EQUIPMENT REMOVED', 'Unequipped ${eq.name}.');
    } else {
      eq.isEquipped = true;
      _addNotification('EQUIPMENT EQUIPPED', 'Equipped ${eq.name}: ${eq.statBonusDescription}');
    }

    _saveState();
    notifyListeners();
  }

  // Sound Config
  void toggleSound(bool enabled) {
    _isSoundEnabled = enabled;
    _saveState();
    notifyListeners();
  }

  // Change active theme variant
  void changeTheme(int index) {
    if (index >= 0 && index < 5) {
      _activeThemeIndex = index;
      _saveState();
      notifyListeners();
    }
  }

  // Roll Bosses
  final List<Map<String, dynamic>> _dailyBossPool = [
    {
      'title': 'Daily Boss: Code Forge',
      'description': 'Code or study development concepts for 2 solid hours without distraction.',
      'rewards': {StatType.intelligence: 100.0, StatType.discipline: 50.0},
    },
    {
      'title': 'Daily Boss: Endurance Overlord',
      'description': 'Go for a rigorous 5-kilometer outdoor run or cardiovascular session.',
      'rewards': {StatType.stamina: 100.0, StatType.discipline: 50.0},
    },
    {
      'title': 'Daily Boss: Calisthenics Fortress',
      'description': 'Perform a high-volume workout consisting of 100 pushups, 100 squats, and 50 pullups.',
      'rewards': {StatType.strength: 100.0, StatType.discipline: 50.0},
    },
  ];

  void rollDailyBoss() {
    final random = Random();
    final template = _dailyBossPool[random.nextInt(_dailyBossPool.length)];

    _quests.removeWhere((q) => q.isBoss && q.type == QuestType.daily);

    final boss = Quest(
      id: 'daily_boss_' + DateTime.now().millisecondsSinceEpoch.toString(),
      title: template['title'],
      description: template['description'],
      type: QuestType.daily,
      difficulty: QuestDifficulty.legendary,
      rewards: template['rewards'] as Map<StatType, double>,
      isBoss: true,
      createdAt: DateTime.now(),
    );
    _quests.add(boss);
    _addNotification('DAILY BOSS SPAWNED', 'Daily Boss has emerged: "${boss.title}"!');
    _saveState();
  }

  void rollWeeklyQuest() {
    _quests.removeWhere((q) => q.type == QuestType.weekly);

    final weeklyBoss = Quest(
      id: 'weekly_boss_' + DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Weekly Boss: System Architect',
      description: 'Design, write code, and completely compile a backend project database or major architecture component.',
      type: QuestType.weekly,
      difficulty: QuestDifficulty.legendary,
      rewards: {
        StatType.intelligence: 200.0,
        StatType.discipline: 100.0,
        StatType.stamina: 100.0,
      },
      isBoss: true,
      badgeReward: 'Epic Badge',
      createdAt: DateTime.now(),
    );
    _quests.add(weeklyBoss);
    _addNotification('WEEKLY RAID BOSS ACTIVE', 'The Sunday Raid Boss appeared: "${weeklyBoss.title}"!');
    _saveState();
    notifyListeners();
  }

  void rollMonthlyQuest() {
    _quests.removeWhere((q) => q.type == QuestType.monthly);

    final monthlyBoss = Quest(
      id: 'monthly_boss_' + DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Monthly Raid: Willpower Ascendant',
      description: 'Drink 3L water, sleep 8 hours, and perform physical exercises every single day for a month.',
      type: QuestType.monthly,
      difficulty: QuestDifficulty.legendary,
      rewards: {
        StatType.immunity: 400.0,
        StatType.discipline: 300.0,
        StatType.strength: 200.0,
      },
      isBoss: true,
      badgeReward: 'Legendary Badge',
      createdAt: DateTime.now(),
    );
    _quests.add(monthlyBoss);
    _addNotification('MONTHLY RAID BOSS ACTIVE', 'Monthly boss has surfaced: "${monthlyBoss.title}"!');
    _saveState();
    notifyListeners();
  }

  // Daily reset check
  void checkDailyReset() {
    final now = DateTime.now();
    if (_lastResetDate == null) {
      _lastResetDate = now;
      _saveState();
      return;
    }

    final isNewDay = _lastResetDate!.year != now.year ||
        _lastResetDate!.month != now.month ||
        _lastResetDate!.day != now.day;

    if (isNewDay) {
      performDailyReset();
    }
  }

  // Roll rollover daily reset logic
  void performDailyReset() {
    final now = DateTime.now();
    List<Quest> failedDailies = [];

    // 1. Log contribution grid
    final dateStr = '${_lastResetDate!.year}-${_lastResetDate!.month.toString().padLeft(2, '0')}-${_lastResetDate!.day.toString().padLeft(2, '0')}';
    final dailyList = _quests.where((q) => q.type == QuestType.daily).toList();
    if (dailyList.isEmpty) {
      _contributionHistory[dateStr] = 'completed';
    } else {
      final completed = dailyList.where((q) => q.isCompleted).length;
      if (completed == dailyList.length) {
        _contributionHistory[dateStr] = 'completed'; 
        _consecutiveCleanDays++;
      } else if (completed > 0) {
        _contributionHistory[dateStr] = 'partial'; 
        _consecutiveCleanDays = 0;
      } else {
        _contributionHistory[dateStr] = 'failed'; 
        _consecutiveCleanDays = 0;
      }
    }

    // 2. Identify failed dailies
    for (var quest in _quests) {
      if (quest.type == QuestType.daily && !quest.isCompleted && !quest.isPunishmentTriggered) {
        failedDailies.add(quest);
        quest.isPunishmentTriggered = true;
      }
    }

    // 3. Apply punishments
    if (failedDailies.isNotEmpty) {
      for (var failed in failedDailies) {
        failed.streak = 0;

        String punishmentTitle = '';
        String punishmentDesc = '';
        double penalty = failed.isBoss ? 150.0 : 40.0;

        if (failed.id == 'default_strength_training') {
          punishmentTitle = 'Penalty Quest: Strength Training Deficit';
          punishmentDesc = 'Failed the core SYSTEM workout quest. You are locked in the Penalty Dungeon! Do 100 pushups, 100 squats, and run 5km to cleanse.';
        } else if (failed.rewards.containsKey(StatType.strength)) {
          punishmentTitle = 'Strength Debuff: Muscle Atrophy';
          punishmentDesc = 'Failed "${failed.title}". Do 40 pushups to recover strength!';
        } else if (failed.rewards.containsKey(StatType.stamina)) {
          punishmentTitle = 'Stamina Debuff: Sloth Curse';
          punishmentDesc = 'Failed "${failed.title}". Run 3.0 kilometers to break the debuff!';
        } else {
          punishmentTitle = 'Willpower Debuff: System Failure';
          punishmentDesc = 'Failed "${failed.title}". Do 25 burpees right now!';
        }

        final punishment = Punishment(
          id: 'punish_' + DateTime.now().millisecondsSinceEpoch.toString() + '_' + Random().nextInt(100).toString(),
          title: punishmentTitle,
          description: punishmentDesc,
          penaltyXp: penalty,
          createdAt: DateTime.now(),
        );

        _punishments.add(punishment);

        _characterXp -= penalty;
        if (_characterXp < 0) {
          if (_characterLevel > 1) {
            _characterLevel--;
            _characterXp = (_characterLevel * 300.0) + _characterXp;
          } else {
            _characterXp = 0.0;
          }
        }

        failed.rewards.forEach((statType, xpAmount) {
          final stat = _stats[statType]!;
          stat.xp -= xpAmount;
          if (stat.xp < 0) {
            if (stat.level > 1) {
              stat.level--;
              stat.xp = (stat.level * 100.0) + stat.xp;
            } else {
              stat.xp = 0.0;
            }
          }
        });
      }
      
      _playSystemSound(SystemSoundType.click); 
      _addNotification(
        'SYSTEM ERROR: INCOMPLETE OBJECTIVES',
        'Shiva, you failed daily objectives. Punishments applied and streaks broken.',
      );
    }

    for (var quest in _quests) {
      if (quest.type == QuestType.daily) {
        quest.isCompleted = false;
        quest.completedAt = null;
        quest.isPunishmentTriggered = false;
        if (quest.id == 'default_strength_training') {
          quest.pushupsProgress = 0;
          quest.situpsProgress = 0;
          quest.squatsProgress = 0;
          quest.runningProgress = 0.0;
        }
      }
    }

    _totalDaysPlayed++;
    _lastResetDate = now;

    rollDailyBoss();

    _checkAchievements();
    _saveState();
    notifyListeners();
  }

  // Achievement checkpoints
  void _checkAchievements() {
    bool unlockedAny = false;

    for (var ach in _achievements) {
      if (ach.isUnlocked) continue;

      bool trigger = false;
      switch (ach.id) {
        case 'first_quest':
          if (_questsCompletedCount >= 1) trigger = true;
          break;
        case 'seven_streak':
          if (_quests.any((q) => q.streak >= 7)) trigger = true;
          break;
        case 'thirty_streak':
          if (_quests.any((q) => q.streak >= 30)) trigger = true;
          break;
        case 'hundred_quests':
          if (_questsCompletedCount >= 100) trigger = true;
          break;
        case 'clean_week':
          if (_consecutiveCleanDays >= 7) trigger = true;
          break;
        case 'discipline_10':
          if ((_stats[StatType.discipline]?.level ?? 1) >= 10) trigger = true;
          break;
      }

      if (trigger) {
        ach.isUnlocked = true;
        ach.unlockedAt = DateTime.now();
        unlockedAny = true;
        _addNotification(
          'ACHIEVEMENT UNLOCKED!',
          'SYSTEM: Shiva unlocked "${ach.title}"! (${ach.description})',
        );
      }
    }

    if (unlockedAny) {
      _playSystemSound(SystemSoundType.click);
    }
  }

  // Setup default featured quests
  void _setupDefaultQuests() {
    _quests = [
      Quest(
        id: 'default_strength_training',
        title: 'Strength Training',
        description: 'WARNING: Failure to complete the daily quest will result in an appropriate penalty.',
        type: QuestType.daily,
        difficulty: QuestDifficulty.legendary,
        rewards: {
          StatType.stamina: 30.0,
          StatType.strength: 30.0,
          StatType.immunity: 20.0,
          StatType.discipline: 20.0,
        },
        pushupsProgress: 0,
        situpsProgress: 0,
        squatsProgress: 0,
        runningProgress: 0.0,
        createdAt: DateTime.now(),
      ),
      Quest(
        id: 'default_study',
        title: 'Mind Sharpening Habit',
        description: 'Study development or read for 30 minutes.',
        type: QuestType.daily,
        difficulty: QuestDifficulty.medium,
        rewards: {StatType.intelligence: 25.0, StatType.discipline: 10.0},
        createdAt: DateTime.now(),
      ),
    ];

    rollDailyBoss();
    rollWeeklyQuest();
    rollMonthlyQuest();
  }

  void _initializeAchievements() {
    _achievements = [
      Achievement(
        id: 'first_quest',
        title: 'First Quest Completed',
        description: 'Take your first step as a Self Improver by checking off a quest.',
      ),
      Achievement(
        id: 'seven_streak',
        title: 'Seven Day Streak',
        description: 'Maintain consistency. Keep a daily habit active for 7 days straight.',
      ),
      Achievement(
        id: 'thirty_streak',
        title: 'Thirty Day Streak',
        description: 'Habit Ascendant. Complete a daily habit for 30 consecutive days.',
      ),
      Achievement(
        id: 'hundred_quests',
        title: 'Hundred Quests Completed',
        description: 'Show iron resilience by finishing 100 quests in total.',
      ),
      Achievement(
        id: 'clean_week',
        title: 'No Punishments for One Week',
        description: 'Perfect discipline. Go 7 days without incurring any failed daily punishments.',
      ),
      Achievement(
        id: 'discipline_10',
        title: 'Discipline Level 10',
        description: 'Elevate your core will. Level up the Discipline attribute to Level 10.',
      ),
    ];
  }

  void _initializeEquipment() {
    _equipment = [
      Equipment(
        id: 'wooden_sword',
        name: 'Wooden Training Sword',
        description: 'A starter training sword to learn consistency.',
        statBonusDescription: '+5% Overall XP',
        unlockedLevel: 1,
      ),
      Equipment(
        id: 'scholars_book',
        name: "Scholar's Ancient Book",
        description: 'A study tome detailing system parameters.',
        statBonusDescription: '+10% Intelligence XP',
        unlockedLevel: 5,
      ),
      Equipment(
        id: 'sword_of_discipline',
        name: 'Sword of Discipline',
        description: 'A neon-tinted blade rewarding pure dedication.',
        statBonusDescription: '+10% Overall XP',
        unlockedLevel: 10,
      ),
      Equipment(
        id: 'dragon_shield',
        name: 'Iron Dragon Shield',
        description: 'A heavy recovery shield boosting health.',
        statBonusDescription: '+15% Immunity XP',
        unlockedLevel: 15,
      ),
      Equipment(
        id: 'golden_armor',
        name: 'Golden SYSTEM Armor',
        description: 'Gleaming legendary armor that glows in the dark.',
        statBonusDescription: '+20% Overall XP',
        unlockedLevel: 25,
      ),
    ];
  }

  // Parses state from a JSON Map
  void _parseStateFromJson(Map<String, dynamic> data) {
    if (data.containsKey('characterLevel')) {
      _playerName = data['playerName'] as String? ?? 'Shiva';
      _playerClass = data['playerClass'] as String? ?? 'Self Improver';
      _characterLevel = data['characterLevel'] as int? ?? 8;
      _characterXp = (data['characterXp'] as num? ?? 2350.0).toDouble();
      _isSoundEnabled = data['isSoundEnabled'] as bool? ?? true;
      _activeThemeIndex = data['activeThemeIndex'] as int? ?? 0;
      _serverAddress = data['serverAddress'] as String? ?? 'localhost:8080';

      _totalXpEarned = data['totalXpEarned'] as int? ?? 2350;
      _questsCompletedCount = data['questsCompletedCount'] as int? ?? 0;
      _punishmentsResolvedCount = data['punishmentsResolvedCount'] as int? ?? 0;
      _longestStreak = data['longestStreak'] as int? ?? 0;
      _totalDaysPlayed = data['totalDaysPlayed'] as int? ?? 1;
      _consecutiveCleanDays = data['consecutiveCleanDays'] as int? ?? 0;

      if (data['stats'] != null) {
        final Map<String, dynamic> decodedStats = data['stats'];
        decodedStats.forEach((key, value) {
          final typeIndex = int.tryParse(key);
          if (typeIndex != null && typeIndex < StatType.values.length) {
            _stats[StatType.values[typeIndex]] = Stat.fromJson(value);
          }
        });
      }

      if (data['contributionHistory'] != null) {
        final Map<String, dynamic> decodedHistory = data['contributionHistory'];
        _contributionHistory = decodedHistory.map((k, v) => MapEntry(k, v as String));
      }

      if (data['quests'] != null) {
        final List<dynamic> decodedQuests = data['quests'];
        _quests = decodedQuests.map((item) => Quest.fromJson(item)).toList();
      }

      if (data['punishments'] != null) {
        final List<dynamic> decodedPunishments = data['punishments'];
        _punishments = decodedPunishments.map((item) => Punishment.fromJson(item)).toList();
      }

      if (data['notifications'] != null) {
        final List<dynamic> decodedNotifications = data['notifications'];
        _notifications = decodedNotifications.map((item) => NotificationAlert.fromJson(item)).toList();
      }

      if (data['achievements'] != null) {
        final List<dynamic> decodedAchievements = data['achievements'];
        _achievements = decodedAchievements.map((item) => Achievement.fromJson(item)).toList();
      }

      if (data['equipment'] != null) {
        final List<dynamic> decodedEquipment = data['equipment'];
        _equipment = decodedEquipment.map((item) => Equipment.fromJson(item)).toList();
      }
      
      if (data['lastResetDate'] != null) {
        _lastResetDate = DateTime.parse(data['lastResetDate'] as String);
      }
    }
  }

  // Load state: Fetches local SharedPreferences, then connects and syncs via WebSockets
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Read server address configuration first
      _serverAddress = prefs.getString('serverAddress') ?? 'system-5jlk.onrender.com';

      // Connect WebSocket to Java backend
      _syncService.connect();

      // Setup default configurations first
      _setupDefaultQuests();
      _initializeAchievements();
      _initializeEquipment();
      _lastResetDate = DateTime.now();

      // Load instant local cache first
      final localDataStr = prefs.getString('local_player_state');
      if (localDataStr != null) {
        final decoded = jsonDecode(localDataStr) as Map<String, dynamic>;
        _parseStateFromJson(decoded);
      } else {
        _playerName = '';
      }
      
      checkDailyReset();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading state: $e");
      _setupDefaultQuests();
      _initializeAchievements();
      _initializeEquipment();
      notifyListeners();
    }
  }

  // Save state: writes to local cache, then pushes through WebSocket outbox
  Future<void> _saveState({bool syncToRemote = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cache server address
      await prefs.setString('serverAddress', _serverAddress);

      final Map<String, dynamic> stateMap = {
        'playerName': _playerName,
        'playerClass': _playerClass,
        'characterLevel': _characterLevel,
        'characterXp': _characterXp,
        'isSoundEnabled': _isSoundEnabled,
        'activeThemeIndex': _activeThemeIndex,
        'serverAddress': _serverAddress,
        'totalXpEarned': _totalXpEarned,
        'questsCompletedCount': _questsCompletedCount,
        'punishmentsResolvedCount': _punishmentsResolvedCount,
        'longestStreak': _longestStreak,
        'totalDaysPlayed': _totalDaysPlayed,
        'consecutiveCleanDays': _consecutiveCleanDays,
        'stats': _stats.map((key, value) => MapEntry(key.index.toString(), value.toJson())),
        'contributionHistory': _contributionHistory,
        'quests': _quests.map((q) => q.toJson()).toList(),
        'punishments': _punishments.map((p) => p.toJson()).toList(),
        'notifications': _notifications.map((n) => n.toJson()).toList(),
        'achievements': _achievements.map((a) => a.toJson()).toList(),
        'equipment': _equipment.map((e) => e.toJson()).toList(),
        'lastResetDate': _lastResetDate?.toIso8601String(),
      };

      // Save local cache
      await prefs.setString('local_player_state', jsonEncode(stateMap));

      // Push real-time update through WebSockets outbox
      if (syncToRemote) {
        _syncService.sendState(stateMap);
      }
    } catch (e) {
      debugPrint("Error saving state: $e");
    }
  }

  // Developer Reset - Reset everything back to new SYSTEM state
  Future<void> developerReset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _playerName = '';
    _playerClass = 'Self Improver';
    _characterLevel = 1;
    _characterXp = 0.0;
    _totalXpEarned = 0;
    _questsCompletedCount = 0;
    _punishmentsResolvedCount = 0;
    _longestStreak = 0;
    _totalDaysPlayed = 1;
    _consecutiveCleanDays = 0;
    _serverAddress = 'system-5jlk.onrender.com';

    _stats.forEach((key, value) {
      value.level = 1;
      value.xp = 0.0;
    });
    _punishments.clear();
    _notifications.clear();
    _contributionHistory.clear();
    
    _setupDefaultQuests();
    _initializeAchievements();
    _initializeEquipment();
    _lastResetDate = DateTime.now();

    _addNotification('SYSTEM INITIALIZED', 'Welcome Shiva, the System has rebooted.');
    await _saveState();
    notifyListeners();
  }
}
