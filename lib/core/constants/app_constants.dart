class AppConstants {
  // App Info
  static const String appName = 'Smart Learning Hub';
  static const String appVersion = '1.0.0';
  
  // User Roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  
  // Shared Preferences Keys
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserId = 'userId';
  static const String keyUserRole = 'userRole';
  static const String keyUserName = 'userName';
  static const String keyUserEmail = 'userEmail';
  
  // Database
  static const String dbName = 'learning_hub.db';
  static const int dbVersion = 7;
  
  // API Keys - MUST be set via environment variables or secure storage
  // DO NOT hardcode API keys here - use flutter_dotenv or secure storage
  static const String openAIApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  
  // API Endpoints
  static const String chatbotApiUrl = 'https://api.openai.com/v1/chat/completions';
  
  // Pagination
  static const int itemsPerPage = 10;
  
  // Notification Channels
  static const String notificationChannelId = 'learning_hub_channel';
  static const String notificationChannelName = 'Learning Hub Notifications';
  static const String notificationChannelDescription = 'Notifications for study reminders and updates';
  
  // Quiz Settings
  static const int quizTimeLimit = 1800; // 30 minutes in seconds
  static const int passingScore = 60; // 60% to pass
  
  // File Upload Limits
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  
  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection. Please check your network.';
  static const String errorAuth = 'Authentication failed. Please login again.';
  static const String errorPermission = 'Permission denied.';
}
