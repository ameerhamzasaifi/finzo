import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/currency_model.dart';
import '../providers/finance_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Profile Section ──────────────────────────────────────
          const _SectionTitle(title: 'Profile'),
          const SizedBox(height: 8),
          Card(
            color: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withAlpha(38),
                child: Text(
                  provider.userName.isNotEmpty
                      ? provider.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(
                provider.userName.isNotEmpty ? provider.userName : 'Set Name',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Tap to change',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              trailing: const Icon(
                Icons.edit_rounded,
                color: Colors.white38,
                size: 18,
              ),
              onTap: () => _showNameDialog(context, provider),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Currency Section ─────────────────────────────────────
          const _SectionTitle(title: 'Currency'),
          const SizedBox(height: 8),
          _CurrencySelector(
            current: provider.currency,
            onChanged: (c) => provider.setCurrency(c),
          ),
          const SizedBox(height: 24),

          // ─── About Section ────────────────────────────────────────
          const _SectionTitle(title: 'About'),
          const SizedBox(height: 8),
          Card(
            color: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Finzo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Offline Personal Finance Manager',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNameDialog(BuildContext context, FinanceProvider provider) {
    final ctrl = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Your Name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                provider.setUserName(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  final CurrencyModel current;
  final ValueChanged<CurrencyModel> onChanged;

  const _CurrencySelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(38),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(current.symbol, style: const TextStyle(fontSize: 20)),
            ),
            title: Text(
              current.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              current.code,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
            onTap: () => _showPicker(context),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CurrencyPickerSheet(
        current: current,
        onSelect: (c) {
          onChanged(c);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  final CurrencyModel current;
  final ValueChanged<CurrencyModel> onSelect;
  const _CurrencyPickerSheet({required this.current, required this.onSelect});

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = CurrencyModel.supported.where((c) {
      final q = _query.toLowerCase();
      return c.name.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q) ||
          c.symbol.contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Currency',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search currency...',
              prefixIcon: Icon(Icons.search, color: Colors.white38),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c = filtered[i];
                final isSelected = c.code == widget.current.code;
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          (isSelected ? AppTheme.primaryColor : Colors.white12)
                              .withAlpha(isSelected ? 50 : 25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(c.symbol, style: const TextStyle(fontSize: 16)),
                  ),
                  title: Text(
                    c.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    c.code,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryColor,
                          size: 20,
                        )
                      : null,
                  onTap: () => widget.onSelect(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
