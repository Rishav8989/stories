import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileLandingPage extends StatelessWidget {
  const ProfileLandingPage({Key? key}) : super(key: key);

  // Function to fetch user data from the API
  Future<Map<String, dynamic>> fetchUserData() async {
    final url = Uri.parse('http://127.0.0.1:8090/api/collections/users/records');
    final headers = {
      'Authorization':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb2xsZWN0aW9uSWQiOiJfcGJfdXNlcnNfYXV0aF8iLCJleHAiOjE3NDM3OTI2NDksImlkIjoiMGIyNG42MWk0N2ZhZDI0IiwicmVmcmVzaGFibGUiOnRydWUsInR5cGUiOiJhdXRoIn0.UOqBef85lqkuaunLBuCw7b1oLsPuEPqYkKXQ2ZyzVY8',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse the JSON response
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
      appBar: AppBar(
        title: Text('User Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(), // Fetch data when the page loads
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for the data
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if the data fetching fails
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Handle the case where no data is returned
            return Center(child: Text('No user data available.'));
          } else {
            // Extract the user data from the snapshot
            final userData = snapshot.data!['items'] as List<dynamic>;
            final user = userData.isNotEmpty ? userData.first : null;

            if (user == null) {
              return Center(child: Text('No user data found.'));
            }

            // Display the user data
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100, // Fallback in case of missing image
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: user['avatar'] != null && user['avatar'].isNotEmpty
                            ? NetworkImage(user['avatar']) as ImageProvider
                            : AssetImage('assets/images/default_avatar.png'), // Default avatar
                      ),
                    ),
                  ),

                  // User Details Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Details',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 16),

                        // Name
                        ListTile(
                          leading: Icon(Icons.person, size: 32),
                          title: Text(user['name'] ?? 'Unknown'),
                          subtitle: Text('Name'),
                        ),

                        // Email
                        ListTile(
                          leading: Icon(Icons.email, size: 32),
                          title: Text(user['email'] ?? 'Unknown'),
                          subtitle: Text('Email'),
                        ),

                        // Verified Status
                        ListTile(
                          leading: Icon(
                            user['verified'] == true ? Icons.check_circle : Icons.cancel,
                            size: 32,
                            color: user['verified'] == true ? Colors.green : Colors.red,
                          ),
                          title: Text(user['verified'] == true ? 'Verified' : 'Not Verified'),
                          subtitle: Text('Account Status'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}