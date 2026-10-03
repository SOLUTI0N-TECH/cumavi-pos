import 'package:bloc_test/bloc_test.dart';
import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/usecases/use_case.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/account/domain/usecases/pick_business_logo.dart';
import 'package:cumavi_pos_mobile/features/account/presentation/cubit/business_settings_cubit.dart';
import 'package:cumavi_pos_mobile/features/account/presentation/cubit/business_settings_state.dart';
import 'package:cumavi_pos_mobile/features/auth/data/datasources/in_memory_session_store.dart';
import 'package:cumavi_pos_mobile/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/entities/business_profile.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/usecases/save_business_profile.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/usecases/sign_out.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/services/demo_photo_capturer.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/services/photo_capturer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySessionStore session;
  late MockAuthRepository repository;

  setUp(() {
    session = InMemorySessionStore();
    repository = MockAuthRepository(
      sessionRepository: session,
      latency: Duration.zero,
    );
  });

  group('SignOut', () {
    test('removes the user but keeps the store on this device', () async {
      final Result<void> result = await SignOut(repository)(const NoParams());

      expect(result, isA<Success<void>>());
      expect(session.isSignedIn, isFalse);
      expect(session.currentBusiness, InMemorySessionStore.demoBusiness);
    });
  });

  group('SaveBusinessProfile NIT', () {
    BusinessProfileDraft draft({String? taxId}) => BusinessProfileDraft(
      name: 'Illimani Store',
      type: BusinessType.clothingAndFootwear,
      department: BoliviaDepartment.santaCruz,
      taxId: taxId,
    );

    test('keeps the current NIT when the draft has none', () async {
      await SaveBusinessProfile(repository)(draft());

      expect(session.currentBusiness?.taxId, '1020304050');
      expect(session.currentBusiness?.department, BoliviaDepartment.santaCruz);
    });

    test('replaces or removes the NIT', () async {
      await SaveBusinessProfile(repository)(draft(taxId: '998877'));
      expect(session.currentBusiness?.taxId, '998877');

      await SaveBusinessProfile(repository)(draft(taxId: ''));
      expect(session.currentBusiness?.taxId, isNull);
    });

    test('rejects a NIT with letters or too short', () async {
      for (final String taxId in <String>['12AB45', '123']) {
        final Result<BusinessProfile> result = await SaveBusinessProfile(
          repository,
        )(draft(taxId: taxId));

        expect(result.failureOrNull?.code, FailureCode.invalidTaxId);
      }
    });
  });

  group('BusinessSettingsCubit', () {
    BusinessSettingsCubit build() => BusinessSettingsCubit(
      business: InMemorySessionStore.demoBusiness,
      saveBusinessProfile: SaveBusinessProfile(repository),
      pickBusinessLogo: const PickBusinessLogo(DemoPhotoCapturer()),
    );

    test('can only save when something changed', () {
      final BusinessSettingsCubit cubit = build();
      expect(cubit.state.canSave, isFalse);

      cubit.nameChanged('Illimani Store 2');
      expect(cubit.state.canSave, isTrue);

      cubit.nameChanged('Illimani Store');
      expect(cubit.state.canSave, isFalse);
    });

    blocTest<BusinessSettingsCubit, BusinessSettingsState>(
      'saves and treats the saved data as the new original',
      build: build,
      act: (BusinessSettingsCubit cubit) async {
        cubit
          ..nameChanged('Tienda Illimani')
          ..taxIdChanged('55667788');
        await cubit.save();
      },
      verify: (BusinessSettingsCubit cubit) {
        expect(cubit.state.status, BusinessSettingsStatus.saved);
        expect(cubit.state.original.name, 'Tienda Illimani');
        expect(cubit.state.hasChanges, isFalse);
        expect(session.currentBusiness?.taxId, '55667788');
      },
    );

    blocTest<BusinessSettingsCubit, BusinessSettingsState>(
      'uses the picked photo as the logo',
      build: build,
      act: (BusinessSettingsCubit cubit) => cubit.pickLogo(PhotoSource.gallery),
      verify: (BusinessSettingsCubit cubit) {
        expect(cubit.state.logoPath, isNotNull);
        expect(cubit.state.canSave, isTrue);
      },
    );
  });
}
