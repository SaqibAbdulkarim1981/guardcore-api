class ApiConfig {
  // Production API on Render.com (Cloud hosting)
  // For local development, change to: 'http://192.168.56.1:5000/api'
  static const String baseUrl = 'https://guardcore-api.onrender.com/api';
  static const int timeoutSeconds = 30;
  
  // Admin credentials for testing
  static const String adminEmail = 'admin@example.com';
  static const String adminPassword = 'admin123';
}
