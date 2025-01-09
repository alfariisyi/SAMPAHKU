import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HistoryPoinPage extends StatefulWidget {
  @override
  _HistoryPoinPageState createState() => _HistoryPoinPageState();
}

class _HistoryPoinPageState extends State<HistoryPoinPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> historyPoinList = [];

  @override
  void initState() {
    super.initState();
    _fetchHistoryPoin();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Future<void> _fetchHistoryPoin() async {
    try {
    
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          isLoading = false;
        });
        _showError("Pengguna belum login.");
        return;
      }

      print('Fetching history poin for user: ${currentUser.uid}');


      QuerySnapshot historySnapshot = await FirebaseFirestore.instance
          .collection('history_poin')
          .where('userid',
              isEqualTo: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid))
          .get();

      if (historySnapshot.docs.isNotEmpty) {
        setState(() {
          historyPoinList = historySnapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String poin = data['tipe_perubahan'] == 'Tambah'
                ? '+${data['jumlahpoin']}'
                : '-${data['jumlahpoin']}';
            return {
              'deskripsi': data['deskripsi'] ?? '-',
              'jumlahpoin': poin, 
              'tanggal':
                  (data['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError("History poin tidak ditemukan!");
      }
    } catch (e, stackTrace) {
      print('Error fetching history poin: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
      });
      _showError("Terjadi kesalahan saat memuat data. Silakan coba lagi.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("History Poin", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Text('<', style: TextStyle(color: Colors.white, fontSize: 24)),
          onPressed: () {
     
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: ListView.builder(
                itemCount: historyPoinList.length,
                itemBuilder: (context, index) {
                  var historyItem = historyPoinList[index];
                  var formattedDate = DateFormat('dd MMMM yyyy, HH:mm')
                      .format(historyItem['tanggal']);
                  var poin = historyItem['jumlahpoin'];

              
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    elevation: 5, 
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), 
                    ),
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      leading: Icon(
                        poin.startsWith('+') ? Icons.add : Icons.remove,
                        color: poin.startsWith('+') ? Colors.green : Colors.red,
                      ),
                      title: Text(historyItem['deskripsi']),
                      subtitle: Text('Tanggal: $formattedDate'),
                      trailing: Text(
                        '$poin Poin',
                        style: TextStyle(
                          color:
                              poin.startsWith('+') ? Colors.green : Colors.red,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
