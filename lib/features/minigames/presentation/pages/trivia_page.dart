import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/features/minigames/domain/entities/trivia_question.dart';
import 'package:tesoro_regional/core/services/content/trivia_service.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  State<TriviaPage> createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage> with TickerProviderStateMixin {
  final TriviaService _triviaService = TriviaService();

  List<TriviaQuestion> _allQuestions = [];
  List<TriviaQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasAnswered = false;
  int? _selectedAnswerIndex;
  bool _showExplanation = false;
  DateTime? _startTime;
  String? _selectedDifficulty;

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
    if (_isLoading && _allQuestions.isEmpty) {
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

      final questionsDto = await _triviaService.loadTriviaQuestions(languageCode);

      if (mounted) {
        setState(() {
          _allQuestions = questionsDto.map((dto) => dto.toDomain()).toList();
          _isLoading = false;
        });
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

  void _startGameWithSelectedDifficulty(String difficulty) {
    setState(() {
      _questions = _allQuestions
          .where((q) => q.difficulty.toLowerCase() == difficulty.toLowerCase())
          .toList();

      if (_questions.isEmpty) {
        _showErrorMessage('No hay preguntas para la dificultad seleccionada');
        return;
      }

      _questions.shuffle();
      _selectedDifficulty = difficulty;
      _currentQuestionIndex = 0;
      _score = 0;
      _hasAnswered = false;
      _selectedAnswerIndex = null;
      _showExplanation = false;
      _startTime = DateTime.now();
    });
    _cardController.forward();
    _updateProgress();
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

  void _showResults() {
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
      _selectedDifficulty = null;
    });
    _progressController.reset();
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando preguntas...'),
            ],
          ),
        ),
      );
    }

    if (_allQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n?.triviaGame ?? 'Trivia Cultural'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.noQuestionsLoaded ?? 'No se pudieron cargar las preguntas',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadQuestions(),
                child: Text(l10n?.retry ?? 'Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/minigames');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.triviaGame ?? 'Trivia Cultural'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/minigames'),
          ),
          bottom: _selectedDifficulty != null ? PreferredSize(
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
          ) : null,
        ),
        body: _selectedDifficulty == null
            ? _DifficultySelectionScreen(
          allQuestions: _allQuestions,
          onDifficultySelected: _startGameWithSelectedDifficulty,
        )
            : _GameScreen(
          questions: _questions,
          currentQuestionIndex: _currentQuestionIndex,
          score: _score,
          selectedAnswerIndex: _selectedAnswerIndex,
          hasAnswered: _hasAnswered,
          showExplanation: _showExplanation,
          onAnswerSelected: _selectAnswer,
          onNextQuestion: _nextQuestion,
          cardAnimation: _cardAnimation,
        ),
      ),
    );
  }
}

class _DifficultySelectionScreen extends StatelessWidget {
  final List<TriviaQuestion> allQuestions;
  final Function(String) onDifficultySelected;

  const _DifficultySelectionScreen({
    required this.allQuestions,
    required this.onDifficultySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    // Count questions by difficulty
    final easyCount = allQuestions.where((q) => q.difficulty.toLowerCase() == 'fácil' || q.difficulty.toLowerCase() == 'easy').length;
    final mediumCount = allQuestions.where((q) => q.difficulty.toLowerCase() == 'medio' || q.difficulty.toLowerCase() == 'medium').length;
    final hardCount = allQuestions.where((q) => q.difficulty.toLowerCase() == 'difícil' || q.difficulty.toLowerCase() == 'hard').length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isLargeScreen ? 32 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.selectDifficulty ?? 'Selecciona la dificultad',
                style: TextStyle(
                  fontSize: isLargeScreen ? 32 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isLargeScreen ? 16 : 12),
              Text(
                l10n?.selectDifficultyDescription ??
                    'Elige el nivel de dificultad de las preguntas sobre la cultura de Ñuble.',
                style: TextStyle(
                  fontSize: isLargeScreen ? 18 : 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isLargeScreen ? 40 : 32),

              Column(
                children: [
                  _DifficultyOption(
                    difficulty: 'Fácil',
                    name: l10n?.easy ?? 'Fácil',
                    description: l10n?.easyDescription ?? 'Preguntas básicas sobre Ñuble',
                    questionCount: easyCount,
                    color: Colors.green,
                    icon: Icons.sentiment_satisfied,
                    onTap: () => onDifficultySelected('Fácil'),
                    isLargeScreen: isLargeScreen,
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 16),
                  _DifficultyOption(
                    difficulty: 'Medio',
                    name: l10n?.medium ?? 'Medio',
                    description: l10n?.mediumDescription ?? 'Preguntas intermedias sobre Ñuble',
                    questionCount: mediumCount,
                    color: Colors.orange,
                    icon: Icons.sentiment_neutral,
                    onTap: () => onDifficultySelected('Medio'),
                    isLargeScreen: isLargeScreen,
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 16),
                  _DifficultyOption(
                    difficulty: 'Difícil',
                    name: l10n?.hard ?? 'Difícil',
                    description: l10n?.hardDescription ?? 'Preguntas desafiantes sobre Ñuble',
                    questionCount: hardCount,
                    color: Colors.red,
                    icon: Icons.sentiment_very_dissatisfied,
                    onTap: () => onDifficultySelected('Difícil'),
                    isLargeScreen: isLargeScreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  final String difficulty;
  final String name;
  final String description;
  final int questionCount;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLargeScreen;

  const _DifficultyOption({
    required this.difficulty,
    required this.name,
    required this.description,
    required this.questionCount,
    required this.color,
    required this.icon,
    required this.onTap,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
        child: Row(
          children: [
            Container(
              width: isLargeScreen ? 60 : 50,
              height: isLargeScreen ? 60 : 50,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isLargeScreen ? 30 : 24,
              ),
            ),
            SizedBox(width: isLargeScreen ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 22 : 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 8 : 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 8 : 4),
                  Text(
                    '$questionCount preguntas disponibles',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 14 : 12,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: isLargeScreen ? 24 : 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _GameScreen extends StatelessWidget {
  final List<TriviaQuestion> questions;
  final int currentQuestionIndex;
  final int score;
  final int? selectedAnswerIndex;
  final bool hasAnswered;
  final bool showExplanation;
  final Function(int) onAnswerSelected;
  final VoidCallback onNextQuestion;
  final Animation<double> cardAnimation;

  const _GameScreen({
    required this.questions,
    required this.currentQuestionIndex,
    required this.score,
    required this.selectedAnswerIndex,
    required this.hasAnswered,
    required this.showExplanation,
    required this.onAnswerSelected,
    required this.onNextQuestion,
    required this.cardAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentQuestion = questions[currentQuestionIndex];
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = isLargeScreen ? 800.0 : double.infinity;

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
              child: Column(
                children: [
                  // Question counter and score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n?.question ?? 'Pregunta'} ${currentQuestionIndex + 1} ${l10n?.ofText ?? 'de'} ${questions.length}',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 16 : 12,
                          vertical: isLargeScreen ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${l10n?.points ?? 'Puntos'}: $score',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isLargeScreen ? 16 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isLargeScreen ? 32 : 24),

                  // Question card
                  Expanded(
                    child: AnimatedBuilder(
                      animation: cardAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: cardAnimation.value,
                          child: Opacity(
                            opacity: cardAnimation.value,
                            child: _QuestionCard(
                              question: currentQuestion,
                              selectedAnswerIndex: selectedAnswerIndex,
                              hasAnswered: hasAnswered,
                              showExplanation: showExplanation,
                              onAnswerSelected: onAnswerSelected,
                              isLargeScreen: isLargeScreen,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Next button
                  if (hasAnswered && showExplanation)
                    Padding(
                      padding: EdgeInsets.only(top: isLargeScreen ? 20 : 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onNextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isLargeScreen ? 20 : 16,
                            ),
                          ),
                          child: Text(
                            currentQuestionIndex < questions.length - 1
                                ? (l10n?.nextQuestion ?? 'Siguiente Pregunta')
                                : (l10n?.viewResults ?? 'Ver Resultados'),
                            style: TextStyle(
                              fontSize: isLargeScreen ? 18 : 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final TriviaQuestion question;
  final int? selectedAnswerIndex;
  final bool hasAnswered;
  final bool showExplanation;
  final Function(int) onAnswerSelected;
  final bool isLargeScreen;

  const _QuestionCard({
    required this.question,
    required this.selectedAnswerIndex,
    required this.hasAnswered,
    required this.showExplanation,
    required this.onAnswerSelected,
    this.isLargeScreen = false,
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
        padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and difficulty badges
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 16 : 12,
                    vertical: isLargeScreen ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    question.category,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: isLargeScreen ? 14 : 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 16 : 12,
                    vertical: isLargeScreen ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(question.difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    question.difficulty,
                    style: TextStyle(
                      color: _getDifficultyColor(question.difficulty),
                      fontWeight: FontWeight.bold,
                      fontSize: isLargeScreen ? 14 : 12,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isLargeScreen ? 20 : 16),

            // Question
            Text(
              question.question,
              style: TextStyle(
                fontSize: isLargeScreen ? 22 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: isLargeScreen ? 28 : 24),

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
                    isLargeScreen: isLargeScreen,
                  );
                },
              ),
            ),

            // Explanation
            if (showExplanation) ...[
              SizedBox(height: isLargeScreen ? 20 : 16),
              Container(
                padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
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
                        Icon(
                          Icons.lightbulb,
                          color: Colors.blue,
                          size: isLargeScreen ? 24 : 20,
                        ),
                        SizedBox(width: isLargeScreen ? 10 : 8),
                        Text(
                          l10n?.explanation ?? 'Explicación',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: isLargeScreen ? 18 : 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isLargeScreen ? 12 : 8),
                    Text(
                      question.explanation,
                      style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
      case 'easy':
        return Colors.green;
      case 'medio':
      case 'medium':
        return Colors.orange;
      case 'difícil':
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final VoidCallback onTap;
  final bool isLargeScreen;

  const _OptionTile({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    required this.onTap,
    this.isLargeScreen = false,
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
      margin: EdgeInsets.only(bottom: isLargeScreen ? 16 : 12),
      child: InkWell(
        onTap: hasAnswered ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
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
                width: isLargeScreen ? 28 : 24,
                height: isLargeScreen ? 28 : 24,
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
                      fontSize: isLargeScreen ? 14 : 12,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isLargeScreen ? 20 : 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
                ),
              ),
              if (icon != null) ...[
                SizedBox(width: isLargeScreen ? 12 : 8),
                Icon(
                  icon,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: isLargeScreen ? 24 : 20,
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
            context.go('/minigames');
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
