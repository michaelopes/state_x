import '../utils/state_x_global_observer.dart';

enum StateXType { isLoading, isState, isError }

class StateXLoading {
  final bool inLoading;

  StateXLoading(this.inLoading);
}

typedef StateXObserver = Function(
    StateXType type, Object? state, int ownerCode);

typedef StateXNotifierObserver = Function(Object? state, int key,
    {String? observerKey});

class StateXStore {
  Exception? error;
  bool inLoading = false;

  final Map<String, StateXObserver> _observers = <String, StateXObserver>{};
  StateXNotifierObserver get stateXObserver => _stateXObserver;

  _stateXObserver(Object? state, int key, {String? observerKey}) {
    StateXType type = StateXType.isState;
    if (state is StateXLoading) {
      type = StateXType.isLoading;
      inLoading = state.inLoading;
    } else if (state is Exception) {
      type = StateXType.isError;
      error = state;
    } else {
      error = null;
      inLoading = false;
    }

    if (_observers.isNotEmpty) {
      if (observerKey != null && _observers[observerKey] != null) {
        _observers[observerKey]!(type, state, key);
      } else {
        for (var obs in _observers.entries) {
          obs.value(type, state, key);
        }
      }
    }
    StateXGlobalObserver.dispatch(type, state);
  }

  void setLoading(bool status, {String? key}) {
    _stateXObserver(StateXLoading(status), status.hashCode, observerKey: key);
  }

  void setError(Exception error, {String? key}) {
    _stateXObserver(error, error.hashCode, observerKey: key);
  }

  void addObserver(StateXObserver observer, {String? key}) {
    var observerKey = (key ?? observer.hashCode.toString());
    _observers.addAll({observerKey: observer});
  }

  void removeObserver(StateXObserver observer) {
    _observers.remove(observer.hashCode.toString());
  }

  void removeObserverKey(String key) {
    _observers.remove(key);
  }

  void dispose() {
    _observers.clear();
  }
}
