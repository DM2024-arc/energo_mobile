import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/countries.dart';
import '../services/payment_service.dart';
import 'session_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String stationDeviceId;
  final String stationName;
  final int durationMinutes;
  final String durationLabel;
  final int amount;

  const PaymentScreen({
    super.key,
    required this.stationDeviceId,
    required this.stationName,
    required this.durationMinutes,
    required this.durationLabel,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _phoneCtrl = TextEditingController();
  Country _country = kCountries.first;
  String _operator = 'mtn'; // mtn | airtel
  bool _loading = false;
  String? _statusMessage;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 9) {
      _showError('Entrez votre numéro Mobile Money (9 chiffres)');
      return;
    }

    setState(() {
      _loading = true;
      _statusMessage = 'Création de la location…';
    });

    try {
      final fullPhone = _country.code + digits;

      // 1. Créer la location
      final rental = await PaymentService.createRental(
          widget.stationDeviceId, widget.durationMinutes);
      final rentalId = (rental['rentalId'] ?? rental['id']).toString();
      final paymentId = (rental['paymentId'] ?? '').toString();

      setState(() => _statusMessage = 'Confirmez le paiement sur votre téléphone…');

      // 2. Initier le paiement
      await PaymentService.initiatePayment(rentalId, _operator, fullPhone);

      // 3. Polling du statut (jusqu'à 2 minutes)
      await _pollPayment(paymentId, rentalId);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _pollPayment(String paymentId, String rentalId, [int attempt = 0]) async {
    if (attempt >= 24) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('Délai dépassé — réessayez');
      return;
    }

    try {
      final status = await PaymentService.getPaymentStatus(paymentId);
      final s = status['status'];

      if (s == 'success') {
        final rental = await PaymentService.getRental(rentalId);
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SessionScreen(rental: rental)),
        );
      } else if (s == 'failed') {
        if (!mounted) return;
        setState(() => _loading = false);
        _showError('Paiement refusé par l\'opérateur');
      } else {
        await Future.delayed(const Duration(seconds: 5));
        if (!mounted) return;
        await _pollPayment(paymentId, rentalId, attempt + 1);
      }
    } catch (_) {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;
      await _pollPayment(paymentId, rentalId, attempt + 1);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.energoColors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.energoColors;
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text('← Retour', style: TextStyle(color: c.primary)),
        ),
        leadingWidth: 100,
        title: const Text('Paiement', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Récapitulatif
              Container(
                padding: const EdgeInsets.all(18),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: c.surface800,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.surface700),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Récapitulatif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    _SummaryRow(label: 'Borne', value: widget.stationName, c: c),
                    _SummaryRow(label: 'Durée', value: widget.durationLabel, c: c),
                    Divider(color: c.surface700, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total à payer', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${widget.amount} FCFA', style: TextStyle(
                            color: c.primary, fontWeight: FontWeight.w900, fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('OPÉRATEUR MOBILE MONEY',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textSecondary, letterSpacing: 1)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _OperatorCard(
                      label: 'MTN Money', emoji: '📱', color: const Color(0xFFFFCC00),
                      selected: _operator == 'mtn', c: c,
                      onTap: () => setState(() => _operator = 'mtn'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _OperatorCard(
                      label: 'Airtel Money', emoji: '📱', color: const Color(0xFFE40000),
                      selected: _operator == 'airtel', c: c,
                      onTap: () => setState(() => _operator = 'airtel'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text('NUMÉRO MOBILE MONEY',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textSecondary, letterSpacing: 1)),
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
                          child: Text('${ctry.flag} ${ctry.code}', style: TextStyle(color: c.textPrimary)),
                        )).toList(),
                        onChanged: _loading ? null : (ctry) => setState(() => _country = ctry!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      enabled: !_loading,
                      keyboardType: TextInputType.phone,
                      maxLength: 9,
                      style: TextStyle(color: c.textPrimary),
                      decoration: const InputDecoration(hintText: '06 000 00 00', counterText: ''),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _pay,
                  child: _loading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 18, width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            Text(_statusMessage ?? 'Chargement…'),
                          ],
                        )
                      : const Text('Payer maintenant'),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text('🔒 Paiement sécurisé · Aucune donnée bancaire stockée',
                    style: TextStyle(color: c.textSecondary, fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final EnergoColors c;
  const _SummaryRow({required this.label, required this.value, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: c.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _OperatorCard extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool selected;
  final EnergoColors c;
  final VoidCallback onTap;

  const _OperatorCard({
    required this.label, required this.emoji, required this.color,
    required this.selected, required this.c, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? c.primary.withValues(alpha: 0.07) : c.surface800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? c.primary : c.surface700, width: selected ? 2 : 1.5),
        ),
        child: Column(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}