class Attendance {
  final int id;
  final int userId;
  final String userName;
  final int locationId;
  final String locationName;
  final String type; // "CheckIn" or "CheckOut"
  final DateTime timestamp;
  final String? qrData;

  Attendance({
    required this.id,
    required this.userId,
    required this.userName,
    required this.locationId,
    required this.locationName,
    required this.type,
    required this.timestamp,
    this.qrData,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? 'Unknown',
      locationId: json['locationId'] ?? 0,
      locationName: json['locationName'] ?? 'Unknown Location',
      type: json['type'] ?? 'CheckIn',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      qrData: json['qrData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'locationId': locationId,
      'locationName': locationName,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'qrData': qrData,
    };
  }
}

class AttendanceRecord {
  final DateTime checkIn;
  final DateTime? checkOut;
  final String locationName;

  AttendanceRecord({
    required this.checkIn,
    this.checkOut,
    required this.locationName,
  });

  Duration get workDuration {
    if (checkOut == null) return Duration.zero;
    return checkOut!.difference(checkIn);
  }

  String get formattedDuration {
    if (checkOut == null) return 'In Progress';
    final hours = workDuration.inHours;
    final minutes = workDuration.inMinutes % 60;
    return '$hours hrs ${minutes} mins';
  }
}
