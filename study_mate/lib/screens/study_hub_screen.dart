import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/note_provider.dart';
import 'package:study_mate/providers/flashcard_provider.dart';
import 'package:study_mate/screens/notes_list_screen.dart';
import 'package:study_mate/screens/flashcards_list_screen.dart';
import 'package:study_mate/screens/focus_timer_screen.dart';
import 'package:study_mate/screens/quizzes_screen.dart';
import 'package:study_mate/screens/statistics_screen.dart';

class StudyHubScreen extends StatelessWidget {
  const StudyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteProvider = Provider.of<NoteProvider>(context);
    final flashcardProvider = Provider.of<FlashcardProvider>(context);
    final noteCount = noteProvider.notes.length;
    final flashcardTotalCount = flashcardProvider.flashcards.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  Text('Study', style: theme.textTheme.headlineLarge),
                  Text(
                    'Organize your materials and focus on learning.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),

                  // Bento Grid Layout
                  MediaQuery.of(context).size.width >= 768
                      ? _buildDesktopBentoGrid(context, noteCount, flashcardTotalCount)
                      : _buildMobileBentoGrid(context, noteCount, flashcardTotalCount),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopBentoGrid(BuildContext context, int noteCount, int flashCount) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _buildNotesCard(context, noteCount)),
            const SizedBox(width: 24),
            Expanded(child: _buildFlashcardsCard(context, flashCount)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildQuizzesCard(context)),
            const SizedBox(width: 24),
            Expanded(child: _buildTimerCard(context)),
            const SizedBox(width: 24),
            Expanded(child: _buildStatsCard(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileBentoGrid(BuildContext context, int noteCount, int flashCount) {
    return Column(
      children: [
        _buildNotesCard(context, noteCount),
        const SizedBox(height: 16),
        _buildFlashcardsCard(context, flashCount),
        const SizedBox(height: 16),
        _buildQuizzesCard(context),
        const SizedBox(height: 16),
        _buildTimerCard(context),
        const SizedBox(height: 16),
        _buildStatsCard(context),
      ],
    );
  }

  Widget _buildNotesCard(BuildContext context, int noteCount) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotesListScreen()),
        );
      },
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              bottom: -20,
              width: 150,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryFixed.withValues(alpha: 0), AppTheme.primaryFixed.withValues(alpha: 0.4)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.description, color: AppTheme.onPrimaryContainer),
                ),
                const SizedBox(height: 16),
                const Text('Notes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Access, organize, and review your class notes. Syncs across all devices.',
                  style: TextStyle(color: AppTheme.onSurfaceVariant),
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildBadge('$noteCount NOTES'),
                    const SizedBox(width: 8),
                    _buildBadge('LOCALLY SAVED'),
                  ],
                ),
              ],
            ),
            const Positioned(
              bottom: 0,
              right: 0,
              child: Icon(Icons.arrow_forward, color: AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.surfaceVariant.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4)),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildFlashcardsCard(BuildContext context, int flashCount) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FlashcardsListScreen()),
        );
      },
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.style, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.secondaryFixed, borderRadius: BorderRadius.circular(4)),
                  child: Text('TOTAL: $flashCount', style: const TextStyle(color: AppTheme.onSecondaryFixed, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Flashcards', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Spaced repetition decks.', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizzesCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizzesScreen()));
      },
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFBAC8DC), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.quiz, color: AppTheme.tertiary),
            ),
            const SizedBox(height: 16),
            const Text('Quizzes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Test your knowledge.', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FocusTimerScreen()),
        );
      },
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2D3133),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, color: AppTheme.primaryFixed, size: 48),
            const SizedBox(height: 12),
            const Text('Study Timer', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Pomodoro focus sessions', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Start Session', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
      },
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.surfaceVariant.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.bar_chart, color: AppTheme.onSurface),
                ),
                const SizedBox(width: 12),
                const Text('Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            const Center(
              child: Text('View study analytics', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
