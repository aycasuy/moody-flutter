import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../Login-Register/database_helper.dart';

class MoodHistoryScreen extends StatefulWidget {
  final int userId; //id alınır

  const MoodHistoryScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _MoodHistoryScreenState createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> moodEntries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('tr_TR', null).then((_) {
      fetchMoods();
    });
  }


  Future<void> fetchMoods() async {
    // Sadece bu kullanıcıya ait ruh hallerini getir
    final data = await dbHelper.getMoodsForUser(widget.userId);


    if (mounted) {
      setState(() {
        moodEntries = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ruh Hali Geçmişim",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildHistoryList(),
    );
  }

  Widget buildHistoryList() {
    if (moodEntries.isEmpty) { // boş veri kontrol kullanıcının boş veya donmuş bir ekranla karşılaşmasını engeller.
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Henüz bir ruh hali kaydın yok.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              "İlk kaydını ekleyerek yolculuğuna başla!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: moodEntries.length,
      itemBuilder: (context, index) {
        final entry = moodEntries[index];
        final String note = entry["note"] ?? "";

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Text(
              entry["emoji"] ?? "🙂",
              style: const TextStyle(fontSize: 36),
            ),
            title: Text(
              entry["mood"] ?? "Bilinmiyor",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                // Sadece not varsa göster
                if (note.trim().isNotEmpty)
                  Text(
                    note,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                if (note.trim().isNotEmpty) const SizedBox(height: 8),
                Text(
                  _formatDateTime(entry["dateTime"]),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  String _formatDateTime(String? rawDateTime) {
    if (rawDateTime == null) return "Tarih bilgisi yok";
    try {
      final dt = DateTime.parse(rawDateTime);

      final formatter = DateFormat('d MMMM y, HH:mm', 'tr_TR');
      return formatter.format(dt);
    } catch (e) {
      return "Geçersiz tarih formatı";
    }
  }
}
