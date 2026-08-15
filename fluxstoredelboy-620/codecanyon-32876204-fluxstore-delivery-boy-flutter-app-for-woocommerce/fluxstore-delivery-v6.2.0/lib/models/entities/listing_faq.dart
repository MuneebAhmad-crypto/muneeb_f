import 'dart:convert';

import 'package:inspireui/utils/logs.dart';

class ListingFAQs {
  final List<FAQ> items;

  const ListingFAQs({this.items = const []});

  /// Listeo format: List of {question, answer} maps
  factory ListingFAQs.fromListeo(dynamic json) {
    if (json == null) return const ListingFAQs();

    final parsedItems = <FAQ>[];

    try {
      final faqData = json is String ? jsonDecode(json) : json;
      if (faqData is! List) return const ListingFAQs();

      for (final item in faqData) {
        if (item is! Map) continue;

        final q = _sanitize(item['question']);
        final a = _sanitize(item['answer']);

        if (q.isNotEmpty && a.isNotEmpty) {
          parsedItems.add(FAQ(question: q, answer: a));
        }
      }
    } catch (e, trace) {
      printLog('Error parsing Listeo FAQs: $e\n$trace');
    }

    return ListingFAQs(items: parsedItems);
  }

  /// ListingPro format: Map with faq/faqans sub-maps
  factory ListingFAQs.fromListingPro(dynamic json) {
    if (json == null) return const ListingFAQs();

    final parsedItems = <FAQ>[];

    try {
      final faqData = json is String ? jsonDecode(json) : json;
      if (faqData is! Map) return const ListingFAQs();

      final questions = faqData['faq'];
      final answers = faqData['faqans'];

      if (questions is! Map || answers is! Map || questions.isEmpty) {
        return const ListingFAQs();
      }

      questions.forEach((key, question) {
        final answer = answers[key];
        if (answer == null) return;

        final q = _sanitize(question);
        final a = _sanitize(answer);

        if (q.isNotEmpty && a.isNotEmpty) {
          parsedItems.add(FAQ(question: q, answer: a));
        }
      });
    } catch (e, trace) {
      printLog('Error parsing ListingPro FAQs: $e\n$trace');
    }

    return ListingFAQs(items: parsedItems);
  }

  static String _sanitize(dynamic text) {
    if (text == null || text is List || text is Map) return '';
    return text.toString().trim();
  }

  List<Map<String, dynamic>> toJson() => items.map((e) => e.toJson()).toList();
}

class FAQ {
  final String question;
  final String answer;

  const FAQ({required this.question, required this.answer});

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
}
