import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/countries.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  Country _country = kCountries.first;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // Formate en "00 000 00 00" comme dans la PWA
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

  Future<void> _login() async {
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 9 || _passCtrl.text.isEmpty) {
      _showError('Veuillez remplir tous les champs obligatoires');
      return;
    }
    if (_passCtrl.text.length < 8) {
      _showError('Mot de passe trop court — minimum 8 caractères requis');
      return;
    }

    setState(() => _loading = true);
    // TODO: appel API via AuthService (prochaine étape)
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('← Retour', style: TextStyle(color: AppColors.primary)),
        ),
        leadingWidth: 100,
        title: const Text('Connexion', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Text('Bon retour 👋',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Connectez-vous pour louer une batterie',
                    style: TextStyle(color: AppColors.gray400, fontSize: 14)),
              ),
              const SizedBox(height: 28),

              // TÉLÉPHONE
              const Text.rich(TextSpan(children: [
                TextSpan(text: 'TÉLÉPHONE ', style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gray400)),
                TextSpan(text: '★', style: TextStyle(color: AppColors.red)),
              ])),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Country>(
                        value: _country,
                        dropdownColor: AppColors.surface,
                        items: kCountries.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.flag} ${c.code}',
                              style: const TextStyle(color: Colors.white)),
                        )).toList(),
                        onChanged: (c) => setState(() => _country = c!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 12,
                      style: const TextStyle(color: Colors.white),
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

              // MOT DE PASSE
              const Text.rich(TextSpan(children: [
                TextSpan(text: 'MOT DE PASSE ', style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gray400)),
                TextSpan(text: '★', style: TextStyle(color: AppColors.red)),
              ])),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Minimum 8 caractères',
                  suffixIcon: IconButton(
                    icon: Text(_obscure ? '👁' : '🙈'),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Légende + mot de passe oublié
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text.rich(TextSpan(children: [
                    TextSpan(text: '★ ', style: TextStyle(color: AppColors.red)),
                    TextSpan(text: 'Champ obligatoire',
                        style: TextStyle(color: AppColors.gray400, fontSize: 12)),
                  ])),
                  GestureDetector(
                    onTap: () {
                      // TODO: navigation vers forgot-password
                    },
                    child: const Text('Mot de passe oublié ?',
                        style: TextStyle(color: AppColors.primary, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // BOUTON CONNEXION
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('Se connecter'),
                ),
              ),
              const SizedBox(height: 20),

              Row(children: const [
                Expanded(child: Divider(color: AppColors.gray700)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('ou', style: TextStyle(color: AppColors.gray500)),
                ),
                Expanded(child: Divider(color: AppColors.gray700)),
              ]),
              const SizedBox(height: 20),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.gray400, fontSize: 14),
                    children: [
                      const TextSpan(text: 'Pas encore de compte ? '),
                      TextSpan(
                        text: 'Créer un compte',
                        style: const TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: navigation vers register
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}