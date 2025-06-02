import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/features/minigames/domain/entities/trivia_question.dart';
import 'package:tesoro_regional/features/minigames/data/datasources/minigames_data_source.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  State<TriviaPage> createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage> with TickerProviderStateMixin {
  final MinigamesDataSource _dataSource = MinigamesDataSourceImpl();

  List<TriviaQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasAnswered = false;
  int? _selectedAnswerIndex;
  bool _showExplanation = false;
  DateTime? _startTime;

  late AnimationController _progressController;
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    );
    _startTime = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading && _questions.isEmpty) {
      _loadQuestions();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final l10n = AppLocalizations.of(context);
      final languageCode = l10n?.locale.languageCode ?? 'es';

      final questionsDto = await _dataSource.getTriviaQuestions(languageCode: languageCode);
      if (mounted) {
        setState(() {
          _questions = questionsDto.map((dto) => dto.toDomain()).toList();
          _questions.shuffle(); // Mezclar preguntas
          _isLoading = false;
        });
        _cardController.forward();
        _updateProgress();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('Error al cargar preguntas: $e');
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateProgress() {
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    _progressController.animateTo(progress);
  }

  void _selectAnswer(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;

      if (_questions[_currentQuestionIndex].isCorrectAnswer(index)) {
        _score++;
      }
    });

    // Mostrar explicación después de un breve delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showExplanation = true;
        });
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _hasAnswered = false;
        _selectedAnswerIndex = null;
        _showExplanation = false;
      });

      _cardController.reset();
      _cardController.forward();
      _updateProgress();
    } else {
      _showResults();
    }
  }

  void _showResults() async {
    // Guardar el puntaje
    final timeTaken = Duration(seconds: DateTime.now().difference(_startTime ?? DateTime.now()).inSeconds);
    await _dataSource.saveGameScore('trivia', _score, _questions.length, timeTaken);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ResultsDialog(
          score: _score,
          totalQuestions: _questions.length,
          onRestart: _restartTrivia,
          onExit: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  void _restartTrivia() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _hasAnswered = false;
      _selectedAnswerIndex = null;
      _showExplanation = false;
      _questions.shuffle();
    });

    _progressController.reset();
    _cardController.reset();
    _cardController.forward();
    _updateProgress();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n?.triviaGame ?? 'Trivia Cultural'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n?.loadingQuestions ?? 'Cargando preguntas...'),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n?.triviaGame ?? 'Trivia Cultural'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(l10n?.noQuestionsLoaded ?? 'No se pudieron cargar las preguntas'),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.triviaGame ?? 'Trivia Cultural'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressController.value,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                );
              },
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Question counter and score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n?.question ?? 'Pregunta'} ${_currentQuestionIndex + 1} ${l10n?.ofText ?? 'de'} ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${l10n?.points ?? 'Puntos'}: $_score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Question card
              Expanded(
                child: AnimatedBuilder(
                  animation: _cardAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _cardAnimation.value,
                      child: Opacity(
                        opacity: _cardAnimation.value,
                        child: _QuestionCard(
                          question: currentQuestion,
                          selectedAnswerIndex: _selectedAnswerIndex,
                          hasAnswered: _hasAnswered,
                          showExplanation: _showExplanation,
                          onAnswerSelected: _selectAnswer,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Next button
              if (_hasAnswered && _showExplanation)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentQuestionIndex < _questions.length - 1
                            ? (l10n?.nextQuestion ?? 'Siguiente Pregunta')
                            : (l10n?.viewResults ?? 'Ver Resultados'),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final TriviaQuestion question;
  final int? selectedAnswerIndex;
  final bool hasAnswered;
  final bool showExplanation;
  final Function(int) onAnswerSelected;

  const _QuestionCard({
    required this.question,
    required this.selectedAnswerIndex,
    required this.hasAnswered,
    required this.showExplanation,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question.category,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Question
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  return _OptionTile(
                    option: question.options[index],
                    index: index,
                    isSelected: selectedAnswerIndex == index,
                    isCorrect: index == question.correctAnswerIndex,
                    hasAnswered: hasAnswered,
                    onTap: () => onAnswerSelected(index),
                  );
                },
              ),
            ),

            // Explanation
            if (showExplanation) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.explanation ?? 'Explicación',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color? borderColor;
    IconData? icon;

    if (hasAnswered) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
      borderColor = Theme.of(context).primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: hasAnswered ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected || (hasAnswered && isCorrect)
                      ? (isCorrect ? Colors.green : Colors.red)
                      : Colors.grey.withOpacity(0.3),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      color: isSelected || (hasAnswered && isCorrect)
                          ? Colors.white
                          : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  icon,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsDialog extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const _ResultsDialog({
    required this.score,
    required this.totalQuestions,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percentage = (score / totalQuestions) * 100;
    String message;
    IconData icon;
    Color color;

    if (percentage >= 80) {
      message = l10n?.excellentExpert ?? '¡Excelente! Eres un experto en cultura de Ñuble';
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (percentage >= 60) {
      message = l10n?.goodKnowledge ?? '¡Bien hecho! Tienes buenos conocimientos';
      icon = Icons.thumb_up;
      color = Colors.green;
    } else {
      message = l10n?.keepLearning ?? 'Sigue aprendiendo sobre la cultura de Ñuble';
      icon = Icons.school;
      color = Colors.blue;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 16),
          Text(
            l10n?.triviaCompleted ?? '¡Trivia Completada!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${l10n?.score ?? 'Puntuación'}: $score/$totalQuestions',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/');
          },
          child: Text(l10n?.exit ?? 'Salir'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRestart();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n?.playAgain ?? 'Jugar de Nuevo'),
        ),
      ],
    );
  }
}
