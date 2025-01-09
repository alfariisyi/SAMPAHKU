import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:papb/pages/home.dart';

class NotaTransaksiPage extends StatefulWidget {
  final String transaksiId;

  NotaTransaksiPage({required this.transaksiId});

  @override
  _NotaTransaksiPageState createState() => _NotaTransaksiPageState();
}

class _NotaTransaksiPageState extends State<NotaTransaksiPage> {
  bool isProcessed = true;
  bool isLoading = true;

  String? nomorTransaksi;
  int? jumlahPoin;
  DateTime? tanggalTransaksi;
  String? deskripsi;
  String? jenisSampah;
  double? beratSampah;

  @override
  void initState() {
    super.initState();
    print('Initializing with transaksiId: ${widget.transaksiId}');
    if (widget.transaksiId.isNotEmpty) {
      _fetchTransactionDetails();
    } else {
      setState(() {
        isLoading = false;
      });
      _showError("Transaksi ID tidak valid!");
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Future<void> _fetchTransactionDetails() async {
    try {
      print('Fetching transaction details for ID: ${widget.transaksiId}');
      
      DocumentSnapshot transactionDoc = await FirebaseFirestore.instance
          .collection('transaksi')
          .doc(widget.transaksiId)
          .get();

      print('Document exists: ${transactionDoc.exists}');
      if (transactionDoc.exists) {
        final data = transactionDoc.data() as Map<String, dynamic>;
        print('Retrieved data: $data');

        final nilaipoin = data['nilaipoin'];
        final tanggal = data['tanggal'];
        final jenisSampahValue = data['jenis_sampah'];
        final beratSampahValue = data['berat'];

        print('Extracted values - nilaipoin: $nilaipoin, tanggal: $tanggal, jenis_sampah: $jenisSampahValue, berat_sampah: $beratSampahValue');

        setState(() {
          nomorTransaksi = transactionDoc.id;
          jumlahPoin = nilaipoin is int ? nilaipoin : 0;
          tanggalTransaksi = tanggal is Timestamp ? tanggal.toDate() : DateTime.now();
          deskripsi = "Daur Ulang Sampah";
          jenisSampah = jenisSampahValue?.toString() ?? 'Tidak ada';
          beratSampah = beratSampahValue is num ? beratSampahValue.toDouble() : 0.0;
          isLoading = false;
        });
      } else {
        print('Transaction document not found');
        setState(() {
          isLoading = false;
        });
        _showError("Transaksi tidak ditemukan!");
      }
    } catch (e, stackTrace) {
      print('Error fetching transaction details: $e');
      print('Stack trace: $stackTrace');
      
      setState(() {
        isLoading = false;
        nomorTransaksi = widget.transaksiId;
        jumlahPoin = 0;
        tanggalTransaksi = DateTime.now();
        deskripsi = "Daur Ulang Sampah";
        jenisSampah = "Tidak ada";
        beratSampah = 0.0;
      });
      _showError("Terjadi kesalahan saat memuat data. Silakan coba lagi.");
    }
  }

  Future<void> _addToHistoryPoin() async {
    try {
      print('Adding to history poin');
      DocumentSnapshot transactionDoc = await FirebaseFirestore.instance
          .collection('transaksi')
          .doc(widget.transaksiId)
          .get();

      final data = transactionDoc.data() as Map<String, dynamic>;
      print('Transaction data for history: $data'); // Debug print

      // Accessing the correct field name 'user_id'
      final userRef = data['user_id'] as DocumentReference?;
      if (userRef == null) {
        throw Exception('User reference tidak ditemukan');
      }

      print('User reference found: ${userRef.path}'); // Debug print

      // Retrieve the user's current points
      DocumentSnapshot userDoc = await userRef.get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final currentPoints = userData['poin'] as int? ?? 0;

      // Calculate the new points total
      final newPoints = (currentPoints + (jumlahPoin ?? 0));

      // Generate a unique history ID (HST001xxx format)
      final historyId = 'HST${DateTime.now().millisecondsSinceEpoch % 1000}'.padLeft(6, '0');

      // Create a new document in 'history_poin' collection
      await FirebaseFirestore.instance.collection('history_poin').doc(historyId).set({
        'deskripsi': deskripsi ?? "Daur Ulang Sampah",
        'jumlahpoin': jumlahPoin ?? 0,
        'tanggal': Timestamp.fromDate(DateTime.now()),
        'tipe_perubahan': "Tambah",
        'userid': userRef, // Using the correct DocumentReference
      });
      
      print('Successfully added to history_poin');

      // Update user's poin in the 'users' collection
      await userRef.update({
        'poin': newPoints,
      });

      print('User points updated successfully');

      // Show success message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Berhasil menambahkan poin! Poin Anda sekarang: $newPoints"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error adding to history poin: $e');
      print('Stack trace: $stackTrace');
      _showError("Gagal menambahkan ke history poin: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Detail Transaksi", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: GestureDetector(
                onTap: isProcessed
                    ? () {
                        setState(() {
                          isProcessed = false;
                        });
                        _addToHistoryPoin();
                      }
                    : null,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isProcessed ? Icons.access_time : Icons.check_circle,
                            color: isProcessed ? Colors.orange : Colors.green,
                            size: 64.0,
                          ),
                          SizedBox(width: 16.0),
                          Flexible(
                            child: Text(
                              isProcessed ? "Transaksi Anda Sedang Diproses" : "Transaksi Berhasil",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Divider(color: Colors.grey),
                      SizedBox(height: 8.0),
                      buildNotaDetail("Nomor Transaksi", nomorTransaksi ?? '-'),
                      buildNotaDetail("Jumlah Poin", "${jumlahPoin ?? 0} Poin"),
                      buildNotaDetail("Tanggal", 
                        tanggalTransaksi != null 
                          ? DateFormat('dd MMMM yyyy, HH:mm').format(tanggalTransaksi!)
                          : '-'
                      ),
                      buildNotaDetail("Deskripsi", deskripsi ?? '-'),
                      buildNotaDetail("Jenis Sampah", jenisSampah ?? '-'),
                      buildNotaDetail("Berat Sampah", "${beratSampah?.toStringAsFixed(1) ?? '0.0'} kg"),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            child: Text(
              "Kembali ke Menu Utama",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNotaDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black54,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
