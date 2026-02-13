import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/common_appbar.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<Map<String, dynamic>> _locations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    final apiService = context.read<ApiService>();
    final locations = await apiService.fetchLocations();
    if (mounted) {
      setState(() {
        _locations = locations;
        _loading = false;
      });
    }
  }

  Future<void> _createLocation() async {
    if (_nameCtrl.text.trim().isEmpty) return;

    final apiService = context.read<ApiService>();
    final location = await apiService.createLocation(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );

    if (location != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location "${location['name']}" created!')),
      );
      _nameCtrl.clear();
      _descCtrl.clear();
      await _loadLocations();
    }
  }

  void _showQrCode(Map<String, dynamic> location) {
    final apiService = context.read<ApiService>();
    final qrUrl = apiService.getQrCodeUrl(location['id']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              qrUrl,
              width: 250,
              height: 250,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 100),
              headers: apiService.token != null 
                  ? {'Authorization': 'Bearer ${apiService.token}'}
                  : {},
            ),
            const SizedBox(height: 12),
            Text(
              location['description'] ?? 'No description',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Locations & QR Codes'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create New Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Location name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _createLocation,
                    icon: const Icon(Icons.add_location),
                    label: const Text('Create Location'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Existing Locations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _locations.isEmpty
                        ? const Center(child: Text('No locations yet'))
                        : ListView.builder(
                            itemCount: _locations.length,
                            itemBuilder: (context, i) {
                              final loc = _locations[i];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.location_on),
                                  title: Text(loc['name'] ?? ''),
                                  subtitle: Text(loc['description'] ?? 'No description'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.qr_code_2),
                                    onPressed: () => _showQrCode(loc),
                                    tooltip: 'Show QR Code',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
