import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class AIService {
  static final AIService instance = AIService._internal();
  AIService._internal();

  // OpenAI API Integration
  Future<String> getOpenAIResponse(String message, List<Map<String, String>> conversationHistory) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content': 'You are a helpful AI study assistant for students. Provide clear, educational responses to help students learn effectively. Be encouraging and supportive.'
        },
        ...conversationHistory,
        {'role': 'user', 'content': message}
      ];

      final response = await http.post(
        Uri.parse(AppConstants.chatbotApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.openAIApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        return 'I apologize, but I encountered an error. Please try again. (Error: ${response.statusCode})';
      }
    } catch (e) {
      return 'I apologize, but I\'m having trouble connecting right now. Please check your internet connection and try again.';
    }
  }

  // Gemini API Integration
  Future<String> getGeminiResponse(String message) async {
    try {
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${AppConstants.geminiApiKey}';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'You are a helpful AI study assistant. $message'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'].toString().trim();
      } else {
        return 'I apologize, but I encountered an error. Please try again. (Error: ${response.statusCode})';
      }
    } catch (e) {
      return 'I apologize, but I\'m having trouble connecting right now. Please check your internet connection and try again.';
    }
  }

  // Fallback rule-based responses
  String getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();

    // Greetings
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || 
        lowerMessage.contains('hey') || lowerMessage.contains('hellow')) {
      return 'Hello! 👋 I\'m your AI Study Assistant. I\'m here to help you learn and understand your course materials better. '
             'You can ask me about programming concepts, study tips, or any questions related to your courses. '
             'What would you like to know today?';
    }
    
    // Programming/Coding
    else if (lowerMessage.contains('programming') || lowerMessage.contains('coding') || 
             lowerMessage.contains('program')) {
      return 'Programming is the process of creating instructions for computers to follow. It involves:\n\n'
             '• Writing code in a programming language (like Dart, Python, Java)\n'
             '• Solving problems through logical thinking\n'
             '• Creating applications, websites, or software\n'
             '• Testing and debugging your code\n\n'
             'Programming helps you build anything from mobile apps to websites to games! '
             'Would you like to know about a specific programming language or concept?';
    }
    
    // Flutter
    else if (lowerMessage.contains('flutter')) {
      return 'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications. '
             'It uses the Dart programming language and provides a rich set of pre-built widgets. '
             'Key benefits include:\n\n'
             '• Cross-platform (iOS, Android, Web, Desktop)\n'
             '• Hot reload for fast development\n'
             '• Beautiful, customizable widgets\n'
             '• High performance\n\n'
             'Would you like to know more about specific Flutter concepts?';
    }
    
    // Dart
    else if (lowerMessage.contains('dart')) {
      return 'Dart is a client-optimized programming language for apps on multiple platforms. '
             'It\'s developed by Google and is used by Flutter. Key features include:\n\n'
             '• Strong typing with type inference\n'
             '• Async/await for asynchronous programming\n'
             '• Rich standard library\n'
             '• Null safety\n'
             '• Object-oriented programming\n\n'
             'Dart is easy to learn, especially if you know JavaScript or Java!';
    }
    
    // Database
    else if (lowerMessage.contains('database') || lowerMessage.contains('sqlite')) {
      return 'SQLite is a lightweight, embedded database perfect for mobile apps. '
             'It supports standard SQL operations:\n\n'
             '• CREATE - Create tables and structure\n'
             '• INSERT - Add new data\n'
             '• SELECT - Read/query data\n'
             '• UPDATE - Modify existing data\n'
             '• DELETE - Remove data\n\n'
             'In Flutter, we use the sqflite package to interact with SQLite databases. '
             'It\'s great for storing user data, settings, and offline content!';
    }
    
    // Quiz/Test
    else if (lowerMessage.contains('quiz') || lowerMessage.contains('test') || 
             lowerMessage.contains('exam')) {
      return 'Taking quizzes is a great way to test your knowledge! Here are some tips:\n\n'
             '• Review course material before attempting\n'
             '• Focus on understanding concepts, not memorizing\n'
             '• Read questions carefully\n'
             '• Manage your time wisely\n'
             '• Don\'t rush - think through each answer\n\n'
             'Remember, quizzes help you identify areas where you need more practice. '
             'Would you like tips on any specific topic?';
    }
    
    // Study tips
    else if (lowerMessage.contains('study') || lowerMessage.contains('learn')) {
      return 'Here are some effective study strategies:\n\n'
             '• Break study sessions into 25-30 minute chunks\n'
             '• Practice active recall (test yourself)\n'
             '• Teach concepts to others or explain out loud\n'
             '• Take regular breaks\n'
             '• Use multiple resources (videos, articles, practice)\n'
             '• Review regularly, not just before tests\n\n'
             'Consistent, focused practice is better than long cramming sessions!';
    }
    
    // Help
    else if (lowerMessage.contains('help') || lowerMessage.contains('how')) {
      return 'I\'m here to help you with your studies! You can ask me about:\n\n'
             '• Programming concepts (Flutter, Dart, Python, Java)\n'
             '• Study strategies and tips\n'
             '• Course-related questions\n'
             '• Technical explanations\n'
             '• Database and SQL\n'
             '• Mobile app development\n\n'
             'Just type your question and I\'ll do my best to help! What would you like to learn about?';
    }
    
    // Mobile/App development
    else if (lowerMessage.contains('mobile') || lowerMessage.contains('app')) {
      return 'Mobile app development is an exciting field! Here\'s what you need to know:\n\n'
             '• Choose a framework (Flutter, React Native, Native)\n'
             '• Learn UI/UX design principles\n'
             '• Understand state management\n'
             '• Work with APIs and databases\n'
             '• Test on real devices\n'
             '• Consider performance and battery usage\n\n'
             'Flutter is a great choice for beginners because you can build for both iOS and Android with one codebase!';
    }
    
    // Variables/Data types
    else if (lowerMessage.contains('variable') || lowerMessage.contains('data type')) {
      return 'Variables are containers for storing data in programming. Common data types include:\n\n'
             '• int - Whole numbers (1, 42, -5)\n'
             '• double - Decimal numbers (3.14, -0.5)\n'
             '• String - Text ("Hello", "World")\n'
             '• bool - True or False values\n'
             '• List - Collections of items [1, 2, 3]\n'
             '• Map - Key-value pairs {\'name\': \'John\'}\n\n'
             'In Dart, you declare variables like: int age = 25; or String name = "Alice";';
    }
    
    // Functions
    else if (lowerMessage.contains('function') || lowerMessage.contains('method')) {
      return 'Functions are reusable blocks of code that perform specific tasks. Benefits:\n\n'
             '• Organize code into logical pieces\n'
             '• Avoid repeating code\n'
             '• Make code easier to test and debug\n'
             '• Accept parameters (inputs)\n'
             '• Return values (outputs)\n\n'
             'Example in Dart:\n'
             'int add(int a, int b) {\n'
             '  return a + b;\n'
             '}\n\n'
             'Functions are fundamental to all programming!';
    }
    
    // Thank you
    else if (lowerMessage.contains('thank') || lowerMessage.contains('thanks')) {
      return 'You\'re welcome! 😊 I\'m happy to help you learn. '
             'Feel free to ask me anything else about your courses or programming concepts. '
             'Keep up the great work with your studies!';
    }
    
    // Default response
    else {
      return 'That\'s an interesting question! While I can provide general guidance on educational topics, '
             'I work best when you ask about:\n\n'
             '• Programming languages (Dart, Flutter, Python, Java)\n'
             '• Study techniques and learning strategies\n'
             '• Mobile app development\n'
             '• Databases and SQL\n'
             '• Software concepts\n\n'
             'Could you rephrase your question or ask about one of these topics? I\'m here to help you learn!';
    }
  }

  // Main method to get AI response with fallback
  Future<String> getAIResponse(String message, {List<Map<String, String>>? conversationHistory}) async {
    // Try OpenAI first if API key is configured
    if (AppConstants.openAIApiKey.isNotEmpty && 
        !AppConstants.openAIApiKey.contains('YOUR_')) {
      final response = await getOpenAIResponse(message, conversationHistory ?? []);
      if (!response.contains('Error:') && !response.contains('trouble connecting')) {
        return response;
      }
    }

    // Try Gemini if OpenAI fails and Gemini key is configured
    if (AppConstants.geminiApiKey.isNotEmpty && 
        !AppConstants.geminiApiKey.contains('YOUR_')) {
      final response = await getGeminiResponse(message);
      if (!response.contains('Error:') && !response.contains('trouble connecting')) {
        return response;
      }
    }

    // Fallback to rule-based responses
    return getFallbackResponse(message);
  }
}
