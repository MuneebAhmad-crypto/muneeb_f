import 'dart:async';
import 'package:flutter/material.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  Timer? _timer;
  int _secondsRemaining = 25 * 60;
  int _initialSeconds = 25 * 60;
  bool _isActive = false;
  String _currentMode = 'Focus';

  void _startTimer() {
    setState(() => _isActive = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _onTimerComplete();
      }
    });
  }

  void _onTimerComplete() async {
    setState(() => _isActive = false);
    if (_currentMode == 'Focus') {
      final durationMinutes = _initialSeconds ~/ 60;
      await _supabaseService.saveStudySession(null, durationMinutes, 'focus');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Focus session saved!')));
      }
    }
    _resetTimer();
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isActive = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      if (_currentMode == 'Focus') _secondsRemaining = 25 * 60;
      if (_currentMode == 'Short Break') _secondsRemaining = 5 * 60;
      if (_currentMode == 'Long Break') _secondsRemaining = 15 * 60;
      _initialSeconds = _secondsRemaining;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Focus Timer', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('CURRENT FOCUS', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.primaryFixed, borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book, size: 18, color: AppTheme.onPrimaryFixed),
                    SizedBox(width: 8),
                    Text('Data Structures', style: TextStyle(color: AppTheme.onPrimaryFixed, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 32, offset: const Offset(0, 8))],
                  border: Border.all(color: AppTheme.surfaceVariant),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [
                          _buildModeButton('Focus'),
                          _buildModeButton('Short Break'),
                          _buildModeButton('Long Break'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryFixed.withValues(alpha: 0.3)),
                          ),
                        ),
                        Text(
                          _formatTime(_secondsRemaining),
                          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: -2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _resetTimer,
                          icon: const Icon(Icons.restart_alt, size: 28, color: AppTheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: _isActive ? _pauseTimer : _startTimer,
                          child: Container(
                            width: 100,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: AppTheme.secondaryContainer.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 4))],
                            ),
                            child: Icon(_isActive ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          onPressed: _onTimerComplete,
                          icon: const Icon(Icons.skip_next, size: 28, color: AppTheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text("TODAY'S TOTAL FOCUS", style: TextStyle(color: AppTheme.outline, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('2', style: theme.textTheme.headlineMedium),
                  const Text('h ', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
                  Text('15', style: theme.textTheme.headlineMedium),
                  const Text('m', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentMode = mode;
            _resetTimer();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            mode,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
