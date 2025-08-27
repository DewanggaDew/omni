import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:omni/core/theme/app_theme.dart';
import 'package:omni/core/theme/theme_cubit.dart';
import 'package:omni/core/utils/currency_formatter.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final _displayNameController = TextEditingController();
  String _selectedCurrency = 'IDR';
  bool _isEditingName = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _displayNameController.text = user.displayName ?? '';

      // Load currency preference from Firestore
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['currency'] != null) {
            setState(() {
              _selectedCurrency = data['currency'] as String;
            });
          }
        }
      } catch (e) {
        // Use default currency if loading fails
      }
    }
  }

  Future<void> _updateDisplayName() async {
    if (_displayNameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.updateDisplayName(_displayNameController.text.trim());

      setState(() => _isEditingName = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Display name updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update name: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.warmRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<void> _saveCurrencyPreference(String currency) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'currency': currency},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Currency updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update currency: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
          tooltip: 'Back to Home',
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSection(
              title: 'Profile',
              children: [
                _buildProfileCard(user, theme, isDark),
                const SizedBox(height: AppTheme.space16),
                _buildDisplayNameTile(theme, isDark),
                const SizedBox(height: AppTheme.space12),
                _buildEmailTile(user, theme, isDark),
              ],
            ),

            const SizedBox(height: AppTheme.space32),

            // Preferences Section
            _buildSection(
              title: 'Preferences',
              children: [
                _buildCurrencyTile(theme, isDark),
                const SizedBox(height: AppTheme.space12),
                _buildThemeTile(theme, isDark),
              ],
            ),

            const SizedBox(height: AppTheme.space32),

            // Account Section
            _buildSection(
              title: 'Account',
              children: [_buildSignOutTile(theme, isDark)],
            ),

            const SizedBox(height: AppTheme.space40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTheme.space16),
        ...children,
      ],
    );
  }

  Widget _buildProfileCard(User? user, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.charcoalBlack : AppTheme.offWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.vibrantBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppTheme.vibrantBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppTheme.space4),
                Text(
                  user?.email ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayNameTile(ThemeData theme, bool isDark) {
    return _buildSettingsTile(
      icon: Icons.edit_rounded,
      title: 'Display Name',
      subtitle: _isEditingName
          ? null
          : FirebaseAuth.instance.currentUser?.displayName ?? 'Not set',
      theme: theme,
      isDark: isDark,
      child: _isEditingName
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _displayNameController,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Enter display name',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space12,
                        vertical: AppTheme.space8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.space8),
                IconButton(
                  onPressed: _isLoading ? null : _updateDisplayName,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: () => setState(() => _isEditingName = false),
                  icon: const Icon(Icons.close_rounded),
                  iconSize: 20,
                ),
              ],
            )
          : null,
      onTap: _isEditingName
          ? null
          : () => setState(() => _isEditingName = true),
    );
  }

  Widget _buildEmailTile(User? user, ThemeData theme, bool isDark) {
    return _buildSettingsTile(
      icon: Icons.email_rounded,
      title: 'Email',
      subtitle: user?.email ?? 'Not available',
      theme: theme,
      isDark: isDark,
      trailing: user?.emailVerified == true
          ? Icon(Icons.verified_rounded, color: AppTheme.emeraldGreen, size: 20)
          : Icon(
              Icons.error_outline_rounded,
              color: AppTheme.warmRed,
              size: 20,
            ),
    );
  }

  Widget _buildCurrencyTile(ThemeData theme, bool isDark) {
    return _buildSettingsTile(
      icon: Icons.attach_money_rounded,
      title: 'Currency',
      subtitle: _selectedCurrency,
      theme: theme,
      isDark: isDark,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: () => _showCurrencyPicker(),
    );
  }

  Widget _buildThemeTile(ThemeData theme, bool isDark) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        String themeText;
        switch (themeMode) {
          case ThemeMode.system:
            themeText = 'System';
            break;
          case ThemeMode.light:
            themeText = 'Light';
            break;
          case ThemeMode.dark:
            themeText = 'Dark';
            break;
        }

        return _buildSettingsTile(
          icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          title: 'Theme',
          subtitle: themeText,
          theme: theme,
          isDark: isDark,
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () => _showThemeSelector(),
        );
      },
    );
  }

  Widget _buildSignOutTile(ThemeData theme, bool isDark) {
    return _buildSettingsTile(
      icon: Icons.logout_rounded,
      title: 'Sign Out',
      theme: theme,
      isDark: isDark,
      titleColor: AppTheme.warmRed,
      onTap: _signOut,
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? child,
    Widget? trailing,
    Color? titleColor,
    required ThemeData theme,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.space16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.charcoalBlack : AppTheme.offWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.space8),
                decoration: BoxDecoration(
                  color: (titleColor ?? AppTheme.vibrantBlue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  icon,
                  color: titleColor ?? AppTheme.vibrantBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.space16),
              Expanded(
                child:
                    child ??
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: titleColor ?? theme.colorScheme.onSurface,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppTheme.space2),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyPickerSheet(
        selectedCurrency: _selectedCurrency,
        onCurrencySelected: (currency) {
          setState(() => _selectedCurrency = currency);
          _saveCurrencyPreference(currency);
        },
      ),
    );
  }

  void _showThemeSelector() {
    final themeCubit = context.read<ThemeCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ThemeSelectorSheet(cubit: themeCubit),
    );
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  const _CurrencyPickerSheet({
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  final String selectedCurrency;
  final Function(String) onCurrencySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencies = CurrencyFormatter.getPopularCurrencies();

    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusXL),
          topRight: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space24),
          Text(
            'Select Currency',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.space24),
          ...currencies.map(
            (currency) => _buildCurrencyOption(
              context,
              currency,
              selectedCurrency == currency['code'],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom + AppTheme.space24,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(
    BuildContext context,
    Map<String, String> currency,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onCurrencySelected(currency['code']!);
            Navigator.of(context).pop();
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.vibrantBlue.withOpacity(0.1)
                  : (isDark ? AppTheme.charcoalBlack : AppTheme.offWhite),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: isSelected
                    ? AppTheme.vibrantBlue.withOpacity(0.3)
                    : theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.vibrantBlue.withOpacity(0.1)
                        : theme.colorScheme.outline.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Center(
                    child: Text(
                      currency['symbol']!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? AppTheme.vibrantBlue
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency['code']!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.vibrantBlue
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        currency['name']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    color: AppTheme.vibrantBlue,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeSelectorSheet extends StatelessWidget {
  const _ThemeSelectorSheet({required this.cubit});

  final ThemeCubit cubit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusXL),
          topRight: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space24),
          Text(
            'Theme',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.space24),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, currentMode) {
              return Column(
                children: [
                  _buildThemeOption(
                    context,
                    'System',
                    'Follow system setting',
                    Icons.settings_rounded,
                    ThemeMode.system,
                    currentMode,
                  ),
                  const SizedBox(height: AppTheme.space12),
                  _buildThemeOption(
                    context,
                    'Light',
                    'Light theme',
                    Icons.light_mode_rounded,
                    ThemeMode.light,
                    currentMode,
                  ),
                  const SizedBox(height: AppTheme.space12),
                  _buildThemeOption(
                    context,
                    'Dark',
                    'Dark theme',
                    Icons.dark_mode_rounded,
                    ThemeMode.dark,
                    currentMode,
                  ),
                ],
              );
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom + AppTheme.space24,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    ThemeMode mode,
    ThemeMode currentMode,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = currentMode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          cubit.setTheme(mode);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.space16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.vibrantBlue.withOpacity(0.1)
                : (isDark ? AppTheme.charcoalBlack : AppTheme.offWhite),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: isSelected
                  ? AppTheme.vibrantBlue.withOpacity(0.3)
                  : theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.space8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.vibrantBlue.withOpacity(0.1)
                      : theme.colorScheme.outline.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.vibrantBlue
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.vibrantBlue
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  color: AppTheme.vibrantBlue,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
