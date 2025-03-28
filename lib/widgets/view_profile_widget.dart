import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../utils/user_service.dart';

class ProfileLandingPage extends StatelessWidget {
  const ProfileLandingPage({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> fetchUserData() async {
    final userService = Get.find<UserService>();
    final token = await userService.getAuthToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final url = Uri.parse(
      'http://rishavpocket.duckdns.org/api/collections/users/records',
    );
    final headers = {'Authorization': token};

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No user data available.'));
          }

          final userData = snapshot.data!['items'] as List<dynamic>;
          final user = userData.isNotEmpty ? userData.first : null;

          if (user == null) {
            return Center(child: Text('No user data found.'));
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                      child: Center(
                        child: user['avatar'] != null && user['avatar'].isNotEmpty
                            ? CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(
                                  'http://rishavpocket.duckdns.org/api/files/${user['collectionId']}/${user['id']}/${user['avatar']}',
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.all(16),
                                child: Icon(
                                  Icons.account_circle,
                                  size: 120,
                                  color: Colors.blue,
                                ),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: Icon(Icons.person, color: Colors.blue, size: 32),
                                title: Text(
                                  user['name'] ?? 'Unknown',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Name'),
                              ),
                              ListTile(
                                leading: Icon(Icons.email, color: Colors.blue, size: 32),
                                title: Text(
                                  user['email'] ?? 'Unknown',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Email'),
                              ),
                              ListTile(
                                leading: Icon(Icons.calendar_today, color: Colors.blue, size: 32),
                                title: Text(
                                  DateTime.parse(user['created']).toLocal()
                                      .toString().split('.').first,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Date Joined'),
                              ),
                              ListTile(
                                leading: Icon(
                                  user['verified'] == true ? Icons.check_circle : Icons.cancel,
                                  color: user['verified'] == true ? Colors.green : Colors.red,
                                  size: 32,
                                ),
                                title: Text(
                                  user['verified'] == true ? 'Verified' : 'Not Verified',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Account Status'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}