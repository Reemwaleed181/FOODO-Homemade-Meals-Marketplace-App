import 'dart:io';

import 'dart:convert';

void main() async {
  print('🔍 Testing Django Backend Connection...\n');

  final baseUrl = 'http://127.0.0.1:8000';

  print('Testing connection to: $baseUrl');

  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(baseUrl));
    final response = await request.close();

    print('✅ SUCCESS! Django server is running');
    print('Status Code: ${response.statusCode}');

    // Read response body
    final responseBody = await response.transform(utf8.decoder).join();
    print(
      'Response: ${responseBody.substring(0, responseBody.length > 100 ? 100 : responseBody.length)}...',
    );
  } catch (e) {
    print('❌ FAILED! Cannot connect to Django server');
    print('Error: $e');
    print('\n🔧 Solutions:');
    print('1. Make sure Django server is running');
    print('2. Check if port 8000 is available');
    print('3. Verify Django is running on 127.0.0.1:8000');
  }
}
