import 'package:flutter/material.dart';
import 'package:study_mate/core/theme/app_theme.dart';

class StudyHubScreen extends StatelessWidget {
  const StudyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return _buildDesktopBentoGrid(context);
                    } else {
                      return _buildMobileBentoGrid(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopBentoGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _buildNotesCard(context)),
            const SizedBox(width: 24),
            Expanded(child: _buildFlashcardsCard(context)),
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

  Widget _buildMobileBentoGrid(BuildContext context) {
    return Column(
      children: [
        _buildNotesCard(context),
        const SizedBox(height: 16),
        _buildFlashcardsCard(context),
        const SizedBox(height: 16),
        _buildQuizzesCard(context),
        const SizedBox(height: 16),
        _buildTimerCard(context),
        const SizedBox(height: 16),
        _buildStatsCard(context),
      ],
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
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
                  colors: [AppTheme.primaryFixed.withOpacity(0), AppTheme.primaryFixed.withOpacity(0.4)],
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
              Text('Notes', style: theme.textTheme.displaySmall),
              const SizedBox(height: 8),
              const Text(
                'Access, organize, and review your class notes. Syncs across all devices.',
                style: TextStyle(color: AppTheme.onSurfaceVariant),
              ),
              const Spacer(),
              Row(
                children: [
                  _buildBadge('12 FOLDERS'),
                  const SizedBox(width: 8),
                  _buildBadge('UPDATED TODAY'),
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
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(4)),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildFlashcardsCard(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
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
                child: Text('DUE: 45', style: TextStyle(color: AppTheme.onSecondaryFixed, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Flashcards', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Spaced repetition decks.', style: TextStyle(color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildQuizzesCard(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
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
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3133),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
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
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.bar_chart, color: AppTheme.onSurface),
              ),
              const SizedBox(width: 12),
              const Text('Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(0.4),
              _buildBar(0.7),
              _buildBar(0.5),
              _buildBar(0.9, showValue: true, value: '2h'),
              _buildBar(0.3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, {bool showValue = false, String value = ''}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (showValue)
              Text(value, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            Container(
              height: 80 * heightFactor,
              decoration: BoxDecoration(
                color: showValue ? AppTheme.primary : AppTheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
