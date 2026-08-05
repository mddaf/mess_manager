import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../models/settlement.dart';

class ApiService {
  final FirebaseAuth _auth;
  final http.Client _client;

  ApiService({FirebaseAuth? auth, http.Client? client})
      : _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  Future<String?> _getAuthToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// REST Endpoint: POST /api/settle
  Future<Settlement> calculateAndStoreSettlement({
    required String messId,
    required String month, // YYYY-MM
  }) async {
    final token = await _getAuthToken();
    final url = Uri.parse('${AppConstants.apiBaseUrl}/settle');

    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'messId': messId,
        'month': month,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Settlement.fromJson(json);
    } else {
      throw Exception(
          'Failed to calculate settlement: ${response.statusCode} ${response.body}');
    }
  }

  /// REST Endpoint: GET /api/meal-rate/:messId/:month
  Future<double> getLiveMealRate({
    required String messId,
    required String month,
  }) async {
    final token = await _getAuthToken();
    final url = Uri.parse('${AppConstants.apiBaseUrl}/meal-rate/$messId/$month');

    final response = await _client.get(
      url,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return (json['mealRate'] as num).toDouble();
    } else {
      return 0.0;
    }
  }
}
