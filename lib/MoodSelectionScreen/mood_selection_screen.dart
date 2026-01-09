import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../MoodHistoryScreen/mood_history_screen.dart';
import '../Login-Register/database_helper.dart';

class MoodWheelScreen extends StatefulWidget {
  final int userId;
  const MoodWheelScreen({required this.userId, super.key});

  @override
  _MoodWheelScreenState createState() => _MoodWheelScreenState();
}

class _MoodWheelScreenState extends State<MoodWheelScreen> {
  final dbHelper = DatabaseHelper();
  final List<Map<String, String>> moods = [
    {"emoji": "😄", "label": "Mutlu"},
    {"emoji": "😔", "label": "Üzgün"},
    {"emoji": "😡", "label": "Öfkeli"},
    {"emoji": "😨", "label": "Endişeli"},
    {"emoji": "😴", "label": "Yorgun"},
    {"emoji": "🤩", "label": "Heyecanlı"},
    {"emoji": "😐", "label": "Nötr"},
    {"emoji": "🥰", "label": "Sevgi Dolu"},
    {"emoji": "🤔", "label": "Düşünceli"},
  ];

  late FixedExtentScrollController _controller;
  int selectedIndex = 0;
  DateTime selectedDateTime = DateTime.now();
  TextEditingController noteController = TextEditingController();

  Map<String, String> moodQuestions = {
    "Mutlu": "Bugün seni bu kadar mutlu eden neydi? Anlatmak ister misin?",
    "Üzgün": "İçini dökmek istersen buradayım. Seni üzen neydi?",
    "Öfkeli": "Öfkeni ne tetikledi? Biraz bahsetmek rahatlatabilir.",
    "Endişeli": "Endişelerini paylaşmak yükünü hafifletebilir. Neler oluyor?",
    "Yorgun": "Bugün seni en çok ne yordu? Dinlenmeyi hak ettin.",
    "Heyecanlı": "Bu harika! Seni bu kadar heyecanlandıran şeyi merak ettim.",
    "Nötr": "Bugün genel olarak nasıl geçti? Aklından geçenler neler?",
    "Sevgi Dolu": "Ne güzel bir his! Bu sevgiyi neye borçlusun?",
    "Düşünceli": "Derin düşüncelere dalmış gibisin. Aklından neler geçiyor?",
  };

  @override
  void initState() {
    super.initState();
    selectedIndex = (moods.length / 2).floor();
    _controller = FixedExtentScrollController(initialItem: selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDateTime) {
      setState(() {
        selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentMoodLabel = moods[selectedIndex]["label"]!;
    String currentMoodEmoji = moods[selectedIndex]["emoji"]!;
    String question =
        moodQuestions[currentMoodLabel] ??
        "Bugün hakkında bir şeyler yazmak ister misin?";

    String formattedDate = DateFormat(
      'dd MMMM yyyy, HH:mm',
      'tr_TR',
    ).format(selectedDateTime);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Ruh Hali Kaydı",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarih ve Saat Seçim Kartı
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tarih ve Saat",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              "Tarih Değiştir",
                              style: GoogleFonts.poppins(),
                            ),
                            onPressed: () => _selectDate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[300],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(
                              "Saat Değiştir",
                              style: GoogleFonts.poppins(),
                            ),
                            onPressed: () => _selectTime(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[300],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ruh Hali Çarkı
            Text(
              "Bugün Nasıl Hissediyorsun?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListWheelScrollView.useDelegate( //kaydırılabilirl liste
                controller: _controller,
                itemExtent: 110,
                diameterRatio: 2.0,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedIndex = index;
                    noteController.clear();
                  });
                },
                perspective: 0.004,
                physics: const FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: moods.length,
                  builder: (context, index) {
                    final mood = moods[index];
                    final isSelected = selectedIndex == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      alignment: Alignment.center,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.teal.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.teal
                              : Colors.grey.shade300,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mood["emoji"]!,
                            style: TextStyle(fontSize: isSelected ? 40 : 32),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood["label"]!,
                            style: GoogleFonts.poppins(
                              fontSize: isSelected ? 18 : 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.teal[800]
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Not Alanı ve Kaydet Butonu Kartı
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Seçilen Ruh Hali: $currentMoodLabel $currentMoodEmoji",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 4,
                      style: GoogleFonts.poppins(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Düşüncelerini buraya yazabilirsin...",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.teal,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.save_alt_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Ruh Halimi Kaydet",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        final mood = moods[selectedIndex]["label"]!;
                        final emoji = moods[selectedIndex]["emoji"]!;
                        final note = noteController.text.trim();
                        final dateTime = selectedDateTime.toIso8601String();

                        final newEntry = {
                          "mood": mood,
                          "emoji": emoji,
                          "note": note,
                          "dateTime": dateTime,
                        };

                        await dbHelper.insertMood(newEntry, widget.userId);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Ruh halin başarıyla kaydedildi!",
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.green[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(10),
                          ),
                        );
                        noteController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              icon: Icon(Icons.history, color: Colors.teal[700]),
              label: Text(
                "Ruh Hali Geçmişimi Görüntüle",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.teal[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MoodHistoryScreen(userId: widget.userId),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
