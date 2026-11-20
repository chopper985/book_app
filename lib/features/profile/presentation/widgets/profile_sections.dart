// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/app_progress_bar.dart';
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/entities/learner_progress.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_icon_box.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_style.dart';
import 'package:AppName/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';
import 'package:AppName/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:AppName/features/profile/presentation/extensions/profile_labels.dart';
import 'package:AppName/features/profile/presentation/widgets/profile_form_fields.dart';

class ProfileSectionTitle extends StatelessWidget {
  final String title;

  const ProfileSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.dsp),
      child: Text(
        title,
        style: AppText.sans(18, height: 28, weight: FontWeight.w600),
      ),
    );
  }
}

/// Bordered panel used by every profile section.
class ProfilePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ProfilePanel({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(8.dsp),
        border: Border.all(color: AppPalette.surfaceHigh),
      ),
      child: child,
    );
  }
}

/// Avatar, name, role, stack and interview date.
class ProfileCard extends StatelessWidget {
  final LearnerProfile profile;
  final String? avatarPath;
  final List<TrackOverview> stack;
  final VoidCallback onEdit;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.stack,
    required this.onEdit,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName.trim();
    final interview = profile.interviewDate;
    final birthDate = profile.birthDate;
    final localizations = MaterialLocalizations.of(context);
    final contacts = [
      if (profile.email case final email?) (Icons.mail_outline, email),
      if (profile.phone case final phone?) (Icons.phone_outlined, phone),
      if (birthDate != null)
        (Icons.cake_outlined, localizations.formatMediumDate(birthDate)),
    ];
    return ProfilePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(path: avatarPath, name: name),
              SizedBox(width: 12.dsp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sans(
                        20,
                        height: 28,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${profile.role.label} · ${profile.experience.label}',
                      style: AppText.sans(
                        13,
                        height: 18,
                        color: AppPalette.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (contacts.isNotEmpty) ...[
            SizedBox(height: 12.dsp),
            for (final (icon, text) in contacts)
              Padding(
                padding: EdgeInsets.only(top: 4.dsp),
                child: Row(
                  children: [
                    Icon(icon, size: 16.dsp, color: AppPalette.onSurfaceVariant),
                    SizedBox(width: 8.dsp),
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(13, height: 18),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          SizedBox(height: 16.dsp),
          Text(
            Strings.profileStack.i18n,
            style: AppText.mono(10, height: 14),
          ),
          SizedBox(height: 8.dsp),
          Wrap(
            spacing: 8.dsp,
            runSpacing: 8.dsp,
            children: [
              for (final overview in stack)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.dsp,
                    vertical: 4.dsp,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.surfaceHigh,
                    borderRadius: BorderRadius.circular(6.dsp),
                  ),
                  child: Text(
                    overview.track.name.text,
                    style: AppText.mono(
                      11,
                      height: 16,
                      color: AppPalette.onSurface,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.dsp),
          Row(
            children: [
              Icon(Icons.event, size: 16.dsp, color: AppPalette.purple),
              SizedBox(width: 6.dsp),
              Text(
                '${Strings.profileInterview.i18n}: ',
                style: AppText.sans(
                  13,
                  height: 18,
                  color: AppPalette.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: Text(
                  interview == null
                      ? Strings.profileInterviewNone.i18n
                      : localizations.formatMediumDate(interview),
                  style: AppText.sans(13, height: 18, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.dsp),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(44.dsp),
                side: const BorderSide(color: AppPalette.primaryStrong),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.dsp),
                ),
              ),
              icon: Icon(Icons.edit, size: 16.dsp, color: AppPalette.primary),
              label: Text(
                Strings.profileEdit.i18n,
                style: AppText.sans(
                  14,
                  height: 20,
                  weight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Level with progress to the next one, streak, practiced and accuracy.
class ProfileStats extends StatelessWidget {
  final LearnerSummary learner;

  const ProfileStats({super.key, required this.learner});

  @override
  Widget build(BuildContext context) {
    const perLevel = LearnerProgress.xpPerLevel;
    final inLevel = learner.xp % perLevel;
    return Column(
      children: [
        ProfilePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      Strings.profileLevel.i18n,
                      style: AppText.mono(10, height: 14),
                    ),
                  ),
                  Text(
                    '${Strings.levelNumber.i18n.fill([learner.level])} · '
                    '${learner.xp} XP',
                    style: AppText.mono(
                      12,
                      height: 16,
                      color: AppPalette.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.dsp),
              AppProgressBar(
                value: inLevel / perLevel,
                gradient: AppPalette.progressGradient,
              ),
              SizedBox(height: 6.dsp),
              Text(
                Strings.profileXpToNext.i18n.fill([perLevel - inLevel]),
                style: AppText.sans(
                  12,
                  height: 16,
                  color: AppPalette.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.dsp),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  label: Strings.profileStreak.i18n,
                  value: Strings.profileStreakValue.i18n
                      .fill([learner.streakDays]),
                  color: AppPalette.teal,
                ),
              ),
              SizedBox(width: 8.dsp),
              Expanded(
                child: _StatTile(
                  label: Strings.profilePracticed.i18n,
                  value: Strings.profilePracticedValue.i18n
                      .fill([learner.practicedCount]),
                  color: AppPalette.primary,
                ),
              ),
              SizedBox(width: 8.dsp),
              Expanded(
                child: _StatTile(
                  label: Strings.profileAccuracy.i18n,
                  value: '${learner.accuracyPercent}%',
                  color: AppPalette.purple,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePanel(
      padding: EdgeInsets.all(12.dsp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.mono(10, height: 14)),
          SizedBox(height: 4.dsp),
          Text(
            value,
            style: AppText.mono(
              15,
              height: 22,
              weight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Track icon, name, completion bar; tappable.
class TrackProgressRow extends StatelessWidget {
  final TrackCompletion item;
  final VoidCallback onTap;

  const TrackProgressRow({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final track = item.overview.track;
    final style = TrackStyle.of(track.id);
    final percent = (item.completion * 100).round();
    final radius = BorderRadius.circular(8.dsp);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.dsp),
      child: Material(
        color: AppPalette.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppPalette.surfaceHigh),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.dsp),
            child: Row(
              children: [
                TrackIconBox(trackId: track.id),
                SizedBox(width: 12.dsp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              track.name.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.sans(
                                14,
                                height: 20,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: AppText.mono(
                              12,
                              height: 16,
                              color: style.percentColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.dsp),
                      AppProgressBar(
                        value: item.completion,
                        color: style.barColor,
                      ),
                    ],
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
