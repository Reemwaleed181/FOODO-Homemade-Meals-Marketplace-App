import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConnectionTest extends StatefulWidget {
  const ConnectionTest({super.key});

  @override
  State<ConnectionTest> createState() => _ConnectionTestState();
}

class _ConnectionTestState extends State<ConnectionTest> {
  bool _isTesting = false;
  String _result = '';
  final List<String> _testResults = [];

  Future<void> _testBackendConnection() async {
    setState(() {
      _isTesting = true;
      _result = 'Testing backend connection...';
      _testResults.clear();
    });

    try {
      // Test 1: Basic connectivity
      _addResult('🔍 Testing basic connectivity...');
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/admin/'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        _addResult('✅ Django admin accessible');
      } else {
        _addResult('⚠️ Django admin returned status: ${response.statusCode}');
      }

      // Test 2: API endpoints
      _addResult('\n🌐 Testing API endpoints...');
      
      // Test signup endpoint
      try {
        final signupResponse = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/auth/signup/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': 'Test User',
            'email': 'test@example.com',
            'password': 'testpass123',
          }),
        ).timeout(const Duration(seconds: 10));
        
        _addResult('✅ Signup endpoint: ${signupResponse.statusCode}');
        if (signupResponse.statusCode != 200) {
          _addResult('   Response: ${signupResponse.body}');
        }
      } catch (e) {
        _addResult('❌ Signup endpoint error: $e');
      }

      // Test login endpoint
      try {
        final loginResponse = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/auth/login/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': 'test@example.com',
            'password': 'testpass123',
          }),
        ).timeout(const Duration(seconds: 10));
        
        _addResult('✅ Login endpoint: ${loginResponse.statusCode}');
        if (loginResponse.statusCode != 200) {
          _addResult('   Response: ${loginResponse.body}');
        }
      } catch (e) {
        _addResult('❌ Login endpoint error: $e');
      }

      // Test 3: CORS headers
      _addResult('\n🔒 Testing CORS configuration...');
      try {
        final corsResponse = await http.get(
          Uri.parse('http://127.0.0.1:8000/api/auth/signup/'),
          headers: {
            'Origin': 'http://localhost:3000',
          },
        ).timeout(const Duration(seconds: 5));
        
        if (corsResponse.headers.containsKey('access-control-allow-origin')) {
          _addResult('✅ CORS headers present');
        } else {
          _addResult('⚠️ CORS headers missing');
        }
      } catch (e) {
        _addResult('❌ CORS test error: $e');
      }

      _addResult('\n🎯 Connection test completed!');
      
    } catch (e) {
      _addResult('❌ Connection test failed: $e');
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
      _result = _testResults.join('\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Connection Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isTesting ? null : _testBackendConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isTesting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text('Testing...'),
                      ],
                    )
                  : const Text('Test Backend Connection'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty ? 'Click "Test Backend Connection" to start testing...' : _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 What this test checks:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Django server accessibility'),
                  Text('• API endpoint functionality'),
                  Text('• CORS configuration'),
                  Text('• Network connectivity'),
                  SizedBox(height: 8),
                  Text(
                    '💡 Make sure Django server is running on port 8000 before testing!',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ConnectionTest(),
    debugShowCheckedModeBanner: false,
  ));
}
