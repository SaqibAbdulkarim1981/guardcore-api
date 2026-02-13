class ApiConfig {
  // Use HTTP for local development to avoid SSL certificate issues
  // Change to HTTPS + proper domain for production
  // Using computer's IP address: 10.0.0.208 for mobile device access
  static const String baseUrl = 'http://10.0.0.208:5000/api';
  static const int timeoutSeconds = 30;
  
  // Admin credentials for testing
  static const String adminEmail = 'admin@example.com';
  static const String adminPassword = 'admin123';
}
