import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../data/protocols_data.dart';
import '../models/habit.dart';
import '../widgets/glass_container.dart';
import 'create_protocol_screen.dart'; // <--- IMPORT BUILDER

class ProtocolLibraryScreen extends StatelessWidget {
  final Function(List<Habit>) onAddProtocol;

  const ProtocolLibraryScreen({super.key, required this.onAddProtocol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "LIBRARY",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 16,
            color: VytalColors.primaryAccent,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: VytalColors.primaryAccent,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. "CREATE OWN" BUTTON (Top)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
            child: Tooltip(
              message: "Create Own Protocol",
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateProtocolScreen(onCreate: onAddProtocol),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        VytalColors.primaryAccent.withValues(alpha: 0.2),
                        VytalColors.primaryAccent.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: VytalColors.primaryAccent.withValues(alpha: 0.5),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.build_circle_outlined,
                        color: VytalColors.primaryAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "CREATE CUSTOM PROTOCOL",
                        style: TextStyle(
                          color: VytalColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "AVAILABLE PRESETS",
                style: TextStyle(
                  color: VytalColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          // 2. PRESETS LIST
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: ProtocolsData.list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final protocol = ProtocolsData.list[index];
                return _ProtocolCard(protocol: protocol, onAdd: onAddProtocol);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  final Protocol protocol;
  final Function(List<Habit>) onAdd;

  const _ProtocolCard({required this.protocol, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    // Determine accent color
    Color accentColor;
    switch (protocol.accentColor) {
      case ColorHex.blue:
        accentColor = VytalColors.primaryAccent;
        break;
      case ColorHex.green:
        accentColor = VytalColors.secondaryAccent;
        break;
      case ColorHex.purple:
        accentColor = const Color(0xFFA020F0);
        break;
      case ColorHex.orange:
        accentColor = Colors.orangeAccent;
        break;
      case ColorHex.red:
        accentColor = Colors.redAccent;
        break;
    }

    return GestureDetector(
      onTap: () => _showDetails(context, accentColor),
      child: Container(
        decoration: BoxDecoration(
          color: VytalColors.textPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: VytalColors.textPrimary.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            // Top part with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: VytalColors.textPrimary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        protocol.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          protocol.title.toUpperCase(),
                          style: const TextStyle(
                            color: VytalColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          protocol.subtitle,
                          style: const TextStyle(
                            color: VytalColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 12,
                              color: accentColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              protocol.author,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom part with tags
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 8,
                    children: protocol.tags
                        .take(2)
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: VytalColors.textSecondary,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              tag.toUpperCase(),
                              style: const TextStyle(
                                color: VytalColors.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: VytalColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        protocol.timeEstimate,
                        style: const TextStyle(
                          color: VytalColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: VytalColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: VytalColors.textSecondary,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Title
            Row(
              children: [
                Text(protocol.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    protocol.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tags & Info
            Row(
              children: [
                _buildInfoBadge(protocol.difficulty, accentColor),
                const SizedBox(width: 10),
                _buildInfoBadge(protocol.timeEstimate, VytalColors.textPrimary),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              protocol.description,
              style: const TextStyle(
                color: VytalColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "PROTOCOL COMPOSITION:",
              style: TextStyle(
                color: VytalColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: protocol.habits.length,
                itemBuilder: (context, index) {
                  final h = protocol.habits[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(12),
                      color: VytalColors.textPrimary.withValues(alpha: 0.02),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: VytalColors.textPrimary.withValues(
                                alpha: 0.05,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Text(h.icon),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.title,
                                style: const TextStyle(
                                  color: VytalColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                h.subtitle,
                                style: const TextStyle(
                                  color: VytalColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  onAdd(protocol.habits);
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Protocol '${protocol.title}' initialized!",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: VytalColors.textPrimary,
                        ),
                      ),
                      backgroundColor: accentColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "INSTALL (${protocol.habits.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(24),
        color: color.withValues(alpha: 0.1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color == VytalColors.textPrimary ? Colors.white : color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
