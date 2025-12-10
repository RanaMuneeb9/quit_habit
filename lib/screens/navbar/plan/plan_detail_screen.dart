import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/models/plan_mission.dart';
import 'package:signature/signature.dart';
import 'package:quit_habit/models/user_plan_mission.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/services/plan_service.dart';
import 'package:quit_habit/utils/app_colors.dart';

/// Detail screen for a plan mission where users complete tasks,
/// answer reflection questions, and (for Day 1) sign the contract.
class PlanDetailScreen extends StatefulWidget {
  final UserPlanMission mission;

  const PlanDetailScreen({super.key, required this.mission});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  late Map<int, bool> _taskCompletions;
  late Map<int, String> _reflectionAnswers;
  late List<TextEditingController> _reflectionControllers;

  SignatureController? _signatureController;
  String? _contractSignature; // base64 encoded PNG

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Initialize task completions from existing data
    _taskCompletions = Map.from(widget.mission.taskCompletions);

    // Initialize reflection answers and controllers
    _reflectionAnswers = Map.from(widget.mission.reflectionAnswers);
    _reflectionControllers = List.generate(
      widget.mission.reflectionQuestions.length,
      (index) => TextEditingController(text: _reflectionAnswers[index] ?? ''),
    );

    // Initialize signature controller for Day 1
    if (widget.mission.requiresContract) {
      _signatureController = SignatureController(
        penStrokeWidth: 3,
        penColor: AppColors.lightTextPrimary,
        exportBackgroundColor: Colors.white,
      );
      _contractSignature = widget.mission.contractSignature;
    }
  }

  @override
  void dispose() {
    for (final controller in _reflectionControllers) {
      controller.dispose();
    }
    _signatureController?.dispose();
    super.dispose();
  }

  bool get _allTasksCompleted {
    for (int i = 0; i < widget.mission.tasks.length; i++) {
      if (_taskCompletions[i] != true) return false;
    }
    return true;
  }

  bool get _contractSigned {
    if (!widget.mission.requiresContract) return true;
    return _contractSignature != null && _contractSignature!.isNotEmpty;
  }

  bool get _allReflectionsAnswered {
    if (widget.mission.reflectionQuestions.isEmpty) return true;
    for (int i = 0; i < widget.mission.reflectionQuestions.length; i++) {
      final answer = _reflectionAnswers[i] ?? '';
      if (answer.trim().isEmpty) return false;
    }
    return true;
  }

  bool get _canComplete {
    if (!_allTasksCompleted) return false;
    if (!_contractSigned) return false;
    if (!_allReflectionsAnswered) return false;
    return true;
  }

  Future<void> _saveProgress() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      if (userId == null) {
        setState(() => _isSaving = false);
        return;
      }

      // Update reflection answers from controllers
      for (int i = 0; i < _reflectionControllers.length; i++) {
        _reflectionAnswers[i] = _reflectionControllers[i].text;
      }

      await PlanService.instance.updateMissionProgress(
        userId,
        widget.mission.id,
        taskCompletions: _taskCompletions,
        reflectionAnswers: _reflectionAnswers,
        contractSignature: _contractSignature,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save progress: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _completeMission() async {
    if (_isLoading || !_canComplete) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Update reflection answers from controllers
      for (int i = 0; i < _reflectionControllers.length; i++) {
        _reflectionAnswers[i] = _reflectionControllers[i].text;
      }

      final success = await PlanService.instance.completeMission(
        userId,
        widget.mission.id,
        taskCompletions: _taskCompletions,
        reflectionAnswers: _reflectionAnswers,
        contractSignature: _contractSignature,
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Day ${widget.mission.dayNumber} completed! 🎉'),
            backgroundColor: AppColors.lightSuccess,
          ),
        );

        // Check if this completes a phase
        if (widget.mission.badgeId != null) {
          _showPhaseCompletionDialog();
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete mission: $e'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPhaseCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightSuccess.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.lightSuccess,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Phase Complete!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve completed ${widget.mission.phase.title}!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You earned the "${widget.mission.phase.title}" badge! 🏆',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to plan screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _signContract() async {
    if (_signatureController == null) return;

    final signature = await _signatureController!.toPngBytes();
    if (signature != null) {
      setState(() {
        _contractSignature = base64Encode(signature);
      });
      await _saveProgress();
    }
  }

  void _clearSignature() {
    _signatureController?.clear();
    setState(() {
      _contractSignature = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted =
        widget.mission.status == UserPlanMissionStatus.completed;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.lightTextPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Day ${widget.mission.dayNumber}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          if (widget.mission.isMilestone)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.planMilestoneBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.planMilestoneText,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'MILESTONE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.planMilestoneText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside text fields
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mission header
              _buildMissionHeader(theme),
              const SizedBox(height: 24),

              // Tasks section
              _buildTasksSection(theme, isCompleted),
              const SizedBox(height: 24),

              // Contract signing section (Day 1 only)
              if (widget.mission.requiresContract) ...[
                _buildContractSection(theme, isCompleted),
                const SizedBox(height: 24),
              ],

              // Reflection questions section
              if (widget.mission.reflectionQuestions.isNotEmpty) ...[
                _buildReflectionSection(theme, isCompleted),
                const SizedBox(height: 24),
              ],

              // Complete button
              if (!isCompleted) ...[
                _buildCompleteButton(theme),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.mission.phase.title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.lightPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Mission title
          Text(
            widget.mission.missionTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Mission description
          Text(
            widget.mission.missionDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(ThemeData theme, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.checklist_rounded,
                color: AppColors.lightPrimary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Tasks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...widget.mission.tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            final isChecked = _taskCompletions[index] ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: isCompleted
                    ? null
                    : () async {
                        setState(() {
                          _taskCompletions[index] = !isChecked;
                        });
                        await _saveProgress();
                      },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppColors.lightSuccess.withOpacity(0.1)
                        : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isChecked
                          ? AppColors.lightSuccess.withOpacity(0.3)
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isChecked
                              ? AppColors.lightSuccess
                              : Colors.transparent,
                          border: Border.all(
                            color: isChecked
                                ? AppColors.lightSuccess
                                : AppColors.lightBorder,
                            width: 2,
                          ),
                        ),
                        child: isChecked
                            ? const Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isChecked
                                ? AppColors.lightTextSecondary
                                : AppColors.lightTextPrimary,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContractSection(ThemeData theme, bool isCompleted) {
    final hasSignature =
        _contractSignature != null && _contractSignature!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasSignature
              ? AppColors.lightSuccess.withOpacity(0.5)
              : AppColors.planIconColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasSignature ? Icons.verified_rounded : Icons.draw_rounded,
                color: hasSignature
                    ? AppColors.lightSuccess
                    : AppColors.planIconColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Non-Smoker Commitment Contract',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              if (hasSignature && !isCompleted)
                IconButton(
                  onPressed: _clearSignature,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.lightTextSecondary,
                    size: 20,
                  ),
                  tooltip: 'Clear signature',
                ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            'I hereby commit to starting a new life without smoking. I understand this is a journey, and I am ready to take it one day at a time.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightTextSecondary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Signature pad or existing signature
          if (hasSignature) ...[
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.lightSuccess.withOpacity(0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Builder(
                  builder: (context) {
                    try {
                      return Image.memory(
                        base64Decode(_contractSignature!),
                        fit: BoxFit.contain,
                      );
                    } catch (_) {
                      return const Center(child: Text('Signature unavailable'));
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '✓ Contract Signed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.lightSuccess,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else if (!isCompleted) ...[
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Signature(
                  controller: _signatureController!,
                  backgroundColor: AppColors.lightBackground,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearSignature,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.lightTextSecondary,
                      side: const BorderSide(color: AppColors.lightBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _signContract,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Sign'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.planIconColor,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReflectionSection(ThemeData theme, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology_rounded,
                color: AppColors.planIconColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Reflection',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...widget.mission.reflectionQuestions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reflectionControllers[index],
                    enabled: !isCompleted,
                    maxLines: 3,
                    onChanged: (value) {
                      setState(() {
                        _reflectionAnswers[index] = value;
                      });
                    },
                    onEditingComplete: _saveProgress,
                    decoration: InputDecoration(
                      hintText: 'Write your thoughts...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextTertiary,
                      ),
                      filled: true,
                      fillColor: AppColors.lightBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.lightBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.lightBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.lightPrimary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _canComplete ? _completeMission : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canComplete
              ? AppColors.lightSuccess
              : AppColors.lightTextTertiary.withOpacity(0.3),
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _canComplete ? 2 : 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _canComplete
                        ? Icons.check_circle_rounded
                        : Icons.lock_rounded,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _canComplete
                        ? 'Complete Day ${widget.mission.dayNumber}'
                        : !_allTasksCompleted
                        ? 'Complete all tasks first'
                        : !_allReflectionsAnswered
                        ? 'Answer all reflections first'
                        : 'Sign contract first',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
