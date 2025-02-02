import 'package:flutter/material.dart';

class InformasiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Text('<', style: TextStyle(color: Colors.white, fontSize: 24)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Informasi', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF689F99),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          crossAxisAlignment: CrossAxisAlignment.center, 
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    'images/nothing.png',
                    height: 150.0, 
                    width: 150.0, 
                    fit: BoxFit.cover, 
                  ),
                  SizedBox(height: 8), 
                  Text(
                    'Informasi tidak ada',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
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
