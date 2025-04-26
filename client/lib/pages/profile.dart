import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jupiter_perp_trader_client/services/auth.dart';
import 'package:jupiter_perp_trader_client/services/wallet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showMnemonicConfirm = false;
  String? _mnemonic;
  bool _isLoading = false;

  Future<void> _showMnemonicWarningDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Security Warning'),
          content: const Text(
            'Your secret recovery phrase gives full access to your wallet. '
            'Never share it with anyone.\n\n',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _showMnemonicConfirm = true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Show Recovery Phrase'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportMnemonic() async {
    setState(() => _isLoading = true);
    try {
      final mnemonic = await WalletService().exportMnemonic();
      setState(() {
        _mnemonic = mnemonic;
        _showMnemonicConfirm = false;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export recovery phrase'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Section
                const Text(
                  'Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: authState.email,
                ),

                const SizedBox(height: 24),

                // Wallet Section
                const Text(
                  'Wallet',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Public Key',
                  value: authState.walletPublicKey ?? 'Not available',
                  onTap:
                      authState.walletPublicKey != null
                          ? () => _copyToClipboard(
                            context,
                            authState.walletPublicKey!,
                          )
                          : null,
                ),

                if (_mnemonic != null) ...[
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    icon: Icons.key,
                    label: 'Secret Recovery Phrase',
                    value: _mnemonic!,
                    onTap:
                        () => _copyToClipboard(
                          context,
                          _mnemonic!,
                          message: 'Recovery phrase copied to clipboard',
                        ),
                    isSecret: true,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Write down these 12 words in order and keep them safe.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ] else if (_showMnemonicConfirm) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _exportMnemonic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Confirm Show Recovery Phrase'),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _showMnemonicWarningDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    icon: const Icon(Icons.warning),
                    label: const Text('Show Recovery Phrase'),
                  ),
                ],

                const Spacer(),

                ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                    );

                    if (confirmed == true) {
                      await AuthService().logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onErrorContainer,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    bool isSecret = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  if (isSecret)
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'monospace',
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  else
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.copy),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, {String? message}) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
