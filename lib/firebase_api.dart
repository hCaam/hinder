import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseApi {
  static const String baseUrl = 'https://hinder-c4a8c-default-rtdb.asia-southeast1.firebasedatabase.app/items';
  static const String authBaseUrl = 'https://identitytoolkit.googleapis.com/v1/accounts';
  static const String apiKey = 'YOUR_FIREBASE_WEB_API_KEY'; // <-- Replace with your Firebase Web API Key

  // Read all items
  static Future<List<Map<String, dynamic>>> fetchItems() async {
    final response = await http.get(Uri.parse('$baseUrl.json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        final item = Map<String, dynamic>.from(e.value);
        item['id'] = e.key;
        return item;
      }).toList();
    }
    throw Exception('Failed to load items');
  }

  // Write (add) an item
  static Future<void> addItem(String name, String description) async {
    final item = {
      'name': name,
      'description': description,
    };
    final response = await http.post(
      Uri.parse('$baseUrl.json'),
      body: json.encode(item),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add item');
    }
  }

  static Future<Map<String, dynamic>> createUser(String email, String password) async {
    final url = '$authBaseUrl:signUp?key=$apiKey';
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error']['message'] ?? 'Failed to create user');
    }
  }
}