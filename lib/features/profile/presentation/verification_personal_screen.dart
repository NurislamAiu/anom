import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../../providers/auth_provider.dart';

class VerificationPersonalScreen extends StatefulWidget {
  const VerificationPersonalScreen({super.key});

  @override
  State<VerificationPersonalScreen> createState() => _VerificationPersonalScreenState();
}

class _VerificationPersonalScreenState extends State<VerificationPersonalScreen> {
  final fullNameController = TextEditingController();
  final reasonController = TextEditingController();
  final socialLinkController = TextEditingController();
  final idNumberController = TextEditingController();
  final locationController = TextEditingController();
  bool isSubmitting = false;
  bool isRequestTooSoon = false;

  @override
  void initState() {
    super.initState();
    checkPreviousRequest();
  }

  Future<void> checkPreviousRequest() async {
    final username = context.read<AuthProvider>().username ?? '';
    final doc = await FirebaseFirestore.instance
        .collection('verification_requests')
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
        title: const Text('Personal Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fill out the form below to apply for verification.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            _textField(fullNameController, 'Full Name *'),
            const SizedBox(height: 16),
            _textField(idNumberController, 'ID Number (Passport or National ID) *'),
            const SizedBox(height: 16),
            _textField(locationController, 'Country & City *'),
            const SizedBox(height: 16),
            _textField(reasonController, 'Why should you be verified? *', maxLines: 3),
            const SizedBox(height: 16),
            _textField(socialLinkController, 'Link to public profile or article *'),
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

    if (fullNameController.text.trim().isEmpty ||
        reasonController.text.trim().isEmpty ||
        socialLinkController.text.trim().isEmpty ||
        idNumberController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      Flushbar(
        title: 'Missing Fields',
        message: 'Please fill in all required fields.',
        backgroundColor: Colors.red[400]!,
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
        duration: const Duration(seconds: 3),
      ).show(context);
      return;
    }

    setState(() => isSubmitting = true);

    await FirebaseFirestore.instance
        .collection('verification_requests')
        .doc(username)
        .set({
      'username': username,
      'type': 'personal',
      'fullName': fullNameController.text.trim(),
      'reason': reasonController.text.trim(),
      'link': socialLinkController.text.trim(),
      'idNumber': idNumberController.text.trim(),
      'location': locationController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => isSubmitting = false);
    if (!mounted) return;

    Navigator.pop(context);
    Flushbar(
      title: 'Submitted',
      message: 'Your request is under review.',
      icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
      backgroundColor: Colors.grey[900]!,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 3),
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
    fullNameController.dispose();
    reasonController.dispose();
    socialLinkController.dispose();
    idNumberController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
