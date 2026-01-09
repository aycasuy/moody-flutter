import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Login-Register/login_page.dart';
import '../MoodSelectionScreen/mood_selection_screen.dart';
import '../MoodHistoryScreen/mood_statistics_screen.dart';
import 'package:untitled8/BreathTherapyScreen/breath_therapy_screen.dart';
import 'package:untitled8/MentalTestScreen/mental_health_screen.dart';

class HomeScreen extends StatelessWidget {
  final int userId;
  final String userName;

  const HomeScreen({required this.userId, required this.userName, Key? key})
    : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final shouldLogout =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Çıkış Yap'),
            content: const Text('Uygulamadan çıkmak istediğine emin misin? 🧐'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Evet, Çık 😢',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldLogout) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      Fluttertoast.showToast(
        msg: "Başarıyla çıkış yapıldı 👋",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe0f7fa),
      appBar: AppBar(
        title: Text(
          'Merhaba, $userName! 🎉',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') _logout(context);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f2f1), Color(0xFFb2dfdb)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Hoş geldin $userName! 😄',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Bugün kendin için bir şeyler yap!',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.teal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildFancyButton(
                  icon: Icons.mood,
                  label: 'Ruh Hali Gir 🎭',
                  color: Colors.teal,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MoodWheelScreen(userId: userId),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildFancyButton(
                  icon: Icons.bar_chart,
                  label: 'Ruh Hali İstatistikleri 📊',
                  color: Colors.teal[300]!,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MoodStatsScreen(userId: userId),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildFancyButton(
                  icon: Icons.air,
                  label: 'Nefes Terapisi 🌬️',
                  color: Colors.blue[300]!,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BreathTherapyScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildFancyButton(
                  icon: Icons.psychology,
                  label: 'Psikolojik Test 🧠',
                  color: Colors.deepPurple,
                  iconColor: Colors.pinkAccent,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MentalHealthTestScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFancyButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 70),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: Colors.black26,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

