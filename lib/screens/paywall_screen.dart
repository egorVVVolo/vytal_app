import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../widgets/glass_container.dart';
import '../services/storage_service.dart'; // <--- Импорт (ОБЯЗАТЕЛЬНО)

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. КНОПКА ЗАКРЫТЬ
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8),
                  child: IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close, color: VytalColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // 2. СКРОЛЛ КОНТЕНТА
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      // Иконка
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Minimalist background
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: VytalColors.primaryAccent,
                            width: 0.5,
                          ), // Sharp/thin border
                        ),
                        child: const Icon(
                          Icons.diamond_outlined,
                          color: VytalColors.primaryAccent,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "VYTAL PRO",
                        style: TextStyle(
                          color: VytalColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,

                        ),
                      ),
                      const Text(
                        "SYSTEM OVERRIDE",
                        style: TextStyle(
                          color: VytalColors.primaryAccent,
                          fontSize: 12,
                          letterSpacing: 8,

                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildFeatureRow(
                        Icons.analytics,
                        "AI Deep Scan",
                        "Unlimited posture analysis",
                      ),
                      _buildFeatureRow(
                        Icons.science,
                        "Secret Protocols",
                        "Access 'Navy SEAL' methods",
                      ),
                      _buildFeatureRow(
                        Icons.cloud_upload,
                        "Cloud Sync",
                        "Eternal cloud storage",
                      ),
                      _buildFeatureRow(
                        Icons.show_chart,
                        "Prediction 2.0",
                        "Genetic growth forecast",
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // 3. НИЖНЯЯ ПАНЕЛЬ
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: VytalColors.background,
                  border: Border(
                    top: BorderSide(color: VytalColors.textPrimary.withValues(alpha: 0.1)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: VytalColors.textPrimary.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Цена
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      border: Border.all(color: VytalColors.secondaryAccent),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "LIFETIME ACCESS",
                                style: TextStyle(
                                  color: VytalColors.secondaryAccent,
                                  fontWeight: FontWeight.bold,

                                ),
                              ),
                              Text(
                                "ONE-TIME PAYMENT",
                                style: TextStyle(
                                  color: VytalColors.textSecondary,
                                  fontSize: 10,

                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "\$19.99",
                            style: TextStyle(
                              color: VytalColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // КНОПКА АКТИВАЦИИ (ИСПРАВЛЕНА ЛОГИКА)
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.heavyImpact();

                        // 1. СОХРАНЯЕМ СТАТУС В БАЗУ!
                        await StorageService.setProStatus(true);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("VYTAL PRO Активирован 🧬"),
                              backgroundColor: VytalColors.secondaryAccent,
                            ),
                          );
                          // 2. Закрываем экран (возвращаемся в историю, которая теперь обновится)
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              Colors.transparent, // Minimalist transparent bg
                          border: Border.all(
                            color: VytalColors.primaryAccent,
                            width: 0.5,
                          ),
                        ),
                        child: const Text(
                          "ACTIVATE PRO",
                          style: TextStyle(
                            color: VytalColors.primaryAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,

                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      "Restore purchases",
                      style: TextStyle(
                        color: VytalColors.textSecondary,
                        fontSize: 12,
                        decoration: TextDecoration.underline,

                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: VytalColors.textSecondary, width: 0.5),
            ),
            child: Icon(icon, color: VytalColors.textPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: VytalColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,

                    letterSpacing: 1,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: VytalColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
