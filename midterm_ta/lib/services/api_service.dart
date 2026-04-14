import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // Get posts (simulating external resources)
  Future<List<dynamic>> getPosts() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/posts?_limit=5'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get a single post
  Future<dynamic> getPost(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/posts/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load post: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get comments for a post
  Future<List<dynamic>> getComments(int postId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/posts/$postId/comments?_limit=5'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get users (simulating team members)
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/users'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Generic GET request with error handling
  Future<T> getWithErrorHandling<T>(
    String endpoint, {
    required T Function(dynamic) parser,
  }) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl$endpoint'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return parser(jsonDecode(response.body));
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
