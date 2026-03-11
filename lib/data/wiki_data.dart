import 'package:flutter/material.dart';

class WikiArticle {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String category;
  final IconData icon;
  final Color color;
  final int readTimeMin;

  const WikiArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.category,
    required this.icon,
    required this.color,
    required this.readTimeMin,
  });
}

class WikiData {
  static const List<WikiArticle> articles = [
    WikiArticle(
      id: '1',
      title: 'Wolff\'s Law',
      subtitle: 'How bones adapt under load',
      category: 'Science',
      icon: Icons.science_rounded,
      color: Colors.blueAccent,
      readTimeMin: 3,
      content: """
Julius Wolff, a German anatomist, proved in the 19th century: the bone of a healthy person or animal adapts to the loads it is subjected to.

If the load on a specific bone increases, the bone remodels to become stronger. This also applies to micro-fractures that occur during sprinting or jumping.

In the context of growth: proper axial load and subsequent recovery (sleep) stimulate thickening and lengthening of bone tissue in open growth plates.
      """,
    ),
    WikiArticle(
      id: '2',
      title: 'HGH Protocol',
      subtitle: 'Maximizing growth hormone during sleep',
      category: 'Hormones',
      icon: Icons.bolt_rounded,
      color: Colors.amberAccent,
      readTimeMin: 5,
      content: """
Human Growth Hormone (HGH) is a key factor in your vertical potential. 75% of your daily output occurs during sleep.

Key factors:
1. **Delta Sleep:** This is when the release happens.
2. **Insulin:** High blood sugar before sleep BLOCKS HGH release. No sweets 3 hours before bed.
3. **Temperature:** A cool room (18-20°C) promotes deeper sleep.

Vytal recommends sleeping before 23:00 to catch the first and most powerful hormone secretion peak.
      """,
    ),
    WikiArticle(
      id: '3',
      title: 'Text Neck',
      subtitle: 'How your phone steals 3 cm',
      category: 'Posture',
      icon: Icons.phone_iphone_rounded,
      color: Colors.redAccent,
      readTimeMin: 2,
      content: """
The 'Text Neck' syndrome is a 21st-century epidemic. Tilting your head forward by 60 degrees to look at your phone increases the load on your cervical spine from 5 kg to 27 kg!

Consequences:
1. Spinal disc compression (loss of height).
2. Dowager's hump (kyphosis).
3. Reduced blood flow to the brain.

Solution: Raise your phone to eye level. Do 'Chin Tucks' daily.
      """,
    ),
    WikiArticle(
      id: '4',
      title: 'Intermittent Fasting',
      subtitle: 'Trigger for detox and growth',
      category: 'Diet',
      icon: Icons.restaurant_menu_rounded,
      color: Colors.greenAccent,
      readTimeMin: 4,
      content: """
The 16/8 fast isn't just about weight loss. It's about hormonal response. When insulin levels drop to a minimum, your body triggers defense mechanisms and spikes HGH to preserve muscle and bone.

Research shows an increase in basal growth hormone levels when fasting over 16 hours. However, this requires caution and medical consultation.
      """,
    ),
  ];
}
