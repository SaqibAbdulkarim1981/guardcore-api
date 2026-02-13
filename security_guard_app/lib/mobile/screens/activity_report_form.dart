import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';

class ActivityReportFormScreen extends StatefulWidget {
  const ActivityReportFormScreen({super.key});

  @override
  State<ActivityReportFormScreen> createState() => _ActivityReportFormScreenState();
}

class _ActivityReportFormScreenState extends State<ActivityReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationCtrl = TextEditingController();
  final _activityCtrl = TextEditingController();
  final _observationsCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  
  String? _selectedShift;
  TimeOfDay? _selectedTime;
  bool _loading = false;

  final List<String> _shifts = ['Day', 'Night', 'Evening'];

  @override
  void dispose() {
    _locationCtrl.dispose();
    _activityCtrl.dispose();
    _observationsCtrl.dispose();
    _remarksCtrl.dispose();
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
      'type': 'Activity',
      'location': _locationCtrl.text,
      'activity': _activityCtrl.text,
      'shift': _selectedShift,
      'time': _selectedTime?.format(context),
      'observations': _observationsCtrl.text,
      'remarks': _remarksCtrl.text,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    try {
      await apiService.submitReport(reportData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity report submitted successfully'),
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
        title: const Text('Activity Report'),
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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.assignment_outlined, color: Colors.blue.shade700, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Fill out the activity report form',
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
                  labelText: 'Location *',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter location' : null,
              ),
              const SizedBox(height: 16),
              
              // Shift
              DropdownButtonFormField<String>(
                initialValue: _selectedShift,
                decoration: InputDecoration(
                  labelText: 'Shift *',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _shifts.map((shift) {
                  return DropdownMenuItem(value: shift, child: Text(shift));
                }).toList(),
                onChanged: (value) => setState(() => _selectedShift = value),
                validator: (v) => v == null ? 'Select shift' : null,
              ),
              const SizedBox(height: 16),
              
              // Time
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time *',
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
              
              // Activity
              TextFormField(
                controller: _activityCtrl,
                decoration: InputDecoration(
                  labelText: 'Activity Performed *',
                  prefixIcon: const Icon(Icons.work_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 3,
                validator: (v) => (v == null || v.isEmpty) ? 'Enter activity' : null,
              ),
              const SizedBox(height: 16),
              
              // Observations
              TextFormField(
                controller: _observationsCtrl,
                decoration: InputDecoration(
                  labelText: 'Observations',
                  prefixIcon: const Icon(Icons.visibility),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Remarks
              TextFormField(
                controller: _remarksCtrl,
                decoration: InputDecoration(
                  labelText: 'Remarks',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                    backgroundColor: Colors.blue.shade700,
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
