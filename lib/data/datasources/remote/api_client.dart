import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/error/exceptions.dart';
import '../../models/post_model.dart';

class ApiClient {
  final http.Client client;
  final String baseUrl = 'https://jsonplaceholder.typicode.com';
  
  ApiClient({required this.client});
  
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => PostModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(message: 'Failed to load posts');
      }
    } on SocketException {
      throw ConnectionException(message: 'No internet connection');
    } on http.ClientException {
      throw ConnectionException(message: 'Failed to connect to server');
    } catch (e) {
      if (e is UnauthorizedException || e is ConnectionException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
  
  Future<PostModel> getPostById(int id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/posts/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return PostModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw ServerException(message: 'Post not found');
      } else {
        throw ServerException(message: 'Failed to load post');
      }
    } on SocketException {
      throw ConnectionException(message: 'No internet connection');
    } on http.ClientException {
      throw ConnectionException(message: 'Failed to connect to server');
    } catch (e) {
      if (e is UnauthorizedException || e is ConnectionException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
  
  Future<PostModel> createPost(PostModel post) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 201) {
        return PostModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(message: 'Failed to create post');
      }
    } on SocketException {
      throw ConnectionException(message: 'No internet connection');
    } on http.ClientException {
      throw ConnectionException(message: 'Failed to connect to server');
    } catch (e) {
      if (e is UnauthorizedException || e is ConnectionException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
  
  Future<PostModel> updatePost(PostModel post) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/posts/${post.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return PostModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw ServerException(message: 'Post not found');
      } else {
        throw ServerException(message: 'Failed to update post');
      }
    } on SocketException {
      throw ConnectionException(message: 'No internet connection');
    } on http.ClientException {
      throw ConnectionException(message: 'Failed to connect to server');
    } catch (e) {
      if (e is UnauthorizedException || e is ConnectionException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
  
  Future<bool> deletePost(int id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/posts/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw ServerException(message: 'Post not found');
      } else {
        throw ServerException(message: 'Failed to delete post');
      }
    } on SocketException {
      throw ConnectionException(message: 'No internet connection');
    } on http.ClientException {
      throw ConnectionException(message: 'Failed to connect to server');
    } catch (e) {
      if (e is UnauthorizedException || e is ConnectionException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
}
