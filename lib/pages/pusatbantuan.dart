import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Text('<', style: TextStyle(color: Colors.white, fontSize: 24)),
          onPressed: () {
            // Add your back navigation action here
            Navigator.pop(context);
          },
        ),
        title: Text('Pusat Bantuan', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF689F99),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Box with Image and Shadow
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2), // Shadow position
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.network(
                    'images/help.png', // Gambar di sini
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Butuh Bantuan?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Changed to black
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Jika Anda memerlukan bantuan lebih lanjut, kami siap membantu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black, // Changed to black
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Kontak Kami
            Text(
              'Kontak Kami',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Changed to black
              ),
            ),
            SizedBox(height: 20),

            // Kontak Box
            _buildContactBox('WhatsApp', '+62 123 4567 890'),
            _buildContactBox('Email', 'support@sampahku.com'),
            _buildContactBox('Instagram', '@sampahku'),
            _buildContactBox('Twitter', '@sampahku_support'),
            _buildContactBox('Nomor Telepon', '+62 21 234 5678'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactBox(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2), // Shadow position
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Changed to black
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black, // Changed to black
            ),
          ),
        ],
      ),
    );
  }
}
