import 'package:state_x/src/stores/state_x_store.dart';

typedef StateObsListener = Function(StateXType type, Object? state);

class StateXGlobalObserver {
  static StateObsListener? _listener;
  static listen(StateObsListener listener) {
    _listener = listener;
  }

  static dispatch(StateXType type, Object? state) {
    if (_listener != null) {
      _listener!(type, state);
    }
  }
}
