import 'dart:io';
import 'dart:convert';

// Simple test script to verify Django backend connection
// Run this with: dart test_django_connection.dart

void main() async {
  print('🧪 Testing Django Backend Connection...\n');
  
  final baseUrl = 'http://127.0.0.1:8000';
  
  // Test 1: Basic connectivity
  print('1️⃣ Testing basic connectivity...');
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('$baseUrl/'));
    final response = await request.close();
    print('✅ Django server is running! Status: ${response.statusCode}');
  } catch (e) {
    print('❌ Cannot connect to Django server: $e');
    print('   Make sure your Django server is running on $baseUrl');
    return;
  }
  
  // Test 2: API endpoints
  print('\n2️⃣ Testing API endpoints...');
  final endpoints = [
    '/api/register/',
    '/api/login/',
    '/api/send-otp/',
    '/api/verify-email/',
    '/api/resend-otp/',
  ];
  
  for (final endpoint in endpoints) {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$baseUrl$endpoint'));
      final response = await request.close();
      print('✅ $endpoint - Status: ${response.statusCode}');
    } catch (e) {
      print('❌ $endpoint - Error: $e');
    }
  }
  
  print('\n🎯 Django Backend Test Complete!');
  print('   If you see errors, make sure your Django server has these endpoints configured.');
}
