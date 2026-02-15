import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/attendance.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  AppUser? _selectedGuard;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  List<Attendance> _attendanceRecords = [];
  List<AttendanceRecord> _processedRecords = [];
  bool _loading = false;
  String? _error;
  Duration _totalWorkHours = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGuards();
    });
  }

  Future<void> _loadGuards() async {
    final apiService = context.read<ApiService>();
    await apiService.fetchUsers();
  }

  Future<void> _loadAttendanceReport() async {
    if (_selectedGuard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a guard first')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final userId = int.tryParse(_selectedGuard!.id);
      
      if (userId == null) {
        throw Exception('Invalid user ID');
      }

      debugPrint('📊 Loading attendance for user ID: $userId');
      final records = await apiService.fetchUserAttendance(userId);
      
      // Filter by date range
      final filteredRecords = records.where((record) {
        return record.timestamp.isAfter(_fromDate.subtract(const Duration(days: 1))) &&
               record.timestamp.isBefore(_toDate.add(const Duration(days: 1)));
      }).toList();

      debugPrint('📊 Filtered ${filteredRecords.length} records in date range');
      
      // Process check-in/check-out pairs
      final processed = _processAttendanceRecords(filteredRecords);
      
      // Calculate total work hours
      Duration total = Duration.zero;
      for (var record in processed) {
        total += record.workDuration;
      }

      setState(() {
        _attendanceRecords = filteredRecords;
        _processedRecords = processed;
        _totalWorkHours = total;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading attendance: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<AttendanceRecord> _processAttendanceRecords(List<Attendance> records) {
    final List<AttendanceRecord> processed = [];
    final sortedRecords = List<Attendance>.from(records)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    Attendance? currentCheckIn;
    
    for (var record in sortedRecords) {
      if (record.type == 'CheckIn') {
        currentCheckIn = record;
      } else if (record.type == 'CheckOut' && currentCheckIn != null) {
        processed.add(AttendanceRecord(
          checkIn: currentCheckIn.timestamp,
          checkOut: record.timestamp,
          locationName: currentCheckIn.locationName,
        ));
        currentCheckIn = null;
      }
    }
    
    // Add any unclosed check-ins
    if (currentCheckIn != null) {
      processed.add(AttendanceRecord(
        checkIn: currentCheckIn.timestamp,
        checkOut: null,
        locationName: currentCheckIn.locationName,
      ));
    }

    return processed;
  }

  Future<void> _selectFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  Future<void> _printReport() async {
    if (_selectedGuard == null || _processedRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to print')),
      );
      return;
    }

    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                children: [
                  pw.Text(
                    'GuardCore Attendance Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Guard Name: ${_selectedGuard!.name}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Report Period: ${DateFormat('dd/MM/yyyy').format(_fromDate)} - ${DateFormat('dd/MM/yyyy').format(_toDate)}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),
            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FixedColumnWidth(40),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('S.No.', isHeader: true),
                    _buildTableCell('Check In Date/Time', isHeader: true),
                    _buildTableCell('Check Out Date/Time', isHeader: true),
                    _buildTableCell('Hours Worked', isHeader: true),
                  ],
                ),
                // Data rows
                ..._processedRecords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  return pw.TableRow(
                    children: [
                      _buildTableCell('${index + 1}'),
                      _buildTableCell(DateFormat('dd/MM/yyyy HH:mm').format(record.checkIn)),
                      _buildTableCell(
                        record.checkOut != null
                            ? DateFormat('dd/MM/yyyy HH:mm').format(record.checkOut!)
                            : 'In Progress',
                      ),
                      _buildTableCell(record.formattedDuration),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),
            // Total
            pw.Container(
              alignment: pw.Alignment.centerRight,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                border: pw.Border.all(color: PdfColors.blue200, width: 2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(
                'Total Work Hours: ${_totalWorkHours.inHours} hrs ${_totalWorkHours.inMinutes % 60} mins',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
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

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '$hours hrs $minutes mins';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_processedRecords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'Print Report',
              onPressed: _printReport,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Report Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Guard Selection
                      Expanded(
                        flex: 2,
                        child: Consumer<ApiService>(
                          builder: (context, apiService, _) {
                            final guards = apiService.users;
                            return DropdownButtonFormField<AppUser>(
                              value: _selectedGuard,
                              decoration: InputDecoration(
                                labelText: 'Select Guard',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.blue.shade50,
                              ),
                              items: guards.map((guard) {
                                return DropdownMenuItem<AppUser>(
                                  value: guard,
                                  child: Text(guard.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGuard = value;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // From Date
                      Expanded(
                        child: InkWell(
                          onTap: _selectFromDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'From Date',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_fromDate),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // To Date
                      Expanded(
                        child: InkWell(
                          onTap: _selectToDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'To Date',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_toDate),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Generate Button
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _loadAttendanceReport,
                        icon: const Icon(Icons.search),
                        label: const Text('Generate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Report Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Error: $_error',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        )
                      : _processedRecords.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assignment_outlined,
                                      size: 80, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No attendance records found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Select a guard and date range, then click Generate',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _buildReportContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Report Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Attendance Report',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoChip(
                      icon: Icons.person,
                      label: 'Guard',
                      value: _selectedGuard?.name ?? '',
                    ),
                    const SizedBox(width: 16),
                    _buildInfoChip(
                      icon: Icons.date_range,
                      label: 'Period',
                      value:
                          '${DateFormat('dd/MM/yyyy').format(_fromDate)} - ${DateFormat('dd/MM/yyyy').format(_toDate)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Data Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.blue.shade700),
                dataRowMinHeight: 60,
                columns: const [
                  DataColumn(
                    label: Text(
                      'S.No.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Check In Date/Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Check Out Date/Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Hours Worked',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                rows: _processedRecords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(record.checkIn),
                      )),
                      DataCell(Text(
                        record.checkOut != null
                            ? DateFormat('dd/MM/yyyy HH:mm')
                                .format(record.checkOut!)
                            : 'In Progress',
                      )),
                      DataCell(Text(record.formattedDuration)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Total Work Hours
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade900],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Work Hours:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatDuration(_totalWorkHours),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Print Button
          ElevatedButton.icon(
            onPressed: _printReport,
            icon: const Icon(Icons.print, size: 28),
            label: const Text(
              'Print Report',
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
