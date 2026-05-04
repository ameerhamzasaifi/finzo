import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Finzo'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header
            Center(
              child: Column(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  const Text(
                    'Finzo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Description
            const Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Finzo is a fully offline personal finance management app that helps you track expenses, manage accounts, set budgets, and achieve your financial goals with ease and privacy.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            // Key Features
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _FeatureItem(
              label: '📊 Dashboard',
              description: 'Overview of your finances',
            ),
            _FeatureItem(
              label: '💼 Accounts',
              description: 'Manage multiple accounts',
            ),
            _FeatureItem(
              label: '💳 Credit Cards',
              description: 'Track credit card spending',
            ),
            _FeatureItem(
              label: '📈 Investments',
              description: 'Monitor your portfolio',
            ),
            _FeatureItem(
              label: '🎯 Budgets',
              description: 'Set and track budgets',
            ),
            _FeatureItem(
              label: '📊 Reports',
              description: 'Detailed financial reports',
            ),
            _FeatureItem(label: '🏦 Loans', description: 'Track active loans'),
            const SizedBox(height: 32),

            // Social/Contact Section
            const Text(
              'Connect With Us',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _ContactButton(
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              subtitle: 'Contact us',
              url: 'mailto:ahsmobilelabs@gmail.com',
              onTap: _launchUrl,
            ),
            const SizedBox(height: 10),
            _ContactButton(
              icon: Icons.code_rounded,
              label: 'GitHub',
              subtitle: 'View source code',
              url: 'https://github.com/ahsmobilelabs',
              onTap: _launchUrl,
            ),
            const SizedBox(height: 10),
            _ContactButton(
              icon: Icons.link_rounded,
              label: 'Linktree',
              subtitle: 'All links in one place',
              url: 'https://linktr.ee/ahsmobilelabs',
              onTap: _launchUrl,
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Made with ❤️ by AHS Mobile Labs',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fully offline • Privacy-focused • Open source',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String label;
  final String description;

  const _FeatureItem({required this.label, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String url;
  final Function(String) onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(url),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_outward_rounded,
                color: Colors.white38,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
