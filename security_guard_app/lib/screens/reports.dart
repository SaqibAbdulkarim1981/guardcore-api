import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/common_appbar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> _reports = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      final apiService = context.read<ApiService>();
      
      // Debug: Print authentication status
      debugPrint('🔍 Reports Screen - Checking authentication...');
      debugPrint('Is Authenticated: ${apiService.isAuthenticated}');
      debugPrint('Token exists: ${apiService.token != null}');
      
      // Check if authenticated
      if (!apiService.isAuthenticated) {
        setState(() {
          _error = 'Not authenticated. Please login first.';
          _loading = false;
        });
        return;
      }
      
      debugPrint('🔍 Fetching reports from API...');
      final reports = await apiService.fetchReports();
      debugPrint('✅ Received ${reports.length} reports');
      if (mounted) {
        setState(() {
          _reports = reports;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading reports: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load reports: ${e.toString()}';
          _loading = false;
        });
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Reports'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadReports,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                          child: const Text('Go to Login'),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Reports: ${_reports.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadReports,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _reports.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No reports yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Reports will appear here when users\nsubmit activity or incident reports.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _reports.length,
                            itemBuilder: (context, i) {
                              final report = _reports[i];
                              final isIncident = report['type']?.toString().toLowerCase() == 'incident';
                              
                              return Card(
                                color: isIncident 
                                    ? Colors.red.shade50 
                                    : Colors.white,
                                child: ListTile(
                                  leading: Icon(
                                    isIncident ? Icons.warning : Icons.check_circle,
                                    color: isIncident ? Colors.red : Colors.green,
                                    size: 32,
                                  ),
                                  title: Text(
                                    report['type'] ?? 'Unknown Type',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isIncident ? Colors.red.shade900 : Colors.black,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (report['description'] != null)
                                        Text(report['description']),
                                      const SizedBox(height: 4),
                                      Text(
                                        'User ID: ${report['userId'] ?? 'N/A'} • Location ID: ${report['locationId'] ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                      Text(
                                        _formatDate(report['createdAt']),
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
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
