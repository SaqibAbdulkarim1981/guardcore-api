import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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

  Future<void> _printReport(Map<String, dynamic> report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue900,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'GuardCore Security Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      report['type'] ?? 'Unknown Type',
                      style: const pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Report Details
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildPdfRow('Report ID:', '#${report['id'] ?? 'N/A'}'),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('Type:', report['type'] ?? 'N/A'),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('User ID:', '${report['userId'] ?? 'N/A'}'),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('Location ID:', '${report['locationId'] ?? 'N/A'}'),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('Date & Time:', _formatDate(report['createdAt'])),
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'Description:',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        report['description'] ?? 'No description provided',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generated on: ${DateTime.now().toString().substring(0, 19)}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.Text(
                'GuardCore Security System - Confidential',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _printAllReports() async {
    if (_reports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reports to print')),
      );
      return;
    }

    final pdf = pw.Document();

    // Group reports by type
    final incidents = _reports.where((r) => r['type']?.toString().toLowerCase() == 'incident').toList();
    final activities = _reports.where((r) => r['type']?.toString().toLowerCase() == 'activity').toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue900,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'GuardCore Security Reports',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Summary Report',
                    style: const pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Report Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  _buildPdfRow('Total Reports:', '${_reports.length}'),
                  pw.SizedBox(height: 6),
                  _buildPdfRow('Incident Reports:', '${incidents.length}'),
                  pw.SizedBox(height: 6),
                  _buildPdfRow('Activity Reports:', '${activities.length}'),
                  pw.SizedBox(height: 6),
                  _buildPdfRow('Generated:', DateTime.now().toString().substring(0, 19)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Incident Reports Section
            if (incidents.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'INCIDENT REPORTS (${incidents.length})',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red900,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              ..._buildReportsList(incidents),
              pw.SizedBox(height: 24),
            ],

            // Activity Reports Section
            if (activities.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'ACTIVITY REPORTS (${activities.length})',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green900,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              ..._buildReportsList(activities),
            ],

            pw.Spacer(),

            // Footer
            pw.Divider(color: PdfColors.grey),
            pw.SizedBox(height: 8),
            pw.Text(
              'GuardCore Security System - Confidential Document',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey,
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  List<pw.Widget> _buildReportsList(List<Map<String, dynamic>> reports) {
    return reports.map((report) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '#${report['id']} - ${report['type']}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  _formatDate(report['createdAt']),
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'User: ${report['userId'] ?? 'N/A'} | Location: ${report['locationId'] ?? 'N/A'}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              report['description'] ?? 'No description',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          if (_reports.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'Print All Reports',
              onPressed: _printAllReports,
            ),
        ],
      ),
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
                                  trailing: IconButton(
                                    icon: const Icon(Icons.print_outlined),
                                    tooltip: 'Print Report',
                                    onPressed: () => _printReport(report),
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
