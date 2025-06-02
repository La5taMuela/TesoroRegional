import 'package:tesoro_regional/features/puzzle/domain/entities/language_localized.dart';

class LanguageLocalizedDto {
  final String languageCode;
  final String text;

  const LanguageLocalizedDto({
    required this.languageCode,
    required this.text,
  });

  factory LanguageLocalizedDto.fromJson(Map<String, dynamic> json) {
    return LanguageLocalizedDto(
      languageCode: json['languageCode'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'text': text,
    };
  }

  LanguageLocalizedDto copyWith({
    String? languageCode,
    String? text,
  }) {
    return LanguageLocalizedDto(
      languageCode: languageCode ?? this.languageCode,
      text: text ?? this.text,
    );
  }

  // Convert to domain entity
  LanguageLocalized toDomain() {
    return LanguageLocalized(
      languageCode: languageCode,
      text: text,
    );
  }

  // Create from domain entity
  factory LanguageLocalizedDto.fromDomain(LanguageLocalized localized) {
    return LanguageLocalizedDto(
      languageCode: localized.languageCode,
      text: localized.text,
    );
  }
}
