import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:papb/pages/home.dart';

class PoinToUangPage extends StatefulWidget {
  @override
  _PoinToUangPageState createState() => _PoinToUangPageState();
}

class _PoinToUangPageState extends State<PoinToUangPage> {
  final TextEditingController _poinController = TextEditingController();
  double _uang = 0.0;
  final double _nilaiTukar = 100.0; // Misalnya, 1 poin = 100 Rupiah
  final double _minimalPenarikan = 10000.0; // Minimal penarikan 10.000 Rupiah

  // Fetch user data from Firestore using the logged-in user's uid
  Future<Map<String, dynamic>> _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser; // Get current user

    if (currentUser != null) {
      // Get user data from Firestore based on the current user's uid
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        return {
          'fullname': userDoc['fullname'],
          'poin': userDoc['poin'],
        };
      } else {
        throw Exception('User not found');
      }
    } else {
      throw Exception('No user is logged in');
    }
  }

  // Inside your _tukarPoin function

  void _tukarPoin(String name, int totalPoints) {
    double jumlahUangDiinginkan = double.tryParse(_poinController.text) ?? 0.0;

    // Hitung berapa poin yang dibutuhkan untuk jumlah uang tersebut
    double poinDibutuhkan = jumlahUangDiinginkan / _nilaiTukar;

    if (jumlahUangDiinginkan >= _minimalPenarikan &&
        poinDibutuhkan <= totalPoints) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Konfirmasi Penarikan"),
            content: Text(
              "Anda yakin ingin menarik Rp ${jumlahUangDiinginkan.toStringAsFixed(0)} dengan menukar ${poinDibutuhkan.toStringAsFixed(0)} poin?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close the dialog
                  await _processPenarikan(poinDibutuhkan,
                      jumlahUangDiinginkan); // Process withdrawal
                },
                child: Text("Ya"),
              ),
            ],
          );
        },
      );
    } else {
      // Error handling with pop-up dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String message = (jumlahUangDiinginkan < _minimalPenarikan)
              ? "Minimal penarikan adalah Rp ${_minimalPenarikan.toStringAsFixed(0)}"
              : "Poin Anda tidak cukup. Anda membutuhkan ${poinDibutuhkan.toStringAsFixed(0)} poin untuk penarikan ini.";

          return AlertDialog(
            title: Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Tutup"),
              ),
            ],
          );
        },
      );
    }
  }

// Inside your _processPenarikan function, after successful withdrawal

  Future<void> _processPenarikan(
      double poinTarik, double jumlahPenarikan) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      if (jumlahPenarikan >= _minimalPenarikan) {
        // Deduct points from user (update user data in Firestore)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'poin': FieldValue.increment(-poinTarik.toInt()), // Deduct points
        });

        // Add to history_poin collection
        String docId =
            'HST${DateTime.now().millisecondsSinceEpoch % 1000}'; // Random 3 digits
        await FirebaseFirestore.instance
            .collection('history_poin')
            .doc(docId)
            .set({
          'deskripsi': 'Penarikan Poin',
          'jumlahpoin': poinTarik,
          'tanggal': Timestamp.now(),
          'tipe_perubahan': 'Kurang',
          'userid': FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid),
        });

        // Show success message with pop-up
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Berhasil"),
              content: Text(
                  "Penukaran berhasil! Anda mendapatkan Rp $jumlahPenarikan"),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Color(0xFF689F99)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));// Go back to the previous screen (home)
                  },
                  child: Text("Kembali", style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );
      } else {
        // Show minimum withdrawal error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Error"),
              content: Text("Minimal penarikan adalah Rp 10.000"),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Color(0xFF689F99)),
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text("Tutup", style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Show authentication error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Error"),
            content: Text("User not authenticated"),
            actions: [
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Color(0xFF689F99)),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Tutup", style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF689F99),
        title:
            Text('Tukar Poin ke Uang', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Text('<', style: TextStyle(color: Colors.white, fontSize: 24)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(), // Fetch user data from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator while fetching data
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}')); // Show error if there is an issue
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('User data not available'));
          }

          String _namaPengguna = snapshot.data!['fullname'];
          int _totalPoin = snapshot.data!['poin'];

          double uangDariSemuaPoin = _totalPoin * _nilaiTukar;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Box pertama: Nama pengguna, total poin, dan konversi poin
                Card(
                  elevation: 3,
                  color: Colors.white,
                  margin: EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nama Pengguna: $_namaPengguna',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Poin Anda: $_totalPoin',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Total Konversi Poin ke Uang: Rp ${uangDariSemuaPoin.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),

                // Box kedua: Jumlah penarikan
                Card(
                  color: Colors.white,
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jumlah Penarikan',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Masukkan Jumlah Penarikan:',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _poinController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Minimal Rp 10.000',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF689F99)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF689F99)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF689F99),
                            padding: EdgeInsets.symmetric(
                                horizontal: 50.0, vertical: 20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          onPressed: () =>
                              _tukarPoin(_namaPengguna, _totalPoin),
                          child: Text(
                            'Tarik',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
