import 'package:state_x/src/stores/state_x_store.dart';

abstract class Stated<State extends Object?> {
  set value(State value);
  State get value;
  int get key;
}

class _StateX<State extends Object?> extends Stated<State> {
  late State _stateXState;
  late void Function(Object? value, int key) observer;

  _StateX(State state, this.observer) {
    _stateXState = state;
  }

  set value(State value) {
    _stateXState = value;
    this.observer(value, this.hashCode);
  }

  State get value => _stateXState;

  int get ownerCode => this.hashCode;

  @override
  int get key => ownerCode;
}

typedef NewStateX = _StateX<T> Function<T>(T state);

class StateX {
  static NewStateX of(StateXStore store) {
    return <T>(T state) => _StateX<T>(state, store.stateXObserver);
  }
}
