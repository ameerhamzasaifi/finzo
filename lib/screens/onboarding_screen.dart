import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { chooseAction, enterBookName, enterUserName, importing }

class _OnboardingScreenState extends State<OnboardingScreen> {
  _Step _step = _Step.chooseAction;
  final _bookCtrl = TextEditingController(text: 'My Finance');
  final _nameCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _bookCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _importBook() async {
    setState(() => _step = _Step.importing);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.single.path == null) {
        setState(() => _step = _Step.chooseAction);
        return;
      }
      final sourcePath = result.files.single.path!;
      if (!sourcePath.endsWith('.books.db')) {
        setState(() {
          _error = 'Please select a valid .books.db file';
          _step = _Step.chooseAction;
        });
        return;
      }
      final bookName = await DatabaseService.importBook(sourcePath);
      await DatabaseService.instance.openBook(bookName);
      _bookCtrl.text = bookName;
      setState(() => _step = _Step.enterUserName);
    } catch (e) {
      setState(() {
        _error = 'Import failed: ${e.toString()}';
        _step = _Step.chooseAction;
      });
    }
  }

  Future<void> _createBook() async {
    final name = _bookCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a book name');
      return;
    }
    try {
      await DatabaseService.instance.createBook(name);
      setState(() {
        _error = null;
        _step = _Step.enterUserName;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _finish() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }
    await DatabaseService.instance.setSetting('user_name', name);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      _Step.chooseAction => _buildChooseAction(),
      _Step.enterBookName => _buildBookName(),
      _Step.enterUserName => _buildUserName(),
      _Step.importing => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Importing…', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    };
  }

  Widget _buildChooseAction() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('💰', style: TextStyle(fontSize: 72)),
        const SizedBox(height: 16),
        const Text(
          'Welcome to Finzo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your personal finance manager',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 48),
        _ActionCard(
          icon: Icons.add_circle_outline_rounded,
          title: 'Create New Book',
          subtitle: 'Start fresh with a new finance book',
          onTap: () => setState(() {
            _error = null;
            _step = _Step.enterBookName;
          }),
        ),
        const SizedBox(height: 16),
        _ActionCard(
          icon: Icons.file_download_outlined,
          title: 'Import Database',
          subtitle: 'Restore from a .books.db file',
          onTap: _importBook,
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: AppTheme.expenseColor)),
        ],
      ],
    );
  }

  Widget _buildBookName() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.menu_book_rounded,
          size: 64,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 24),
        const Text(
          'Name Your Book',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'This will be your finance database name',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _bookCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. My Finance',
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: AppTheme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: AppTheme.expenseColor, fontSize: 12),
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _createBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() {
            _error = null;
            _step = _Step.chooseAction;
          }),
          child: const Text('Back', style: TextStyle(color: Colors.white38)),
        ),
      ],
    );
  }

  Widget _buildUserName() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.person_rounded,
          size: 64,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 24),
        const Text(
          'What\'s your name?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We\'ll use this to personalize your experience',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _nameCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: AppTheme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: AppTheme.expenseColor, fontSize: 12),
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _finish,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
