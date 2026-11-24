// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:interview_practice/features/auth/domain/usecase/account_usecases.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/domain/usecase/profile_usecases.dart';
import 'package:interview_practice/features/profile/presentation/cubit/edit_profile_cubit.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/test_graph.dart';

void main() {
  late TestGraph graph;

  setUp(() async => graph = await TestGraph.create());

  const fields = ProfileFields(
    displayName: 'Lan',
    role: TargetRole.mobile,
    experience: ExperienceLevel.junior,
    techStack: ['dart'],
  );

  test('onboarding is pending only before the first profile', () async {
    expect(graph.profiles.onboardingCompleted, isFalse);
    await graph.profiles.save(fields);
    expect(graph.profiles.onboardingCompleted, isTrue);
  });

  test('a profile restored from the cloud also completes onboarding',
      () async {
    await graph.profiles.restore(
      LearnerProfile(
        fields: fields,
        createdAt: DateTime(2026, 9),
        updatedAt: DateTime(2026, 9),
      ),
    );
    expect(graph.profiles.onboardingCompleted, isTrue);
  });

  test('signing out clears the data but does not bring onboarding back',
      () async {
    await graph.profiles.save(fields);
    graph.auth.emitUser(googleUser);
    final clear = ClearLocalLearnerData(
      graph.practice,
      graph.profiles,
      graph.saved,
      graph.roadmaps,
      graph.usage,
    );
    await SignOut(graph.auth, graph.sync, clear)();

    expect(graph.profiles.hasProfile, isFalse);
    expect(graph.profiles.onboardingCompleted, isTrue);
    expect(await graph.practice.getResults(), isEmpty);
  });

  test('a profile from before the flag still skips onboarding after sign-out',
      () async {
    await graph.profileLocal.write(
      LearnerProfile(
        fields: fields,
        createdAt: DateTime(2026, 9),
        updatedAt: DateTime(2026, 9),
      ),
    );
    expect(graph.profileLocal.onboarded, isFalse);
    await graph.profiles.restore(null);
    expect(graph.profiles.onboardingCompleted, isTrue);
  });

  test('without a profile the edit screen creates a new one', () async {
    await graph.profileLocal.writeOnboarded();
    final cubit = EditProfileCubit(
      GetProfile(graph.profiles),
      GetAvatarPath(graph.profiles),
      StoreAvatar(graph.profiles),
      SaveProfile(graph.profiles),
      GetTracks(graph.catalog),
    );
    await cubit.load();
    expect(cubit.state.original, isNull);
    expect(cubit.state.fields?.displayName, '');

    cubit
      ..setName('Minh')
      ..toggleTrack('dart');
    expect(cubit.state.canSave, isTrue);
    await cubit.save();
    expect(graph.profiles.profile?.displayName, 'Minh');
    await cubit.close();
  });
}
