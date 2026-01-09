import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class BreathTherapyScreen extends StatefulWidget {
  const BreathTherapyScreen({super.key}); // super.key eklendi

  @override
  _BreathTherapyScreenState createState() => _BreathTherapyScreenState();
}

// Animasyonlar için
class _BreathTherapyScreenState extends State<BreathTherapyScreen>
    with TickerProviderStateMixin {
  String _instruction = "Başlamak için dokunun";
  String _countdown = "";
  bool _isRunning = false;
  int _cycleCount = 0; // 0: inhale, 1: hold, 2: exhale
  Timer? _instructionTimer; // Talimatlar ve geri sayım için timer
  Timer? _animationStepTimer; // Animasyon adımları için timer

  // Nefes animasyonu için
  late AnimationController _animationController;
  late Animation<double> _circleAnimation;

  final Map<String, List<int>> _patterns = {
    '4-7-8 Tekniği': [4, 7, 8], // Nefes Al, Tut, Ver (saniye)
    'Kutu Nefesi ': [4, 4, 4, 4], // Al, Tut, Ver, Tut
    'Rahatlatıcı Nefes': [5, 0, 5], // Al, (Tutma Yok), Ver
    'Enerji Verici Nefes': [3, 0, 3, 3], // Al, Ver, Tut (kısa)
  };
  String _selectedPatternKey = '4-7-8 Tekniği';

  // Renkler
  final Color _primaryColor = Colors.teal;
  final Color _accentColor = Colors.cyan;
  final Color _backgroundColor = Colors.teal.shade50;
  final Color _textColor = Colors.teal.shade900;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 4,
      ), // Varsayılan süre, dinamik olarak değişecek
    );

    _circleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Başlangıçta seçili desene göre talimatı ayarla
    _updateInstructionForPattern();
  }

  void _updateInstructionForPattern() {
    if (!_isRunning) {
      final pattern = _patterns[_selectedPatternKey]!;
      String patternDesc = "";
      if (pattern.length == 3) {
        patternDesc =
            "${pattern[0]} saniye Al - ${pattern[1]} saniye Tut - ${pattern[2]} saniye Ver";
        if (pattern[1] == 0) {
          patternDesc = "${pattern[0]} saniye Al - ${pattern[2]} saniye Ver";
        }
      } else if (pattern.length == 4) {
        patternDesc =
            "${pattern[0]}saniye Al - ${pattern[1]} saniye Tut - ${pattern[2]} saniye Ver - ${pattern[3]} saniye Tut";
      }
      setState(() {
        _instruction = patternDesc;
        _countdown = ""; // Geri sayımı temizle
      });
    }
  }

  void _startStopTherapy() {
    if (_isRunning) {
      _instructionTimer?.cancel();
      _animationStepTimer?.cancel();
      _animationController.stop();
      _animationController.reset();
      setState(() {
        _isRunning = false;
        _updateInstructionForPattern(); // Durdurulduğunda desen açıklamasını göster
      });
    } else {
      setState(() {
        _isRunning = true;
        _cycleCount = 0; // Döngüyü sıfırla
      });
      _nextStep();
    }
  }

  void _nextStep() {
    if (!_isRunning) return;

    final pattern = _patterns[_selectedPatternKey]!;
    int currentStepDuration;
    String currentInstruction;

    // 3 aşamalı desenler (Al, Tut, Ver)
    if (pattern.length == 3) {
      if (_cycleCount == 0) {
        // Nefes Al
        currentInstruction = "Nefes Alın";
        currentStepDuration = pattern[0];
        _animateCircle(true, currentStepDuration);
      } else if (_cycleCount == 1) {
        // Tut (eğer varsa)
        if (pattern[1] > 0) {
          currentInstruction = "Nefes Tutun";
          currentStepDuration = pattern[1];
          _animateCircle(null, currentStepDuration); // null = sabit tut
        } else {
          // Tutma yoksa doğrudan nefes ver adımına geç
          _cycleCount++; // Bir sonraki adıma geçmek için _cycleCount'u artır
          _nextStep();
          return;
        }
      } else {
        // Nefes Ver (_cycleCount == 2)
        currentInstruction = "Nefes Verin";
        currentStepDuration = pattern[2];
        _animateCircle(false, currentStepDuration);
        _cycleCount =
            -1; // Döngüyü sıfırlamak için bir sonraki artışta 0 olacak
      }
    }
    // 4 aşamalı desenler (Al, Tut, Ver, Tut)
    else if (pattern.length == 4) {
      if (_cycleCount == 0) {
        // Nefes Al
        currentInstruction = "Nefes Alın";
        currentStepDuration = pattern[0];
        _animateCircle(true, currentStepDuration);
      } else if (_cycleCount == 1) {
        // İlk Tut
        currentInstruction = "Nefes Tutun";
        currentStepDuration = pattern[1];
        _animateCircle(null, currentStepDuration);
      } else if (_cycleCount == 2) {
        // Nefes Ver
        currentInstruction = "Nefes Verin";
        currentStepDuration = pattern[2];
        _animateCircle(false, currentStepDuration);
      } else {
        // İkinci Tut (_cycleCount == 3)
        currentInstruction = "Nefes Tutun";
        currentStepDuration = pattern[3];
        _animateCircle(null, currentStepDuration);
        _cycleCount = -1; // Döngüyü sıfırlamak için
      }
    } else {
      _startStopTherapy(); // Güvenlik için durdur
      return;
    }

    _showInstructionAndCountdown(currentInstruction, currentStepDuration);

    _animationStepTimer?.cancel();
    _animationStepTimer = Timer(Duration(seconds: currentStepDuration), () {
      if (_isRunning) {
        _cycleCount++;
        _nextStep();
      }
    });
  }

  void _animateCircle(bool? expand, int durationSeconds) {
    if (durationSeconds <= 0) return; // Süre 0 ise animasyon yapma

    _animationController.duration = Duration(seconds: durationSeconds);
    if (expand == true) {
      // Nefes Al
      _animationController.forward(from: 0.0);
    } else if (expand == false) {
      // Nefes Ver
      _animationController.reverse(from: 1.0);
    } else {}
  }

  void _showInstructionAndCountdown(String text, int seconds) {
    setState(() {
      _instruction = text;
      _countdown = seconds.toString();
    });

    int remaining = seconds;
    _instructionTimer?.cancel();
    _instructionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      setState(() {
        remaining--;
        _countdown = remaining > 0
            ? remaining.toString()
            : ""; // 0 olunca boş göster
        if (remaining <= 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _instructionTimer?.cancel();
    _animationStepTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildPatternSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPatternKey,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _primaryColor),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: _patterns.keys.map((String key) {
            final pattern = _patterns[key]!;
            String description = "";
            if (pattern.length == 3) {
              description =
                  "(${pattern[0]}-${pattern[1] == 0 ? '' : pattern[1].toString() + '-'}${pattern[2]})";
              if (pattern[1] == 0)
                description = "(${pattern[0]}-${pattern[2]})";
            } else if (pattern.length == 4) {
              description =
                  "(${pattern[0]}-${pattern[1]}-${pattern[2]}-${pattern[3]})";
            }

            return DropdownMenuItem<String>(
              value: key,
              child: Text(
                "$key $description",
                style: GoogleFonts.poppins(
                  color: _textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: _isRunning
              ? null // Terapi çalışıyorsa değiştirmeyi engelle
              : (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPatternKey = value;
                      _updateInstructionForPattern();
                    });
                  }
                },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          "Nefes Terapisi",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround, // Elemanları dikeyde yay
            children: [
              _buildPatternSelector(),

              // Nefes Animasyon Alanı
              AnimatedBuilder(
                animation: _circleAnimation,
                builder: (context, child) {
                  return Container(
                    width:
                        MediaQuery.of(context).size.width *
                        0.6 *
                        _circleAnimation.value,
                    height:
                        MediaQuery.of(context).size.width *
                        0.6 *
                        _circleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accentColor.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withOpacity(0.3),
                          blurRadius: 20 * _circleAnimation.value,
                          spreadRadius: 5 * _circleAnimation.value,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Talimat ve Geri Sayım
              Column(
                children: [
                  Text(
                    _instruction,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_countdown.isNotEmpty && _isRunning)
                    Text(
                      _countdown,
                      style: GoogleFonts.poppins(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                ],
              ),

              // Başlat/Durdur Butonu
              ElevatedButton.icon(
                icon: Icon(
                  _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 28,
                  color: Colors.white,
                ),
                label: Text(
                  _isRunning ? "Durdur" : "Başlat",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: _startStopTherapy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning
                      ? Colors.redAccent.shade200
                      : _primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

