import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:papb/pages/login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String username;
  late int points;
  late String fullName;
  late String email;
  late String phoneNumber;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Get the current user UID
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch user data from Firestore using the user's UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            points = userDoc['poin'];
            fullName = userDoc['fullname'];
            email = userDoc['email'];
            phoneNumber = userDoc['phonenumber'];
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        // If no user is logged in, handle accordingly
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Text('<', style: TextStyle(color: Colors.white, fontSize: 24)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF689F99),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : hasError
                ? Center(child: Text('Error loading user data'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username and Points Section
                      Card(
                        elevation: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            "Username: $fullName",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Points: $points"),
                          leading: Icon(Icons.account_circle, size: 60),
                        ),
                      ),
                      // Email Section
                      Card(
                        elevation: 5,
                        margin: const EdgeInsets.only(bottom: 15),
                        color: Colors.white,
                        child: ListTile(
                          title: Text("Email"),
                          subtitle: Text(email),
                          leading: Icon(Icons.email, color: Colors.blueAccent),
                        ),
                      ),
                      // Phone Number Section
                      Card(
                        elevation: 5,
                        margin: const EdgeInsets.only(bottom: 15),
                        color: Colors.white,
                        child: ListTile(
                          title: Text("Phone Number"),
                          subtitle: Text(phoneNumber),
                          leading: Icon(Icons.phone, color: Colors.blueAccent),
                        ),
                      ),
                      // Logout Button
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
