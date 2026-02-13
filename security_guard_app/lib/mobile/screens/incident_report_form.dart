import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';

class IncidentReportFormScreen extends StatefulWidget {
  const IncidentReportFormScreen({super.key});

  @override
  State<IncidentReportFormScreen> createState() => _IncidentReportFormScreenState();
}

class _IncidentReportFormScreenState extends State<IncidentReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationCtrl = TextEditingController();
  final _incidentTypeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _actionTakenCtrl = TextEditingController();
  final _witnessCtrl = TextEditingController();
  
  String? _selectedSeverity;
  TimeOfDay? _selectedTime;
  bool _loading = false;

  final List<String> _severities = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void dispose() {
    _locationCtrl.dispose();
    _incidentTypeCtrl.dispose();
    _descriptionCtrl.dispose();
    _actionTakenCtrl.dispose();
    _witnessCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    final apiService = context.read<ApiService>();
    final reportData = {
      'type': 'Incident',
      'location': _locationCtrl.text,
      'incidentType': _incidentTypeCtrl.text,
      'severity': _selectedSeverity,
      'time': _selectedTime?.format(context),
      'description': _descriptionCtrl.text,
      'actionTaken': _actionTakenCtrl.text,
      'witness': _witnessCtrl.text,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    try {
      await apiService.submitReport(reportData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incident report submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Report'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Report any incidents immediately',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Location
              TextFormField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  labelText: 'Incident Location *',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter location' : null,
              ),
              const SizedBox(height: 16),
              
              // Incident Type
              TextFormField(
                controller: _incidentTypeCtrl,
                decoration: InputDecoration(
                  labelText: 'Incident Type *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: 'e.g., Theft, Vandalism, Fire, etc.',
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter incident type' : null,
              ),
              const SizedBox(height: 16),
              
              // Severity
              DropdownButtonFormField<String>(
                initialValue: _selectedSeverity,
                decoration: InputDecoration(
                  labelText: 'Severity *',
                  prefixIcon: const Icon(Icons.priority_high),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _severities.map((severity) {
                  return DropdownMenuItem(value: severity, child: Text(severity));
                }).toList(),
                onChanged: (value) => setState(() => _selectedSeverity = value),
                validator: (v) => v == null ? 'Select severity' : null,
              ),
              const SizedBox(height: 16),
              
              // Time
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time of Incident *',
                    prefixIcon: const Icon(Icons.schedule),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  child: Text(
                    _selectedTime?.format(context) ?? 'Select time',
                    style: TextStyle(
                      color: _selectedTime == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionCtrl,
                decoration: InputDecoration(
                  labelText: 'Incident Description *',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: 'Provide detailed description of what happened',
                ),
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty) ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
              
              // Action Taken
              TextFormField(
                controller: _actionTakenCtrl,
                decoration: InputDecoration(
                  labelText: 'Action Taken *',
                  prefixIcon: const Icon(Icons.check_circle_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: 'What actions did you take?',
                ),
                maxLines: 3,
                validator: (v) => (v == null || v.isEmpty) ? 'Enter action taken' : null,
              ),
              const SizedBox(height: 16),
              
              // Witness
              TextFormField(
                controller: _witnessCtrl,
                decoration: InputDecoration(
                  labelText: 'Witness (if any)',
                  prefixIcon: const Icon(Icons.people),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: 'Name and contact of witness',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submitReport,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(_loading ? 'Submitting...' : 'Submit Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
