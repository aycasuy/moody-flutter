import 'package:flutter/material.dart';

class MentalHealthTestScreen extends StatefulWidget {
  @override
  _MentalHealthTestScreenState createState() => _MentalHealthTestScreenState();
}

class _MentalHealthTestScreenState extends State<MentalHealthTestScreen> {
  int _currentQuestionIndex = 0;
  List<int?> _answers = List.filled(10, null);
  bool _testCompleted = false;
  String _result = '';

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Son zamanlarda kendimi sık sık üzgün hissediyorum',
      'type': 'depression',
    },
    {
      'question': 'Günlük aktivitelerden eskisi kadar zevk almıyorum',
      'type': 'anhedonia',
    },
    {'question': 'Uyku düzenimde belirgin değişiklikler var', 'type': 'sleep'},
    {'question': 'İştahımda önemli değişiklikler oldu', 'type': 'appetite'},
    {'question': 'Kendimi sürekli yorgun hissediyorum', 'type': 'fatigue'},
    {'question': 'Odaklanmakta güçlük çekiyorum', 'type': 'concentration'},
    {'question': 'Kendimi değersiz hissediyorum', 'type': 'self_worth'},
    {
      'question': 'Ölüm veya intihar düşünceleri aklıma geliyor',
      'type': 'suicidal',
    },
    {'question': 'Kaygı seviyem normalden yüksek', 'type': 'anxiety'},
    {
      'question': 'Günlük işlerimi yapmakta zorlanıyorum',
      'type': 'functionality',
    },
  ];

  void _answerQuestion(int score) {
    setState(() {
      _answers[_currentQuestionIndex] = score;

      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _calculateResult();
        _testCompleted = true;
      }
    });
  }

  void _calculateResult() {
    int totalScore = _answers.fold(0, (sum, item) => sum + (item ?? 0));

    if (totalScore <= 10) {
      _result = 'İyi durumdasınız';
    } else if (totalScore <= 20) {
      _result = 'Hafif düzeyde sıkıntılar yaşıyor olabilirsiniz';
    } else if (totalScore <= 30) {
      _result = 'Orta düzeyde psikolojik sıkıntılar yaşıyorsunuz';
    } else {
      _result = 'Profesyonel destek almayı düşünebilirsiniz';
    }
  }

  void _resetTest() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers = List.filled(10, null);
      _testCompleted = false;
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Psikolojik Durum Testi'),
        actions: [
          if (_testCompleted)
            IconButton(icon: Icon(Icons.refresh), onPressed: _resetTest),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _testCompleted ? _buildResults() : _buildQuestion(),
      ),
    );
  }

  Widget _buildQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
        ),
        SizedBox(height: 20),
        Text(
          'Soru ${_currentQuestionIndex + 1}/${_questions.length}',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 20),
        Text(
          _questions[_currentQuestionIndex]['question'],
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 40),
        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _answers[_currentQuestionIndex] == index
                    ? Colors.teal
                    : Colors.grey[200],
                foregroundColor: _answers[_currentQuestionIndex] == index
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: () => _answerQuestion(index),
              child: Text(
                _getAnswerText(index),
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResults() {
    int totalScore = _answers.fold(0, (sum, item) => sum + (item ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Test Sonucu',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _getResultColor(totalScore),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                'Puan: $totalScore/40',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _result,
                style: TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Text(
          'Önemli Not:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        Text(
          'Bu test profesyonel bir teşhis aracı değildir. '
          'Eğer kendinizi kötü hissediyorsanız, bir ruh sağlığı uzmanına başvurun.',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  String _getAnswerText(int score) {
    switch (score) {
      case 0:
        return 'Hiç katılmıyorum';
      case 1:
        return 'Nadiren';
      case 2:
        return 'Bazen';
      case 3:
        return 'Sıklıkla';
      case 4:
        return 'Sürekli';
      default:
        return '';
    }
  }

  Color _getResultColor(int score) {
    if (score <= 10) return Colors.green;
    if (score <= 20) return Colors.blue;
    if (score <= 30) return Colors.orange;
    return Colors.red;
  }
}
