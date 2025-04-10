import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutProjectPage extends StatelessWidget {
  const AboutProjectPage({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch URL',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            'About This Project',
            key: const ValueKey('title'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: IconButton(
            key: const ValueKey('back'),
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Center(
          child: SizedBox(
            width: 600, // Set max width to 600
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.book,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Stories',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Version 1.0.0',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'About',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stories is a modern reading platform that allows users to discover, read, and discuss books. The app provides a seamless experience for book lovers with features like personalized reading lists, discussion rooms, and more.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                Text(
                  'Features',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFeatureCard(
                  context,
                  icon: Icons.book_outlined,
                  title: 'Book Discovery',
                  description: 'Browse through a vast collection of books and discover new stories.',
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Discussion Rooms',
                  description: 'Join discussions with other readers about your favorite books.',
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.person_outline,
                  title: 'Personal Library',
                  description: 'Create and manage your personal collection of books.',
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Customization',
                  description: 'Customize your reading experience with themes, fonts, and more.',
                ),
                const SizedBox(height: 32),
                Text(
                  'Contact & Support',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email Support'),
                    subtitle: const Text('support@stories.com'),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _launchURL('mailto:support@stories.com');
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('GitHub Repository'),
                    subtitle: const Text('github.com/stories'),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _launchURL('https://github.com/stories');
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    '© 2024 Stories. All rights reserved.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}