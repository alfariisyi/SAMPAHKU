import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:papb/pages/history.dart';
import 'package:papb/pages/informasi.dart';
import 'package:papb/pages/profil.dart';
import 'package:papb/pages/pusatbantuan.dart';
import 'package:papb/pages/transaksi.dart';
import 'package:papb/pages/tukar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _imageCount = 4;

  String? _fullName = '';
  int _points = 0;

  @override
  void initState() {
    super.initState();
    _getUserData();
    Future.delayed(Duration(seconds: 3), _autoScroll);
  }

 
  void _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _fullName = userDoc['fullname'];
            _points = userDoc['poin'];
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  void _autoScroll() {
    if (_currentPage < _imageCount - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
    Future.delayed(Duration(seconds: 3), _autoScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            SizedBox(
              height: 250.0,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _imageCount,
                itemBuilder: (context, index) {
                  return Image.asset(
                    'images/images_$index.jpg', 
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

           
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Color(0xFF689F99),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    Text(
                      _fullName ?? 'Nama Pengguna',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Poin : $_points',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w100,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
                children: [
                  _buildMenuIcon(
                      Icons.recycling, 'Tukar Sampah', _navigateToRecycle),
                  _buildMenuIcon(Icons.person, 'Profil', _navigateToProfile),
                  _buildMenuIcon(
                      Icons.help, 'Pusat Bantuan', _navigateToHelpCenter),
                  _buildMenuIcon(Icons.history, 'Riwayat', _navigateToHistory),
                  _buildMenuIcon(
                      Icons.money, 'Tukar Poin', _navigateToExchangePoints),
                  _buildMenuIcon(
                      Icons.info, 'Informasi', _navigateToSettings),
                ],
              ),
            ),

            
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
              child: Text(
                'Informasi',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),


            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center,
                  crossAxisAlignment: CrossAxisAlignment
                      .center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'images/nothing.png', 
                      height: 150.0, 
                      width: 150.0, 
                      fit: BoxFit.cover, 
                    SizedBox(height: 8), 
                    Text(
                      'Informasi tidak ada',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(17.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(icon, size: 30.0, color: Color(0xFF689F99)),
            ),
            SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12.0, color: Color.fromARGB(255, 0, 0, 0)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  void _navigateToRecycle() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SampahInputPage()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _navigateToHelpCenter() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HelpCenterPage()),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPoinPage()),
    );
  }

  void _navigateToExchangePoints() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PoinToUangPage()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InformasiPage()),
    );
  }
}

