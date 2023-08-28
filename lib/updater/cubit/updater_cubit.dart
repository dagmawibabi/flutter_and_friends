import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shorebird_code_push/shorebird_code_push_io.dart';

part 'updater_state.dart';

class UpdaterCubit extends Cubit<UpdaterState> {
  UpdaterCubit({ShorebirdCodePush? codePush})
      : _codePush = codePush ?? ShorebirdCodePush(),
        super(const UpdaterState());

  final ShorebirdCodePush _codePush;

  Future<void> checkForUpdates() async {
    emit(state.copyWith(status: UpdaterStatus.updateCheckInProgress));
    try {
      final updateAvailable = await _codePush.isNewPatchAvailableForDownload();
      emit(
        state.copyWith(
          status: UpdaterStatus.idle,
          updateAvailable: updateAvailable,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: UpdaterStatus.idle));
    }
  }

  Future<void> downloadUpdate() async {
    emit(state.copyWith(status: UpdaterStatus.downloadInProgress));
    try {
      await _codePush.downloadUpdateIfAvailable();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    try {
      final isNewPatchReadyToInstall =
          await _codePush.isNewPatchReadyToInstall();
      emit(
        state.copyWith(
          isNewPatchReadyToInstall: isNewPatchReadyToInstall,
          status: UpdaterStatus.idle,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          isNewPatchReadyToInstall: false,
          status: UpdaterStatus.idle,
        ),
      );
    }
  }
}