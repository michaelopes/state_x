import 'package:flutter_test/flutter_test.dart';
import 'package:state_x/src/stores/state_x_store.dart';
import 'package:state_x/src/utils/state_x.dart';

class StoreTest extends StateXStore {
  late final state = StateX.of(this)(0);
}

void main() {
  test('State x store observer add and remove', () async {
    StateXType type = StateXType.isState;
    var store = StoreTest();
    var obs = (tp, state, ownerCode) => type = tp;
    store.addObserver(obs);
    store.setLoading(true);
    expect(type == StateXType.isLoading, true);

    type = StateXType.isState;
    store.removeObserver(obs);
    store.setLoading(true);
    expect(type == StateXType.isLoading, false);
  });

  test('State x store observer change state', () async {
    var store = StoreTest();
    int stateValue = 0;
    var obs = (tp, state, ownerCode) =>
        tp == StateXType.isState ? stateValue = state : "";
    store.addObserver(obs);
    store.state.value = 20;
    expect(stateValue, 20);
  });

  test('State x store observer set error', () async {
    var store = StoreTest();
    Exception error = Exception();

    var obs =
        (tp, state, ownerCode) => tp == StateXType.isError ? error = state : "";

    store.addObserver(obs);
    store.setError(Exception("123456"));

    expect(error.toString(), "Exception: 123456");
  });
}
