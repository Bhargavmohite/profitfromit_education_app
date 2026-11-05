import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Speech reading options for text lessons.
/// Hinglish is an experimental Hindi/English mixture, not an ML Kit language.
enum LessonSpeechLanguage {
  english,
  hindi,
  hinglish,
  gujarati,
  marathi,
  bengali,
  tamil,
  telugu,
  malayalam,
  bhojpuri,
  haryanvi,
  arabic,
  rajasthani,
}

extension LessonSpeechLanguageInfo on LessonSpeechLanguage {
  String get label {
    switch (this) {
      case LessonSpeechLanguage.english:
        return 'English';
      case LessonSpeechLanguage.hindi:
        return 'Hindi';
      case LessonSpeechLanguage.hinglish:
        return 'Hinglish (beta)';
      case LessonSpeechLanguage.gujarati:
        return 'Gujarati';
      case LessonSpeechLanguage.marathi:
        return 'Marathi';
      case LessonSpeechLanguage.bengali:
        return 'Bengali';
      case LessonSpeechLanguage.tamil:
        return 'Tamil';
      case LessonSpeechLanguage.telugu:
        return 'Telugu';
      case LessonSpeechLanguage.malayalam:
        return 'Malayalam';
      case LessonSpeechLanguage.bhojpuri:
        return 'Bhojpuri';
      case LessonSpeechLanguage.haryanvi:
        return 'Haryanvi';
      case LessonSpeechLanguage.arabic:
        return 'Arabic';
      case LessonSpeechLanguage.rajasthani:
        return 'Rajasthani';
    }
  }

  String get speechLocale {
    switch (this) {
      case LessonSpeechLanguage.english:
        return 'en-IN';
      case LessonSpeechLanguage.hindi:
      case LessonSpeechLanguage.hinglish:
        return 'hi-IN';
      case LessonSpeechLanguage.gujarati:
        return 'gu-IN';
      case LessonSpeechLanguage.marathi:
        return 'mr-IN';
      case LessonSpeechLanguage.bengali:
        return 'bn-IN';
      case LessonSpeechLanguage.tamil:
        return 'ta-IN';
      case LessonSpeechLanguage.telugu:
        return 'te-IN';
      case LessonSpeechLanguage.arabic:
        return 'ar-SA';
      case LessonSpeechLanguage.malayalam:
      case LessonSpeechLanguage.bhojpuri:
      case LessonSpeechLanguage.haryanvi:
      case LessonSpeechLanguage.rajasthani:
        throw UnsupportedError('No configured TTS voice for $label.');
    }
  }

  TranslateLanguage? get translationTarget {
    switch (this) {
      case LessonSpeechLanguage.english:
        return null;
      case LessonSpeechLanguage.hindi:
      case LessonSpeechLanguage.hinglish:
        return TranslateLanguage.hindi;
      case LessonSpeechLanguage.gujarati:
        return TranslateLanguage.gujarati;
      case LessonSpeechLanguage.marathi:
        return TranslateLanguage.marathi;
      case LessonSpeechLanguage.bengali:
        return TranslateLanguage.bengali;
      case LessonSpeechLanguage.tamil:
        return TranslateLanguage.tamil;
      case LessonSpeechLanguage.telugu:
        return TranslateLanguage.telugu;
      case LessonSpeechLanguage.arabic:
        return TranslateLanguage.arabic;
      // ML Kit on-device TRANSLATION does not support these languages.
      case LessonSpeechLanguage.malayalam:
      case LessonSpeechLanguage.bhojpuri:
      case LessonSpeechLanguage.haryanvi:
      case LessonSpeechLanguage.rajasthani:
        return null;
    }
  }

  /// ML Kit supports Bengali, Tamil, Telugu and Arabic, but NOT Malayalam,
  /// Bhojpuri, Haryanvi or Rajasthani as translation targets. Those options
  /// remain visible but give a clear explanation when selected.
  bool get supportsOnDeviceNarration {
    switch (this) {
      case LessonSpeechLanguage.malayalam:
      case LessonSpeechLanguage.bhojpuri:
      case LessonSpeechLanguage.haryanvi:
      case LessonSpeechLanguage.rajasthani:
        return false;
      default:
        return true;
    }
  }
}

/// Converts lesson text to the selected language locally using Google ML Kit.
/// ML Kit downloads language models on first use; subsequent processing is
/// on-device. Does not send lesson content to the Profit From It backend.
class LessonTranslationService {
  final OnDeviceTranslatorModelManager _models =
      OnDeviceTranslatorModelManager();

  /// One screen's cache; changing a lesson creates a fresh service instance.
  final Map<LessonSpeechLanguage, String> _cache = {};
  String? _cachedSource;

  Future<String> prepare(
      String englishText, LessonSpeechLanguage language) async {
    final source = englishText.trim();
    if (source.isEmpty) throw StateError('There is no lesson text to read.');
    if (!language.supportsOnDeviceNarration) {
      throw UnsupportedError(
        '${language.label} translation is not available through the '
        'current offline translator. A supported translation and speech '
        'service is required before this language can be enabled.',
      );
    }
    if (language == LessonSpeechLanguage.english) return source;

    if (source != _cachedSource) {
      _cachedSource = source;
      _cache.clear();
    }
    final cached = _cache[language];
    if (cached != null) return cached;

    final target = language.translationTarget!;
    await _ensureModel(TranslateLanguage.english);
    await _ensureModel(target);

    final translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: target,
    );

    try {
      // Translate manageable chunks to support long educational articles.
      final translated = <String>[];
      for (final chunk in splitAtWordBoundary(source, 950)) {
        translated.add(await translator.translateText(chunk));
      }
      var result = translated.join(' ').trim();
      if (result.isEmpty) throw StateError('Translation returned no text.');
      if (language == LessonSpeechLanguage.hinglish) {
        result = _toExperimentalHinglish(result);
      }
      _cache[language] = result;
      return result;
    } finally {
      await translator.close();
    }
  }

  Future<void> _ensureModel(TranslateLanguage language) async {
    final code = language.bcpCode;
    if (await _models.isModelDownloaded(code)) return;

    final installed = await _models.downloadModel(
      code,
      isWifiRequired: false,
    );
    if (!installed) {
      throw StateError('Could not download the $code translation model. '
          'Connect to the internet and try again.');
    }
  }

  /// Keeps familiar investing vocabulary in English inside Hindi sentences.
  /// Natural Hinglish requires a dedicated bilingual translation model.
  static String _toExperimentalHinglish(String hindiText) {
    const replacements = <String, String>{
      'शेयर बाजार': 'stock market',
      'स्टॉक मार्केट': 'stock market',
      'शेयर मार्केट': 'stock market',
      'म्यूचुअल फंड': 'mutual fund',
      'म्युचुअल फंड': 'mutual fund',
      'पोर्टफोलियो': 'portfolio',
      'पोर्टफ़ोलियो': 'portfolio',
      'डिविडेंड': 'dividend',
      'लाभांश': 'dividend',
      'बजट': 'budget',
      'रिटर्न': 'returns',
      'मुद्रास्फीति': 'inflation',
    };
    var text = hindiText;
    for (final replacement in replacements.entries) {
      text = text.replaceAll(replacement.key, replacement.value);
    }
    return text;
  }
}

/// Splits long text at words (or a hard limit for oversized tokens) so that
/// both ML Kit translation and Android TTS receive bounded strings.
List<String> splitAtWordBoundary(String text, int maxLength) {
  assert(maxLength > 0);
  final parts = <String>[];
  final words = text.split(RegExp(r'\s+'));
  var buffer = StringBuffer();
  var length = 0;

  void flush() {
    if (length == 0) return;
    parts.add(buffer.toString());
    buffer = StringBuffer();
    length = 0;
  }

  for (final word in words) {
    if (word.isEmpty) continue;
    if (word.length > maxLength) {
      flush();
      for (var start = 0; start < word.length; start += maxLength) {
        final end =
            (start + maxLength < word.length) ? start + maxLength : word.length;
        parts.add(word.substring(start, end));
      }
      continue;
    }
    if (length + (length > 0 ? 1 : 0) + word.length > maxLength) flush();
    if (length > 0) {
      buffer.write(' ');
      length++;
    }
    buffer.write(word);
    length += word.length;
  }
  flush();
  return parts;
}
