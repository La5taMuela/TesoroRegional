import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('es', 'CL'),
    Locale('en', 'US'),
  ];

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // App general
  String get appName => translate('app_name');
  String get settings => translate('settings');
  String get cancel => translate('cancel');
  String get exit => translate('exit');
  String get exitApp => translate('exit_app');
  String get exitAppConfirmation => translate('exit_app_confirmation');
  String get startButton => translate('start_button');
  String get welcomeSubtitle => translate('welcome_subtitle');
  String get exploreSection => translate('explore_section');
  String get minigamesSection => translate('minigames_section');
  String get playNow => translate('play_now');
  String get viewAll => translate('view_all');
  String get unlock => translate('unlock');
  String get unlocked => translate('unlocked');
  String get locked => translate('locked');
  String get restart => translate('restart');
  String get time => translate('time');
  String get moves => translate('moves');
  String get pairs => translate('pairs');
  String get congratulations => translate('congratulations');
  String get playAgain => translate('play_again');
  String get excellentMemory => translate('excellent_memory');
  String get greatWork => translate('great_work');
  String get wellDone => translate('well_done');
  String get comingSoon => translate('coming_soon');
  String get workingOnMoreGames => translate('working_on_more_games');
  String get understood => translate('understood');

  // Modules
  String get puzzle => translate('puzzle');
  String get map => translate('map');
  String get missions => translate('missions');
  String get stories => translate('stories');

  // Minigames
  String get minigames => translate('minigames');
  String get triviaGame => translate('trivia_game');
  String get memoryGame => translate('memory_game');
  String get puzzleSlider => translate('puzzle_slider');
  String get culturalMinigames => translate('cultural_minigames');
  String get learnPlayingSubtitle => translate('learn_playing_subtitle');
  String get triviaDescription => translate('trivia_description');
  String get memoryDescription => translate('memory_description');
  String get puzzleDescription => translate('puzzle_description');
  String get moreGamesInDevelopment => translate('more_games_in_development');
  String get culturalMemory => translate('cultural_memory');

  // Progress
  String get puzzleProgress => translate('puzzle_progress');
  String piecesDiscovered(int collected, int total) => translate('pieces_discovered').replaceAll('{collected}', collected.toString()).replaceAll('{total}', total.toString());
  String piecesRemaining(int remaining) => translate('pieces_remaining').replaceAll('{remaining}', remaining.toString());

  // Map
  String get culturalMap => translate('cultural_map');
  String get culturalMapTitle => translate('cultural_map_title');
  String get zoomInDevelopment => translate('zoom_in_development');
  String get zoomOutDevelopment => translate('zoom_out_development');
  String get viewExamplePiece => translate('view_example_piece');
  String get pieceUnlocked => translate('piece_unlocked');
  String mapCenter(String lat, String lng) => translate('map_center').replaceAll('{lat}', lat.toString()).replaceAll('{lng}', lng.toString());
  String locationFound(String lat, String lng) => translate('location_found').replaceAll('{lat}', lat.toString()).replaceAll('{lng}', lng.toString());
  String locationError(String error) => translate('location_error').replaceAll('{error}', error);
  String piecesDiscoveredCount(int count) => translate('pieces_discovered_count').replaceAll('{count}', count.toString());

  // Memory Game
  String gameCompletedInMoves(int moves) => translate('game_completed_in_moves').replaceAll('{moves}', moves.toString());
  String gameTime(String time) => translate('game_time').replaceAll('{time}', time);
  String get selectCategory => translate('select_category');

  // Memory Game Categories
  String get category_history => translate('category_history');
  String get category_gastronomy => translate('category_gastronomy');
  String get category_nature => translate('category_nature');
  String get category_architecture => translate('category_architecture');
  String get category_crafts => translate('category_crafts');
  String get category_tourism => translate('category_tourism');

  // Settings
  String get settingsSubtitle => translate('settings_subtitle');
  String get developerTools => translate('developer_tools');
  String get qrGenerator => translate('qr_generator');
  String get qrGeneratorDesc => translate('qr_generator_desc');
  String get appSettings => translate('app_settings');
  String get language => translate('language');
  String get notifications => translate('notifications');
  String get notificationsEnabled => translate('notifications_enabled');
  String get notificationsNotAvailable => translate('notifications_not_available');
  String get theme => translate('theme');
  String get lightTheme => translate('light_theme');
  String get darkTheme => translate('dark_theme');
  String get systemTheme => translate('system_theme');
  String get about => translate('about');
  String get aboutApp => translate('about_app');
  String get aboutAppDesc => translate('about_app_desc');
  String get version => translate('version');
  String get languageChanged => translate('language_changed');
  String get themeChanged => translate('theme_changed');
  String get spanish => translate('spanish');
  String get english => translate('english');

  // Trivia
  String get loadingQuestions => translate('loading_questions');
  String get noQuestionsLoaded => translate('no_questions_loaded');
  String get question => translate('question');
  String get ofText => translate('of');
  String get points => translate('points');
  String get nextQuestion => translate('next_question');
  String get viewResults => translate('view_results');
  String get explanation => translate('explanation');
  String get triviaCompleted => translate('trivia_completed');
  String get score => translate('score');
  String get excellentExpert => translate('excellent_expert');
  String get goodKnowledge => translate('good_knowledge');
  String get keepLearning => translate('keep_learning');

  // Puzzle Slider
  String get selectPuzzle => translate('select_puzzle');
  String get puzzleCompleted => translate('puzzle_completed');
  String get viewPuzzles => translate('view_puzzles');
  String get resetPuzzle => translate('reset_puzzle');
  String get resetPuzzleConfirmation => translate('reset_puzzle_confirmation');
  String get shuffleAgain => translate('shuffle_again');
  String get viewAllPuzzles => translate('view_all_puzzles');
  String get availablePuzzles => translate('available_puzzles');
  String get progress => translate('progress');
  String get completed => translate('completed');
  String get viewCompleteImage => translate('view_complete_image');
  String get puzzleCompletedInstructions => translate('puzzle_completed_instructions');
  String get puzzleInstructions => translate('puzzle_instructions');
  String get excellentStrategy => translate('excellent_strategy');
  String get goodStrategy => translate('good_strategy');
  String get keepPracticing => translate('keep_practicing');

  // Missions
  String get pointsToVisit => translate('points_to_visit');
  String get missionCompleted => translate('mission_completed');
  String get youHaveObtained => translate('you_have_obtained');

  // Stories
  String get refresh => translate('refresh');
  String get noStoriesAvailable => translate('no_stories_available');
  String get retry => translate('retry');
  String get searchStories => translate('search_stories');
  String get filterByCity => translate('filter_by_city');
  String get noStoriesFound => translate('no_stories_found');
  String get read => translate('read');
  String get readMore => translate('read_more');
  String get minutes => translate('minutes');

  // Trivia específico
  String get triviaProgress => translate('trivia_progress');
  String get questionsAnswered => translate('questions_answered');
  String get bestScore => translate('best_score');
  String get averageScore => translate('average_score');
  String get gamesPlayed => translate('games_played');
  String get difficulty => translate('difficulty');
  String get easy => translate('easy');
  String get medium => translate('medium');
  String get hard => translate('hard');
  String get loadingTrivia => translate('loading_trivia');
  String get noTriviaAvailable => translate('no_triviaAvailable');
  String get triviaStats => translate('trivia_stats');

  // QR Scanner
  String get scanQR => translate('scan_qr');
  String get qrScanner => translate('qr_scanner');
  String get cameraPermissionRequired => translate('camera_permission_required');
  String get cameraPermissionDescription => translate('camera_permission_description');
  String get allowCameraAccess => translate('allow_camera_access');
  String get pointCameraToQR => translate('point_camera_to_qr');
  String get lookForNubleQRCodes => translate('look_for_nuble_qr_codes');
  String get flash => translate('flash');
  String get flip => translate('flip');
  String get invalidQRCode => translate('invalid_qr_code');
  String get scannedCode => translate('scanned_code');
  String get continueScanning => translate('continue_scanning');
  String get close => translate('close');

  // Puzzle
  String get verifyingQRCode => translate('verifying_qr_code');
  String get pieceDiscovered => translate('piece_discovered');
  String get youHaveDiscovered => translate('you_have_discovered');
  String get category => translate('category');
  String get structuredQRRecognized => translate('structured_qr_recognized');
  String get traditionalQRRecognized => translate('traditional_qr_recognized');
  String get great => translate('great');
  String get qrCodeNotRecognized => translate('qr_code_not_recognized');
  String get qrType => translate('qr_type');
  String get structured => translate('structured');
  String get traditional => translate('traditional');
  String get keywordDetected => translate('keyword_detected');
  String get validQRButNoPiece => translate('valid_qr_but_no_piece');
  String get verifyQRLocation => translate('verify_qr_location');
  String get errorProcessingQR => translate('error_processing_qr');
  String get culturalPuzzle => translate('cultural_puzzle');
  String get loadingPuzzle => translate('loading_puzzle');
  String get pieces => translate('pieces');
  String get noPiecesDiscoveredYet => translate('no_pieces_discovered_yet');
  String get scanQRInstructions => translate('scan_qr_instructions');
  String get noPiecesInCategory => translate('no_pieces_in_category');

  // Trivia specific
  String get selectDifficulty => translate('select_difficulty');
  String get selectDifficultyDescription => translate('select_difficulty_description');
  String get easyDescription => translate('easy_description');
  String get mediumDescription => translate('medium_description');
  String get hardDescription => translate('hard_description');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
