import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/countries.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _pass2Ctrl  = TextEditingController();
  Country _country = kCountries.first;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _cgu = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 9) digits = digits.substring(0, 9);

    String formatted = '';
    if (digits.isNotEmpty) formatted += digits.substring(0, digits.length.clamp(0, 2));
    if (digits.length > 2) formatted += ' ${digits.substring(2, digits.length.clamp(2, 5))}';
    if (digits.length > 5) formatted += ' ${digits.substring(5, digits.length.clamp(5, 7))}';
    if (digits.length > 7) formatted += ' ${digits.substring(7, digits.length.clamp(7, 9))}';

    if (formatted != value) {
      _phoneCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.energoColors.red),
    );
  }

  String _friendlyError(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('409') || msg.contains('exist') || msg.contains('already')) {
      return 'Un compte existe déjà avec ce numéro — connectez-vous ou utilisez un autre numéro';
    }
    if (msg.contains('socketexception') || msg.contains('failed host lookup') ||
        msg.contains('connection')) {
      return 'Connexion au serveur impossible — vérifiez votre connexion Internet';
    }
    return raw.replaceAll('Exception: ', '');
  }

  Future<void> _register() async {
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    final pass   = _passCtrl.text;

    if (digits.length != 9) {
      return _showError("Numéro invalide — saisissez exactement 9 chiffres");
    }
    if (pass.isEmpty) {
      return _showError("Le mot de passe est obligatoire");
    }
    if (pass.length < 8) {
      return _showError("Mot de passe trop court — minimum 8 caractères requis");
    }
    if (!RegExp(r'[A-Z]').hasMatch(pass)) {
      return _showError("Le mot de passe doit contenir au moins une majuscule (ex: Oko@2021)");
    }
    if (!RegExp(r'[0-9]').hasMatch(pass)) {
      return _showError("Le mot de passe doit contenir au moins un chiffre (ex: Oko@2021)");
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(pass)) {
      return _showError("Le mot de passe doit contenir au moins un caractère spécial (ex: @, #, !)");
    }
    if (pass != _pass2Ctrl.text) {
      return _showError("Les mots de passe ne correspondent pas");
    }
    if (!_cgu) {
      return _showError("Veuillez accepter les conditions d'utilisation");
    }

    setState(() => _loading = true);
    try {
      final fullPhone = _country.code + digits;
      await AuthService.register(_nameCtrl.text.trim(), fullPhone, pass);

      if (!mounted) return;

      final profile = await AuthService.getMe();
      final name = (profile['fullName'] ?? profile['name'] ?? '').toString();
      final prenom = name.trim().isNotEmpty ? name.trim().split(' ').first : '';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Compte créé avec succès ! Bienvenue $prenom 🎉'),
          backgroundColor: context.energoColors.primary,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(profile: profile)),
      );
    } catch (e) {
      _showError(_friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.energoColors;
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('← Retour', style: TextStyle(color: c.primary)),
        ),
        leadingWidth: 100,
        title: const Text('Inscription', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Center(
                child: Text('Créer un compte',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              ),
              Center(
                child: Text('Rejoignez ENERGO Congo',
                    style: TextStyle(color: c.textSecondary, fontSize: 14)),
              ),
              const SizedBox(height: 24),

              Text('NOM COMPLET',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                style: TextStyle(color: c.textPrimary),
                decoration: const InputDecoration(hintText: 'Jean Mbemba'),
              ),
              const SizedBox(height: 16),

              Text.rich(TextSpan(children: [
                TextSpan(text: 'TÉLÉPHONE ', style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: c.textSecondary)),
                TextSpan(text: '★', style: TextStyle(color: c.red)),
              ])),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 52,
                    decoration: BoxDecoration(
                      color: c.surface800,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.surface700),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Country>(
                        value: _country,
                        dropdownColor: c.surface800,
                        items: kCountries.map((ctry) => DropdownMenuItem(
                          value: ctry,
                          child: Text('${ctry.flag} ${ctry.code}',
                              style: TextStyle(color: c.textPrimary)),
                        )).toList(),
                        onChanged: (ctry) => setState(() => _country = ctry!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 12,
                      style: TextStyle(color: c.textPrimary),
                      onChanged: _onPhoneChanged,
                      decoration: const InputDecoration(
                        hintText: '00 000 00 00',
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text.rich(TextSpan(children: [
                TextSpan(text: 'MOT DE PASSE ', style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: c.textSecondary)),
                TextSpan(text: '★', style: TextStyle(color: c.red)),
              ])),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure1,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Minimum 8 caractères',
                  suffixIcon: IconButton(
                    icon: Text(_obscure1 ? '👁' : '🙈'),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text('Ex: Oko@2021 (majuscule, chiffre, symbole)',
                  style: TextStyle(color: c.textSecondary, fontSize: 12)),
              const SizedBox(height: 16),

              Text.rich(TextSpan(children: [
                TextSpan(text: 'CONFIRMER LE MOT DE PASSE ', style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: c.textSecondary)),
                TextSpan(text: '★', style: TextStyle(color: c.red)),
              ])),
              const SizedBox(height: 8),
              TextField(
                controller: _pass2Ctrl,
                obscureText: _obscure2,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Répétez le mot de passe',
                  suffixIcon: IconButton(
                    icon: Text(_obscure2 ? '👁' : '🙈'),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _cgu,
                    activeColor: c.primary,
                    onChanged: (v) => setState(() => _cgu = v ?? false),
                  ),
                  Expanded(
                    child: Text(
                      "J'accepte les conditions d'utilisation",
                      style: TextStyle(color: c.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('Créer mon compte'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}