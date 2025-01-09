import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:papb/pages/nota.dart';

class SampahInputPage extends StatefulWidget {
  @override
  _SampahInputPageState createState() => _SampahInputPageState();
}

class _SampahInputPageState extends State<SampahInputPage> {
  final _namaSampahController = TextEditingController();
  final _beratController = TextEditingController();
  String _jenisSampah = 'Sampah Organik';

  // Data untuk jenis sampah dan poin
  final Map<String, String> jenisSampahDetails = {
    'Sampah Organik': 'Sampah Organik (5 Poin/kg)',
    'Sampah Anorganik': 'Sampah Anorganik (12 Poin/kg)',
    'Sampah Elektronik': 'Sampah Elektronik (35 Poin/unit)',
    'Sampah Tekstil': 'Sampah Tekstil (10 Poin/kg)',
  };

  final Map<String, String> contohSampah = {
    'Sampah Organik': 'Contoh: Sisa makanan, kulit buah, daun, rumput.',
    'Sampah Anorganik': 'Contoh: Plastik, Kaca, Logam, Kertas, Tetra Pak.',
    'Sampah Elektronik': 'Contoh: Smartphone rusak, laptop, charger.',
    'Sampah Tekstil': 'Contoh: Pakaian bekas, kain bekas, seprai.',
  };

  final Map<String, int> poinPerJenisSampah = {
    'Sampah Organik': 5,
    'Sampah Anorganik': 12,
    'Sampah Elektronik': 35,
    'Sampah Tekstil': 10,
  };

  // Function to generate custom document ID
  String generateDocumentId() {
    final random = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    return "SMPH$random";
  }

  // Function to handle the form submission
  Future<void> submitForm() async {
    String namaSampah = _namaSampahController.text;
    String beratSampah = _beratController.text;

    if (namaSampah.isEmpty || beratSampah.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap lengkapi semua inputan!')),
      );
      return;
    }

    double berat = double.tryParse(beratSampah) ?? 0;
    int poin = (berat * poinPerJenisSampah[_jenisSampah]!).round();

    // Get current user ID
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User belum login!')),
      );
      return;
    }

    String userId = user.uid;

    try {
      // Custom document ID
      String documentId = generateDocumentId();

      // Add data to Firestore collection 'transaksi'
      await FirebaseFirestore.instance.collection('transaksi').doc(documentId).set({
        'nama_sampah': namaSampah,
        'berat': berat,
        'jenis_sampah': _jenisSampah,
        'nilaipoin': poin,
        'user_id': FirebaseFirestore.instance.collection('users').doc(userId), // Reference to 'users'
        'tanggal': FieldValue.serverTimestamp(), // Adding timestamp
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil disubmit!')),
      );

      // Clear the input fields after submission
      _namaSampahController.clear();
      _beratController.clear();

      // Navigate to the NotaTransaksiPage with the generated documentId
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotaTransaksiPage(transaksiId: documentId)),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
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
            // Add your back navigation action here
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF689F99),
        title: Text(
          "Form Input Sampah",
          style: TextStyle(color: Colors.white),
          
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Kotak untuk form input
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
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
                  children: [
                    Image.network(
                      'images/input.png', // Replace with actual image path
                      height: 400,
                      width: 400,
                    ),
                    // Input Nama Sampah
                    TextField(
                      controller: _namaSampahController,
                      decoration: InputDecoration(
                        labelText: "Nama Sampah",
                        labelStyle: TextStyle(color: Color(0xFF689F99)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF689F99))),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF689F99), width: 2.0),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 20),

                    // Input Berat Sampah (hanya angka dan koma)
                    TextField(
                      controller: _beratController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Berat Sampah (kg)",
                        labelStyle: TextStyle(color: Color(0xFF689F99)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF689F99)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF689F99)),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      ],
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 20),

                    // Dropdown Jenis Sampah
                    DropdownButtonFormField<String>(
                      value: _jenisSampah,
                      onChanged: (newValue) {
                        setState(() {
                          _jenisSampah = newValue!;
                        });
                      },
                      items: jenisSampahDetails.keys.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: "Pilih Jenis Sampah",
                        labelStyle: TextStyle(color: Color(0xFF689F99)),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF689F99)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF689F99)),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      dropdownColor: Colors.white,
                    ),

                    SizedBox(height: 10),

                    // Menampilkan Poin dan Contoh Sampah berdasarkan pilihan
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          jenisSampahDetails[_jenisSampah]!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          contohSampah[_jenisSampah]!,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Tombol Submit
                    ElevatedButton(
                      onPressed: submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF689F99),
                        minimumSize: Size(200, 50),
                      ),
                      child: Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
