import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/session_info.dart';
import '../../domain/usecases/get_session_info.dart';

/// App-level holder of the signed-in user and the business, so screens do not
/// query the repository directly.
class SessionCubit extends Cubit<SessionInfo> {
  SessionCubit(this._getSessionInfo) : super(const SessionInfo.empty());

  final GetSessionInfo _getSessionInfo;

  Future<void> refresh() async {
    final Result<SessionInfo> result = await _getSessionInfo(const NoParams());
    if (result case Success<SessionInfo>(:final SessionInfo value)) {
      emit(value);
    }
  }
}
