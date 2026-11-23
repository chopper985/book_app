// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart' show I18n;
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:interview_practice/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/domain/usecase/profile_usecases.dart';
import 'package:interview_practice/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:interview_practice/features/profile/presentation/screens/edit_profile_screen.dart';
import '../../helpers/in_memory_avatar_datasource.dart';
import '../../helpers/test_graph.dart';

void main() {
  late TestGraph graph;
  late InMemoryAvatarLocalDataSource avatars;
  late ProfileRepositoryImpl profiles;

  setUp(() async {
    graph = await TestGraph.create();
    avatars = InMemoryAvatarLocalDataSource();
    profiles = ProfileRepositoryImpl(graph.profileLocal, avatars, graph.clock);
    await profiles.save(
      const ProfileFields(
        displayName: 'Lan',
        role: TargetRole.mobile,
        experience: ExperienceLevel.junior,
        techStack: ['dart'],
      ),
    );
  });

  EditProfileCubit newCubit() => EditProfileCubit(
        GetProfile(profiles),
        GetAvatarPath(profiles),
        StoreAvatar(profiles),
        SaveProfile(profiles),
        GetTracks(graph.catalog),
      );

  group('ProfileFields validation', () {
    test('email is optional but must look like an email', () {
      expect(ProfileFields.isValidEmail(''), isTrue);
      expect(ProfileFields.isValidEmail(' lan@mail.vn '), isTrue);
      expect(ProfileFields.isValidEmail('lan@mail'), isFalse);
      expect(ProfileFields.isValidEmail('lan mail.vn'), isFalse);
    });

    test('phone is optional, 9 to 15 digits with separators', () {
      expect(ProfileFields.isValidPhone(''), isTrue);
      expect(ProfileFields.isValidPhone('0912 345 678'), isTrue);
      expect(ProfileFields.isValidPhone('+84-912.345.678'), isTrue);
      expect(ProfileFields.isValidPhone('12345'), isFalse);
      expect(ProfileFields.isValidPhone('0912abc678'), isFalse);
      expect(ProfileFields.isValidPhone('1' * 16), isFalse);
    });

    test('name is required', () {
      expect(ProfileFields.isValidName('   '), isFalse);
      expect(ProfileFields.isValidName('Lan'), isTrue);
    });
  });

  test('loads saved values and is not dirty until something changes', () async {
    final cubit = newCubit();
    await cubit.load();
    expect(cubit.state.fields?.displayName, 'Lan');
    expect(cubit.state.tracks, isNotEmpty);
    expect(cubit.state.isDirty, isFalse);
    expect(cubit.state.canSave, isFalse);

    cubit.setEmail('x');
    expect(cubit.state.isDirty, isTrue);
    expect(cubit.state.canSave, isFalse, reason: 'invalid email');
    cubit.setEmail('');
    expect(cubit.state.isDirty, isFalse, reason: 'blank equals unset');
    await cubit.close();
  });

  test('saves personal details, trimmed, keeping createdAt', () async {
    final created = profiles.profile!.createdAt;
    graph.clock.value = graph.clock.value.add(const Duration(days: 1));
    final cubit = newCubit();
    await cubit.load();

    cubit
      ..setName('  Lan Anh ')
      ..setEmail(' lan@mail.vn ')
      ..setPhone('0912 345 678')
      ..setBirthDate(DateTime(2001, 5, 9))
      ..selectExperience(ExperienceLevel.middle)
      ..toggleTrack('go');
    expect(cubit.state.canSave, isTrue);
    await cubit.save();

    expect(cubit.state.saved, isTrue);
    final saved = profiles.profile!;
    expect(saved.displayName, 'Lan Anh');
    expect(saved.email, 'lan@mail.vn');
    expect(saved.phone, '0912 345 678');
    expect(saved.birthDate, DateTime(2001, 5, 9));
    expect(saved.experience, ExperienceLevel.middle);
    expect(saved.techStack, ['dart', 'go']);
    expect(saved.createdAt, created);
    expect(saved.updatedAt, graph.clock.value);
    await cubit.close();
  });

  test('an empty stack cannot be saved', () async {
    final cubit = newCubit();
    await cubit.load();
    cubit.toggleTrack('dart');
    expect(cubit.state.isDirty, isTrue);
    expect(cubit.state.canSave, isFalse);
    await cubit.close();
  });

  group('avatar', () {
    test('a pick is stored only on save, replacing the old file', () async {
      var cubit = newCubit();
      await cubit.load();
      cubit.pickAvatar('/tmp/first.jpg');
      expect(cubit.state.avatarPath, '/tmp/first.jpg');
      expect(avatars.files, isEmpty, reason: 'nothing copied before save');
      await cubit.save();
      final first = profiles.profile!.avatarFileName!;
      expect(avatars.files.keys, [first]);
      await cubit.close();

      cubit = newCubit();
      await cubit.load();
      expect(cubit.state.avatarPath, '/avatars/$first');
      cubit.pickAvatar('/tmp/second.jpg');
      await cubit.save();
      final second = profiles.profile!.avatarFileName!;
      expect(second, isNot(first));
      expect(avatars.files.keys, [second], reason: 'old avatar pruned');
      await cubit.close();
    });

    test('removing deletes the stored file on save', () async {
      var cubit = newCubit();
      await cubit.load();
      cubit.pickAvatar('/tmp/first.jpg');
      await cubit.save();
      await cubit.close();

      cubit = newCubit();
      await cubit.load();
      cubit.removeAvatar();
      expect(cubit.state.avatarPath, isNull);
      expect(cubit.state.canSave, isTrue);
      await cubit.save();
      expect(profiles.profile!.avatarFileName, isNull);
      expect(avatars.files, isEmpty);
      await cubit.close();
    });

    test('discarding a pick leaves no file behind', () async {
      final cubit = newCubit();
      await cubit.load();
      cubit.pickAvatar('/tmp/first.jpg');
      await cubit.close();
      expect(avatars.files, isEmpty);
      expect(profiles.profile!.avatarFileName, isNull);
    });
  });

  testWidgets('edit screen fits a small screen at 1.3x text and validates',
      (tester) async {
    late EditProfileCubit cubit;
    await tester.runAsync(() async {
      cubit = newCubit();
      await cubit.load();
    });

    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      I18n(
        initialLocale: const Locale('vi', 'VN'),
        child: Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
              ),
              child: child!,
            ),
            home: BlocProvider.value(
              value: cubit,
              child: const EditProfileScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text(Strings.editProfileTitle.i18n), findsOneWidget);

    // Email field is the second text field.
    await tester.enterText(find.byType(TextField).at(1), 'not-an-email');
    await tester.pump();
    expect(find.text(Strings.editProfileEmailError.i18n), findsOneWidget);
    expect(cubit.state.canSave, isFalse);

    await tester.scrollUntilVisible(
      find.text(Strings.editProfileInterviewDate.i18n),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  });
}
