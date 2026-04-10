import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../data/wiki_data.dart';
import '../widgets/glass_container.dart';
import '../utils/l10n.dart';

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
        title: Text(
          L10n.t('knowledge_base').toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 16,
            color: VytalColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: VytalColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.t('research'),
              style: const TextStyle(
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
                    color:
                        Colors.transparent, // Minimalist transparent background
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
            Text(
              L10n.t('library'),
              style: const TextStyle(
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
                                child: Icon(article.icon, color: article.color),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      "${article.readTimeMin} ${L10n.t('min_read')}",
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

class _ArticleDetailScreen extends StatefulWidget {
  final WikiArticle article;
  const _ArticleDetailScreen({required this.article});

  @override
  State<_ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<_ArticleDetailScreen> {
  bool _isMythExpanded = false;
  int? _selectedAnswerIndex;
  bool _showQuizResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VytalColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: VytalColors.background,
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.article.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          VytalColors.background.withValues(alpha: 0.2),
                          VytalColors.background,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      widget.article.icon,
                      size: 80,
                      color: widget.article.color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(
                Icons.arrow_back,
                color: VytalColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  widget.article.category.toUpperCase(),
                  style: TextStyle(
                    color: widget.article.color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.article.title,
                  style: const TextStyle(
                    color: VytalColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),

                // Content
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    widget.article.content,
                    style: const TextStyle(
                      color: VytalColors.textPrimary,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Interactive Element: Myth vs Fact Accordion
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMythExpanded = !_isMythExpanded;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isMythExpanded
                          ? widget.article.color.withValues(alpha: 0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.article.color.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: widget.article.color,
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  "Myth vs Fact",
                                  style: TextStyle(
                                    color: VytalColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              _isMythExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: VytalColors.textSecondary,
                            ),
                          ],
                        ),
                        if (_isMythExpanded) ...[
                          const SizedBox(height: 20),
                          Text(
                            "Myth: ${widget.article.mythVsFact['Myth']}",
                            style: const TextStyle(
                              color: VytalColors.textSecondary,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Fact: ${widget.article.mythVsFact['Fact']}",
                            style: const TextStyle(
                              color: VytalColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (widget.article.quiz != null) ...[
                  const SizedBox(height: 40),
                  const Text(
                    "Knowledge Check",
                    style: TextStyle(
                      color: VytalColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.article.quiz!['question'],
                          style: const TextStyle(
                            color: VytalColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(
                          (widget.article.quiz!['options'] as List).length,
                          (index) {
                            bool isSelected = _selectedAnswerIndex == index;
                            bool isCorrect =
                                index == widget.article.quiz!['correctIndex'];

                            Color buttonColor = Colors.transparent;
                            Color borderColor = VytalColors.textSecondary
                                .withValues(alpha: 0.5);
                            if (_showQuizResult) {
                              if (isCorrect) {
                                buttonColor = Colors.green.withValues(
                                  alpha: 0.2,
                                );
                                borderColor = Colors.green;
                              } else if (isSelected && !isCorrect) {
                                buttonColor = Colors.red.withValues(alpha: 0.2);
                                borderColor = Colors.red;
                              }
                            } else if (isSelected) {
                              buttonColor = widget.article.color.withValues(
                                alpha: 0.2,
                              );
                              borderColor = widget.article.color;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap: _showQuizResult
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedAnswerIndex = index;
                                          _showQuizResult = true;
                                        });
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: buttonColor,
                                    border: Border.all(color: borderColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.article.quiz!['options'][index],
                                    style: TextStyle(
                                      color: VytalColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.article.color,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      L10n.t('read'),
                      style: TextStyle(
                        color: widget.article.color,
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
