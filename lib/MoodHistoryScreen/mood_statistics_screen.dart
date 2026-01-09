import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Login-Register/database_helper.dart';

class MoodStatsScreen extends StatefulWidget {
  final int
  userId; // Bu ekrana hangi kullanıcının istatistiklerini göstereceğimizi bilmek için

  const MoodStatsScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _MoodStatsScreenState createState() => _MoodStatsScreenState();
}

class _MoodStatsScreenState extends State<MoodStatsScreen> {
  final dbHelper = DatabaseHelper();
  Map<String, int> moodCounts = {};
  int totalMoods = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMoodStats();
  }


  Future<void> loadMoodStats() async {
    // Sadece bu kullanıcıya ait ruh hallerini getir
    final userMoods = await dbHelper.getMoodsForUser(widget.userId);
    final Map<String, int> counts = {};

    for (var mood in userMoods) {
      final moodName = mood['mood']?.toString() ?? 'Bilinmiyor';
      counts[moodName] = (counts[moodName] ?? 0) + 1;
    }

    if (mounted) {
      setState(() {
        moodCounts = counts;
        totalMoods = userMoods.length;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ruh Hali İstatistikleri",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : totalMoods == 0
          ? Center(
              child: Text(
                "İstatistik gösterecek veri bulunamadı. 🧐",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            )
          : buildStatsBody(),
    );
  }

  // İstatistiklerin gösterildiği ana gövdeyi oluşturur.
  Widget buildStatsBody() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          "Ruh Hali Dağılımı",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: PieChart(
              PieChartData(
                sections: _generatePieChartSections(),
                sectionsSpace: 3,
                centerSpaceRadius: 50,
              ),
            ),
          ),
        ),
        const Divider(height: 32, thickness: 1, indent: 20, endIndent: 20),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: moodCounts.entries.map((entry) {
              return _buildMoodStatCard(entry.key, entry.value);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Pasta grafiği dilimlerini oluşturur.
  List<PieChartSectionData> _generatePieChartSections() {
    return moodCounts.entries.map((entry) {
      final mood = entry.key;
      final count = entry.value;
      final percentage = count / totalMoods;

      return PieChartSectionData(
        value: percentage * 100,
        title: '${(percentage * 100).toStringAsFixed(0)}%',
        color: _getColor(mood),
        radius: 80,
        titleStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  // Her bir ruh hali için istatistik kartı oluşturur.
  Widget _buildMoodStatCard(String mood, int count) {
    final percentage = count / totalMoods;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        leading: Text(_getEmoji(mood), style: const TextStyle(fontSize: 32)),
        title: Text(
          mood,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              color: _getColor(mood),
              backgroundColor: Colors.grey[200],
              minHeight: 6,
            ),
            const SizedBox(height: 6),
            Text(
              "${(percentage * 100).toStringAsFixed(1)}% ($count kayıt)",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // --- Yardımcı Fonksiyonlar ---

  String _getEmoji(String mood) {
    const emojiMap = {
      'Mutlu': '😄',
      'Üzgün': '😔',
      'Öfkeli': '😡',
      'Endişeli': '😨',
      'Yorgun': '😴',
      'Heyecanlı': '🤩',
      'Nötr': '😐',
      'Sevgi Dolu': '🥰',
      'Düşünceli': '🤔',
    };
    return emojiMap[mood] ?? '🙂';
  }

  Color _getColor(String mood) {
    const colorMap = {
      'Mutlu': Colors.green,
      'Üzgün': Colors.blueGrey,
      'Öfkeli': Colors.redAccent,
      'Endişeli': Colors.orange,
      'Yorgun': Colors.deepPurple,
      'Heyecanlı': Colors.amber,
      'Nötr': Colors.grey,
      'Sevgi Dolu': Colors.pinkAccent,
      'Düşünceli': Colors.lightBlue,
    };
    return colorMap[mood] ?? Colors.teal;
  }
}
