import '../models/habit.dart';

class Protocol {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String author;
  final String icon;
  final ColorHex accentColor;

  final List<String> tags; // ["Easy", "Morning", "Focus"]
  final String timeEstimate; // "15 min"
  final String difficulty; // "Easy", "Medium", "Hard"

  final List<Habit> habits;

  Protocol({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.author,
    required this.icon,
    required this.accentColor,
    required this.tags,
    required this.timeEstimate,
    required this.difficulty,
    required this.habits,
  });
}

enum ColorHex { blue, green, purple, orange, red }

class ProtocolsData {
  static final List<Protocol> list = [
    Protocol(
      id: 'p1',
      title: 'Morning Neuro',
      subtitle: 'Brain & rhythm activation',
      description:
          'Classic Andrew Huberman protocol to set your circadian rhythms. Maximum wakefulness without caffeine in the first hour.',
      author: 'Andrew Huberman',
      icon: '☀️',
      accentColor: ColorHex.orange,
      tags: ["Energy", "Focus", "Morning"],
      timeEstimate: "20 min",
      difficulty: "Easy",
      habits: [
        Habit(
          id: 't1',
          title: 'Sunlight Exposure',
          subtitle: '10 min outside (Lux > 100k)',
          type: HabitType.vitamin,
          icon: '🌅',
        ),
        Habit(
          id: 't2',
          title: 'Salt Water',
          subtitle: '500ml + 1g Himalayan salt',
          type: HabitType.vitamin,
          icon: '💧',
        ),
        Habit(
          id: 't3',
          title: 'Cold Shower',
          subtitle: '90 sec (until shivering)',
          type: HabitType.activity,
          icon: '🚿',
        ),
        Habit(
          id: 't4',
          title: 'Delay Caffeine',
          subtitle: 'No coffee for 90 min after waking',
          type: HabitType.mental,
          icon: '☕',
        ),
      ],
    ),
    Protocol(
      id: 'p2',
      title: 'Growth Hacking',
      subtitle: 'HGH Stimulation & Posture',
      description:
          'Aggressive protocol for physical growth. Focused on spinal decompression and peak hormone release.',
      author: 'Vytal Lab',
      icon: '🧬',
      accentColor: ColorHex.blue,
      tags: ["Height", "Posture", "Sleep"],
      timeEstimate: "45 min",
      difficulty: "Hard",
      habits: [
        Habit(
          id: 't5',
          title: 'Sprints',
          subtitle: '4x100m (Max effort)',
          type: HabitType.activity,
          icon: '🏃',
        ),
        Habit(
          id: 't6',
          title: 'Dead Hangs',
          subtitle: '3 sets of 60 seconds',
          type: HabitType.activity,
          icon: '🪜',
        ),
        Habit(
          id: 't7',
          title: 'Deep Sleep',
          subtitle: 'Strict sleep by 23:00',
          type: HabitType.sleep,
          icon: '🌙',
        ),
        Habit(
          id: 't8',
          title: 'Sauna/Hot Bath',
          subtitle: 'Pre-sleep heat shock',
          type: HabitType.activity,
          icon: '🔥',
        ),
      ],
    ),
    Protocol(
      id: 'p3',
      title: 'Spine Decompress',
      subtitle: 'Text Neck Correction',
      description:
          'Exercises for people who sit a lot. Regains 1-2 cm of height by straightening kyphosis.',
      author: 'Physio',
      icon: '🦴',
      accentColor: ColorHex.green,
      tags: ["Posture", "Recovery"],
      timeEstimate: "15 min",
      difficulty: "Medium",
      habits: [
        Habit(
          id: 't9',
          title: 'Wall Angels',
          subtitle: '20 reps against the wall',
          type: HabitType.activity,
          icon: '🧱',
        ),
        Habit(
          id: 't10',
          title: 'Chin Tucks',
          subtitle: '30 reps',
          type: HabitType.activity,
          icon: '😐',
        ),
        Habit(
          id: 't11',
          title: 'Chest Stretch',
          subtitle: 'In the doorway for 2 min',
          type: HabitType.activity,
          icon: '🚪',
        ),
      ],
    ),
    Protocol(
      id: 'p4',
      title: 'Dopamine Detox',
      subtitle: 'Monk Mode',
      description:
          'Dopamine receptor recovery. A difficult psychological challenge to regain motivation.',
      author: 'Iman Gadzhi',
      icon: '🧘',
      accentColor: ColorHex.purple,
      tags: ["Mental", "Focus", "NoPhone"],
      timeEstimate: "All day",
      difficulty: "Hardcore",
      habits: [
        Habit(
          id: 't12',
          title: 'NO Social Media',
          subtitle: 'Full TikTok/Insta block',
          type: HabitType.mental,
          icon: '📵',
        ),
        Habit(
          id: 't13',
          title: 'Silence',
          subtitle: '30 min without music or podcasts',
          type: HabitType.mental,
          icon: '🤫',
        ),
        Habit(
          id: 't14',
          title: 'Reading',
          subtitle: '20 pages (paper)',
          type: HabitType.mental,
          icon: '📚',
        ),
      ],
    ),
    Protocol(
      id: 'p5',
      title: 'Deep Sleep Stack',
      subtitle: 'Sleep Pharmacology',
      description:
          'Supplement stack for maximum CNS recovery. (Consult your doctor).',
      author: 'Biohacker',
      icon: '💊',
      accentColor: ColorHex.red,
      tags: ["Supplements", "Recovery"],
      timeEstimate: "5 min",
      difficulty: "Easy",
      habits: [
        Habit(
          id: 't15',
          title: 'Magnesium Bisglycinate',
          subtitle: '400 mg 1 hour before bed',
          type: HabitType.vitamin,
          icon: '💊',
        ),
        Habit(
          id: 't16',
          title: 'L-Theanine',
          subtitle: '200 mg for relaxation',
          type: HabitType.vitamin,
          icon: '🍵',
        ),
        Habit(
          id: 't17',
          title: 'Chamomile Tea',
          subtitle: 'Natural Apigenin',
          type: HabitType.vitamin,
          icon: '🌼',
        ),
      ],
    ),
  ];
}
