import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../data/wiki_data.dart';
import '../widgets/glass_container.dart';

class WikiScreen extends StatelessWidget {
  const WikiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ВАЖНО: Scaffold имеет прозрачный фон, но чтобы не было белого,
    // оборачиваем в CyberpunkGridBackground или просто задаем цвет.
    // Если переход идет через Fade, то предыдущий экран просвечивает,
    // поэтому нужен непрозрачный черный фон самого Scaffold.

    return Scaffold(
      backgroundColor: VytalColors.background, // Фикс белого экрана
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "KNOWLEDGE BASE",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 16,
            color: VytalColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: VytalColors.textPrimary),
      ),
      body: Container(
        // Добавил сетку для красоты
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "RESEARCH",
                style: TextStyle(
                  color: VytalColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,

                ),
              ),
              const SizedBox(height: 20),

              // Featured Article (Большая карточка с анимацией)
              GestureDetector(
                onTap: () => _openArticle(context, WikiData.articles[0]),
                child: Hero(
                  tag: 'article_0',
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors
                          .transparent, // Minimalist transparent background
                      border: Border.all(
                        color: WikiData.articles[0].color.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          WikiData.articles[0].color.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: WikiData.articles[0].color,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            WikiData.articles[0].category.toUpperCase(),
                            style: TextStyle(
                              color: WikiData.articles[0].color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,

                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: Colors.transparent,
                          child: Text(
                            WikiData.articles[0].title,
                            style: const TextStyle(
                              color: VytalColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: Colors.transparent,
                          child: Text(
                            WikiData.articles[0].subtitle,
                            style: const TextStyle(
                              color: VytalColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: 40),
              const Text(
                "LIBRARY",
                style: TextStyle(
                  color: VytalColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,

                ),
              ),
              const SizedBox(height: 16),

              // Список остальных статей
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: WikiData.articles.length - 1,
                itemBuilder: (context, index) {
                  final article = WikiData.articles[index + 1];
                  return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () => _openArticle(context, article),
                          child: GlassContainer(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: article.color.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: article.color.withValues(alpha: 0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Icon(
                                    article.icon,
                                    color: article.color,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.category.toUpperCase(),
                                        style: TextStyle(
                                          color: article.color,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,

                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        article.title,
                                        style: const TextStyle(
                                          color: VytalColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${article.readTimeMin} min read",
                                        style: const TextStyle(
                                          color: VytalColors.textSecondary,
                                          fontSize: 12,

                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: VytalColors.textSecondary,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: (100 * index).ms)
                      .slideX(begin: 0.1, end: 0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openArticle(BuildContext context, WikiArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ArticleDetailScreen(article: article),
      ),
    );
  }
}

class _ArticleDetailScreen extends StatelessWidget {
  final WikiArticle article;
  const _ArticleDetailScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: VytalColors.background,
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      article.color.withValues(alpha: 0.2),
                      VytalColors.background,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(
                    article.icon,
                    size: 80,
                    color: article.color.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: VytalColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  article.category.toUpperCase(),
                  style: TextStyle(
                    color: article.color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,

                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  article.title,
                  style: const TextStyle(
                    color: VytalColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),

                // Контент в стекле
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    article.content,
                    style: const TextStyle(
                      color: VytalColors.textPrimary,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Интерактивный элемент (Квиз / Факт)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: article.color.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: article.color),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "Did you know? This method is used by Olympic athletes for recovery.",
                          style: TextStyle(
                            color: VytalColors.textSecondary,
                            fontSize: 12,

                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: article.color, width: 0.5),
                    ),
                    child: Text(
                      "READ",
                      style: TextStyle(
                        color: article.color,
                        fontWeight: FontWeight.bold,

                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
