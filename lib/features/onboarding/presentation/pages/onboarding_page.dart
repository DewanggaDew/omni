import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omni/core/utils/currency.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  String? _currency;
  String? _country;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final locale = PlatformDispatcher.instance.locale;
    _currency = defaultCurrencyForLocale(locale);
    _country = locale.countryCode?.toUpperCase();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'currency': _currency,
        'country': _country,
        'needsOnboarding': false,
      });
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _currency,
                items: const [
                  DropdownMenuItem(
                    value: 'IDR',
                    child: Text('IDR - Indonesian Rupiah'),
                  ),
                  DropdownMenuItem(
                    value: 'MYR',
                    child: Text('MYR - Malaysian Ringgit'),
                  ),
                  DropdownMenuItem(
                    value: 'USD',
                    child: Text('USD - US Dollar'),
                  ),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                ],
                onChanged: (v) => setState(() => _currency = v),
                decoration: const InputDecoration(labelText: 'Base currency'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Select currency' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _country ?? '',
                decoration: const InputDecoration(
                  labelText: 'Country (ISO code, e.g. ID)',
                ),
                onChanged: (v) => _country = v.toUpperCase(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
