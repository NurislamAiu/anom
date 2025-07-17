import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../../../providers/auth_provider.dart';

class VerificationBusinessScreen extends StatefulWidget {
  const VerificationBusinessScreen({super.key});

  @override
  State<VerificationBusinessScreen> createState() => _VerificationBusinessScreenState();
}

class _VerificationBusinessScreenState extends State<VerificationBusinessScreen> {
  final companyNameController = TextEditingController();
  final companyWebsiteController = TextEditingController();
  final companyLocationController = TextEditingController();
  final businessReasonController = TextEditingController();
  final registrationNumberController = TextEditingController();
  bool isSubmitting = false;
  bool isRequestTooSoon = false;

  @override
  void initState() {
    super.initState();
    checkPreviousBusinessRequest();
  }

  Future<void> checkPreviousBusinessRequest() async {
    final username = context.read<AuthProvider>().username ?? '';
    final doc = await FirebaseFirestore.instance
        .collection('verification_requests_business')
        .doc(username)
        .get();

    if (doc.exists) {
      final timestamp = doc['timestamp'] as Timestamp?;
      if (timestamp != null) {
        final now = DateTime.now();
        final last = timestamp.toDate();
        final difference = now.difference(last).inDays;
        if (difference < 7) {
          setState(() {
            isRequestTooSoon = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = context.read<AuthProvider>().username ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Business Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fill out the form below to apply for business verification.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            _textField(companyNameController, 'Company Name *'),
            const SizedBox(height: 16),
            _textField(registrationNumberController, 'Registration Number *'),
            const SizedBox(height: 16),
            _textField(companyLocationController, 'Country & City *'),
            const SizedBox(height: 16),
            _textField(companyWebsiteController, 'Website or Public Profile *'),
            const SizedBox(height: 16),
            _textField(businessReasonController, 'Why should your business be verified? *', maxLines: 3),
            const Spacer(),
            if (isRequestTooSoon)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'You’ve already submitted a request recently. Please wait 7 days before submitting again.',
                  style: TextStyle(color: Colors.red[400], fontSize: 14),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting || isRequestTooSoon ? null : _handleSubmit,
                icon: isSubmitting
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballPulse,
                    colors: [Colors.black],
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.send),
                label: isSubmitting
                    ? const Text('Submitting...')
                    : const Text('Submit Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final username = context.read<AuthProvider>().username ?? '';

    if (companyNameController.text.trim().isEmpty ||
        companyWebsiteController.text.trim().isEmpty ||
        registrationNumberController.text.trim().isEmpty ||
        businessReasonController.text.trim().isEmpty ||
        companyLocationController.text.trim().isEmpty) {
      Flushbar(
        title: 'Missing Fields',
        message: 'Please fill in all required fields.',
        backgroundColor: Colors.red[400]!,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }

    setState(() => isSubmitting = true);

    await FirebaseFirestore.instance
        .collection('verification_requests_business')
        .doc(username)
        .set({
      'username': username,
      'type': 'business',
      'companyName': companyNameController.text.trim(),
      'registrationNumber': registrationNumberController.text.trim(),
      'location': companyLocationController.text.trim(),
      'website': companyWebsiteController.text.trim(),
      'reason': businessReasonController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => isSubmitting = false);
    if (!mounted) return;

    Navigator.pop(context);

    Flushbar(
      title: 'Request Submitted',
      message: 'Your business verification request has been submitted successfully. Our team will review it within a few days.',
      icon: const Icon(Icons.verified_user, color: Colors.lightBlueAccent),
      backgroundColor: Colors.grey[900]!,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 4),
    ).show(context);
  }

  Widget _textField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    companyNameController.dispose();
    companyWebsiteController.dispose();
    registrationNumberController.dispose();
    companyLocationController.dispose();
    businessReasonController.dispose();
    super.dispose();
  }
}
