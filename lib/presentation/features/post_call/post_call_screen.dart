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
  String? _summaryOverride;
  String _disposition = 'Interested';
  String _stage = 'Technical interview';
  final List<String> _followUpTasks = <String>[];

  @override
  void initState() {
    super.initState();
    _profileRepository = widget.profileRepository ?? MockProfileRepository();
    _hydrateSavedData();
  }

  Future<void> _hydrateSavedData() async {
    final existing =
        await _profileRepository.getPostCallData(widget.profile.id);
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

  String get _summaryText =>
      _summaryOverride ??
      'Spoke with ${widget.profile.displayName} about the current opportunity. '
          'Candidate asked about role scope, process timeline, and next interview stage.';

  Future<void> _scheduleInterview() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nextBusinessDay = now.add(const Duration(days: 2));

    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Schedule interview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AimyPhoneDesignTokens.textBody,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a quick demo slot or pick a custom time.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AimyPhoneDesignTokens.textCaption,
                  ),
                ),
                const SizedBox(height: 14),
                _ScheduleOptionTile(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Tomorrow morning',
                  subtitle: _formatDateTime(
                    DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10),
                  ),
                  onTap: () => Navigator.of(context).pop(
                    DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10),
                  ),
                ),
                const SizedBox(height: 8),
                _ScheduleOptionTile(
                  icon: Icons.schedule,
                  title: 'Tomorrow afternoon',
                  subtitle: _formatDateTime(
                    DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14),
                  ),
                  onTap: () => Navigator.of(context).pop(
                    DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14),
                  ),
                ),
                const SizedBox(height: 8),
                _ScheduleOptionTile(
                  icon: Icons.event_available,
                  title: 'Next available slot',
                  subtitle: _formatDateTime(
                    DateTime(
                      nextBusinessDay.year,
                      nextBusinessDay.month,
                      nextBusinessDay.day,
                      11,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(
                    DateTime(
                      nextBusinessDay.year,
                      nextBusinessDay.month,
                      nextBusinessDay.day,
                      11,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _ScheduleOptionTile(
                  icon: Icons.edit_calendar_outlined,
                  title: 'Pick custom date and time',
                  subtitle: 'Open calendar and time picker',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (selected != null) {
      _applyScheduledInterview(selected);
      return;
    }

    await _pickCustomInterviewTime(now);
  }

  Future<void> _pickCustomInterviewTime(DateTime now) async {
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _scheduledInterviewAt ?? now.add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentBlue,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledInterviewAt ?? now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentBlue,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null || !mounted) return;

    final scheduled =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    _applyScheduledInterview(scheduled);
  }

  void _applyScheduledInterview(DateTime scheduled) {
    setState(() => _scheduledInterviewAt = scheduled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Interview scheduled for ${_formatDateTime(scheduled)}')),
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
    final confirmed = await _confirmProfileSync();
    if (confirmed != true || !mounted) return;
    setState(() => _isSaving = true);
    try {
      await _profileRepository.savePostCallData(
        profileId: widget.profile.id,
        summary: _summaryText,
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
        const SnackBar(
            content: Text('Could not save profile data. Please retry.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool?> _confirmProfileSync() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Save to profile?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Summary: $_summaryText\n\n'
            'Disposition: $_disposition\n'
            'Stage: $_stage\n'
            'Notes: ${_recruiterNotes.length}\n'
            'Interview: ${_scheduledInterviewAt == null ? 'Not scheduled' : _formatDateTime(_scheduledInterviewAt!)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editSummary() async {
    var draftSummary = _summaryText;
    final edited = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                'Edit call summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AimyPhoneDesignTokens.textBody,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: draftSummary,
                maxLines: 5,
                autofocus: true,
                onChanged: (value) => draftSummary = value,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Update summary before saving...',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(draftSummary.trim()),
                  child: const Text('Save summary'),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (edited == null || edited.isEmpty || !mounted) return;
    setState(() => _summaryOverride = edited);
  }

  Future<void> _createFollowUpTask() async {
    final task = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create follow-up task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AimyPhoneDesignTokens.textBody,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _TaskOptionTile(
                  icon: Icons.phone_callback,
                  title: 'Callback candidate tomorrow',
                  subtitle: 'Due tomorrow at 10:00',
                  onTap: () =>
                      Navigator.of(context).pop('Callback candidate tomorrow'),
                ),
                const SizedBox(height: 8),
                _TaskOptionTile(
                  icon: Icons.mail_outline,
                  title: 'Send role details',
                  subtitle: 'Share job scope and process timeline',
                  onTap: () => Navigator.of(context).pop('Send role details'),
                ),
                const SizedBox(height: 8),
                _TaskOptionTile(
                  icon: Icons.event_available,
                  title: 'Prepare technical interview',
                  subtitle: 'Add interview task for Talent pipeline',
                  onTap: () =>
                      Navigator.of(context).pop('Prepare technical interview'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (task == null || !mounted) return;
    setState(() {
      if (!_followUpTasks.contains(task)) {
        _followUpTasks.add(task);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task created: $task')),
    );
  }

  PostCallDataEntity _buildPostCallData() {
    return PostCallDataEntity(
      profileId: widget.profile.id,
      summary: _summaryText,
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Expanded(
                      child: Text(
                        'Post-Call Actions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz_rounded)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x1A58A6FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.borderGlow),
                  ),
                  child: const Text(
                    'Demo mode • local data',
                    style: TextStyle(
                      color: Color(0xFFCFE6FF),
                      fontSize: AimyPhoneDesignTokens.textCaption,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_isLoadingSavedData) ...[
                  const LinearProgressIndicator(minHeight: 2),
                  const SizedBox(height: 10),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Call ended • ${_format(widget.elapsed)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.profile.displayName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AimyPhoneDesignTokens.textBodySm,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_scheduledInterviewAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Interview: ${_formatDateTime(_scheduledInterviewAt!)}',
                    style: const TextStyle(
                      color: AppColors.accentBlue,
                      fontSize: AimyPhoneDesignTokens.textCaption,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (_recruiterNotes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes captured: ${_recruiterNotes.length}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: AimyPhoneDesignTokens.textCaption,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ..._recruiterNotes.asMap().entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '• ${entry.value}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize:
                                              AimyPhoneDesignTokens.textCaption,
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
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _SummaryCard(
                  summary: _summaryText,
                  onEdit: _editSummary,
                ),
                const SizedBox(height: 16),
                _OutcomeFieldsCard(
                  disposition: _disposition,
                  stage: _stage,
                  onDispositionChanged: (value) {
                    if (value == null) return;
                    setState(() => _disposition = value);
                  },
                  onStageChanged: (value) {
                    if (value == null) return;
                    setState(() => _stage = value);
                  },
                ),
                const SizedBox(height: 16),
                const _SectionTitle('Advanced insights'),
                const SizedBox(height: 8),
                const _InsightScoreCard(),
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
                const SizedBox(height: 8),
                _ActionCard(
                  icon: Icons.playlist_add_check_circle,
                  title: 'Create follow-up task',
                  actionLabel: _followUpTasks.isEmpty ? 'Add' : 'View',
                  onTap: _createFollowUpTask,
                ),
                if (_followUpTasks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _FollowUpTasksCard(tasks: _followUpTasks),
                ],
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
  const _SummaryCard({required this.summary, required this.onEdit});

  final String summary;
  final VoidCallback onEdit;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Editable summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: AimyPhoneDesignTokens.textBodySm,
                  ),
                ),
              ),
              TextButton(onPressed: onEdit, child: const Text('Edit')),
            ],
          ),
          Text(
            summary,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: AimyPhoneDesignTokens.textBodySm,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeFieldsCard extends StatelessWidget {
  const _OutcomeFieldsCard({
    required this.disposition,
    required this.stage,
    required this.onDispositionChanged,
    required this.onStageChanged,
  });

  final String disposition;
  final String stage;
  final ValueChanged<String?> onDispositionChanged;
  final ValueChanged<String?> onStageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AimyPhoneDesignTokens.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile sync fields',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: AimyPhoneDesignTokens.textBodySm,
            ),
          ),
          const SizedBox(height: 10),
          _DarkDropdown(
            label: 'Disposition',
            value: disposition,
            values: const ['Interested', 'Follow-up', 'Not interested'],
            onChanged: onDispositionChanged,
          ),
          const SizedBox(height: 8),
          _DarkDropdown(
            label: 'Stage',
            value: stage,
            values: const ['Technical interview', 'Shortlisted', 'Nurture'],
            onChanged: onStageChanged,
          ),
        ],
      ),
    );
  }
}

class _DarkDropdown extends StatelessWidget {
  const _DarkDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.surface,
      decoration: InputDecoration(labelText: label),
      style: const TextStyle(color: Colors.white),
      items: values
          .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _ScheduleOptionTile extends StatelessWidget {
  const _ScheduleOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
              Icon(icon, color: AppColors.accentBlue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AimyPhoneDesignTokens.textBodySm,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AimyPhoneDesignTokens.textCaption,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskOptionTile extends StatelessWidget {
  const _TaskOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ScheduleOptionTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class _FollowUpTasksCard extends StatelessWidget {
  const _FollowUpTasksCard({required this.tasks});

  final List<String> tasks;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow-up tasks: ${tasks.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: AimyPhoneDesignTokens.textBodySm,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.task_alt,
                    color: AppColors.accentBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AimyPhoneDesignTokens.textCaption,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

class _InsightScoreCard extends StatelessWidget {
  const _InsightScoreCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE7F0FF),
            child: Text(
              '92',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confidence score: High',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Strong communication and relevant project examples.',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
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
