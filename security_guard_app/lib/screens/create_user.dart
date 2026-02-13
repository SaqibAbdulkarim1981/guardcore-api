import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../widgets/primary_button.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _days = TextEditingController(text: '30');
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _days.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    
    final apiService = context.read<ApiService>();
    final days = int.tryParse(_days.text.trim()) ?? 30;
    
    final user = await apiService.createUser(
      name: _name.text.trim(),
      email: _email.text.trim(),
      activeDays: days,
    );

    if (user != null && mounted) {
      // Compose invitation email
      final appDownload = 'https://example.com/download';
      final subject = Uri.encodeComponent('You are invited to Security Guard App');
      final body = Uri.encodeComponent(
        'Hello ${_name.text.trim()},\n\n'
        'You have been invited as a user to the Security Guard App.\n\n'
        'Your account is active for $days days.\n\n'
        'Download the app: $appDownload\n\n'
        'Regards,\nSuper Admin'
      );
      final mailto = Uri.parse('mailto:${_email.text.trim()}?subject=$subject&body=$body');
      
      try {
        if (await canLaunchUrl(mailto)) {
          await launchUrl(mailto);
        }
      } catch (e) {
        // Email client not available
      }

      setState(() => _loading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ${user.name} created successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create user. Check backend connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => (v == null || v.isEmpty) ? 'Enter name' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || v.isEmpty) ? 'Enter email' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _days, decoration: const InputDecoration(labelText: 'Days active'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.isEmpty) ? 'Enter days' : null),
              const SizedBox(height: 18),
              PrimaryButton(label: 'Create and Send Invite', onPressed: _submit, loading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}
