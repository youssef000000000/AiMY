import 'package:aimy/core/core.dart';
import 'package:aimy/data/data.dart';
import 'package:aimy/domain/domain.dart';
import 'package:flutter/material.dart';

import 'call_outcome_summary_screen.dart';

class PostCallScreen extends StatefulWidget {
  const PostCallScreen({
    super.key,
    required this.profile,
    required this.elapsed,
    this.callSid,
    this.profileRepository,
  });

  final ProfileEntity profile;
  final Duration elapsed;
  final String? callSid;
  final ProfileRepository? profileRepository;

  @override
  State<PostCallScreen> createState() => _PostCallScreenState();
}

class _PostCallScreenState extends State<PostCallScreen> {
  late final ProfileRepository _profileRepository;
  DateTime? _scheduledInterviewAt;
  final List<String> _recruiterNotes = <String>[];
  bool _isLoadingSavedData = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _profileRepository = widget.profileRepository ?? MockProfileRepository();
    _hydrateSavedData();
  }

  Future<void> _hydrateSavedData() async {
    final existing = await _profileRepository.getPostCallData(widget.profile.id);
    if (!mounted) return;
    if (existing != null) {
      _scheduledInterviewAt = existing.scheduledInterviewAt;
      _recruiterNotes
        ..clear()
        ..addAll(existing.recruiterNotes);
    }
    setState(() => _isLoadingSavedData = false);
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatDateTime(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year} $hour:$minute';
  }

  Future<void> _scheduleInterview() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _scheduledInterviewAt ?? now.add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledInterviewAt ?? now),
    );
    if (time == null || !mounted) return;

    final scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => _scheduledInterviewAt = scheduled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Interview scheduled for ${_formatDateTime(scheduled)}')),
    );
  }

  Future<void> _addRecruiterNote() async {
    var draftNote = '';
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add recruiter note',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AimyPhoneDesignTokens.textBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                maxLines: 4,
                autofocus: true,
                onChanged: (v) => draftNote = v,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Write a quick note...',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(draftNote.trim());
                      },
                      child: const Text('Save note'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (note == null || note.isEmpty || !mounted) return;
    setState(() => _recruiterNotes.add(note));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recruiter note added')),
    );
  }

  void _removeNoteAt(int index) {
    if (index < 0 || index >= _recruiterNotes.length) return;
    setState(() => _recruiterNotes.removeAt(index));
  }

  Future<void> _saveToProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await _profileRepository.savePostCallData(
        profileId: widget.profile.id,
        summary:
            'Call ended in ${_format(widget.elapsed)} with ${widget.profile.displayName}.',
        recruiterNotes: List<String>.from(_recruiterNotes),
        scheduledInterviewAt: _scheduledInterviewAt,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post-call data saved to profile')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save profile data. Please retry.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  PostCallDataEntity _buildPostCallData() {
    return PostCallDataEntity(
      profileId: widget.profile.id,
      summary: 'Call ended in ${_format(widget.elapsed)} with ${widget.profile.displayName}.',
      recruiterNotes: List<String>.from(_recruiterNotes),
      scheduledInterviewAt: _scheduledInterviewAt,
      savedAt: DateTime.now(),
    );
  }

  Future<void> _goToOutcomeSummary() async {
    if (_isSaving) return;
    final payload = _buildPostCallData();
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CallOutcomeSummaryScreen(
          profile: widget.profile,
          postCallData: payload,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AimyPhoneDesignTokens.screenPaddingH,
              AimyPhoneDesignTokens.screenPaddingV,
              AimyPhoneDesignTokens.screenPaddingH,
              AimyPhoneDesignTokens.screenPaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoadingSavedData) ...[
                  const LinearProgressIndicator(minHeight: 2),
                  const SizedBox(height: 10),
                ],
                Text(
                  'Call ended • ${_format(widget.elapsed)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AimyPhoneDesignTokens.textH2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.profile.displayName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AimyPhoneDesignTokens.textBodySm,
                  ),
                ),
                if (_scheduledInterviewAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Interview: ${_formatDateTime(_scheduledInterviewAt!)}',
                    style: const TextStyle(
                      color: AppColors.accentBlue,
                      fontSize: AimyPhoneDesignTokens.textCaption,
                    ),
                  ),
                ],
                if (_recruiterNotes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Notes captured: ${_recruiterNotes.length}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: AimyPhoneDesignTokens.textCaption,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._recruiterNotes.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '• ${entry.value}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: AimyPhoneDesignTokens.textCaption,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeNoteAt(entry.key),
                            icon: const Icon(Icons.close, size: 16),
                            tooltip: 'Remove note',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _SummaryCard(profile: widget.profile),
                const SizedBox(height: 16),
                const _SectionTitle('Insights'),
                const SizedBox(height: 8),
                const _InsightCard(
                  icon: Icons.task_alt,
                  text: 'Candidate is interested and available this week.',
                ),
                const SizedBox(height: 8),
                const _InsightCard(
                  icon: Icons.schedule,
                  text: 'Suggested next step: schedule technical interview.',
                ),
                const SizedBox(height: 16),
                const _SectionTitle('Actions'),
                const SizedBox(height: 8),
                _ActionCard(
                  icon: Icons.calendar_month,
                  title: 'Schedule interview',
                  actionLabel: _scheduledInterviewAt == null ? 'Open' : 'Edit',
                  onTap: _scheduleInterview,
                ),
                const SizedBox(height: 8),
                _ActionCard(
                  icon: Icons.note_alt,
                  title: 'Add recruiter notes',
                  actionLabel: _recruiterNotes.isEmpty ? 'Open' : 'View',
                  onTap: _addRecruiterNote,
                ),
                if (widget.callSid != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'sid: ${widget.callSid}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: AimyPhoneDesignTokens.textCaption,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveToProfile,
                    child: Text(_isSaving ? 'Saving...' : 'Save to profile'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _goToOutcomeSummary,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x3321262D),
        borderRadius: BorderRadius.circular(AimyPhoneDesignTokens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Summary:\n'
        'Spoke with ${profile.displayName} about the current opportunity. '
        'Candidate asked about role scope, process timeline, and next interview stage.',
        style: const TextStyle(
          color: AppColors.onSurface,
          fontSize: AimyPhoneDesignTokens.textBodySm,
          height: 1.35,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: AimyPhoneDesignTokens.textBodySm,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AimyPhoneDesignTokens.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accentBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AimyPhoneDesignTokens.textCaption,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AimyPhoneDesignTokens.radiusMd),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AimyPhoneDesignTokens.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AimyPhoneDesignTokens.textBodySm,
                  ),
                ),
              ),
              Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.accentBlue,
                  fontSize: AimyPhoneDesignTokens.textCaption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
