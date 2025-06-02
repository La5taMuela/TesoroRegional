import 'package:flutter/material.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class CompletionProgress extends StatelessWidget {
  final double percentage;

  const CompletionProgress({Key? key, required this.percentage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _CompletionProgressContent(percentage: percentage);
  }
}

class _CompletionProgressContent extends StatefulWidget {
  final double percentage;

  const _CompletionProgressContent({Key? key, required this.percentage})
      : super(key: key);

  @override
  State<_CompletionProgressContent> createState() =>
      _CompletionProgressContentState();
}

class _CompletionProgressContentState extends State<_CompletionProgressContent> {
  double get percentage => widget.percentage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text('Loading...'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.puzzleProgress,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 100
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 100
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}