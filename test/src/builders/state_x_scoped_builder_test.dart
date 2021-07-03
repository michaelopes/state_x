import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_x/src/stores/state_x_store.dart';
import 'package:state_x/state_x.dart';

class StoreTest extends StateXStore {
  late final state = StateX.of(this)(0);
}

var store = StoreTest();

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StateXScopedBuilder(
        store: store,
        onState: () => Text("IsState"),
        onError: (error) => Text("StateError $error"),
        onLoading: () => Text("StateLoading"),
      ),
    );
  }
}

void main() {
  testWidgets('State x scoped builder state flux', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TestApp(),
    ));

    expect(find.text("IsState"), findsOneWidget);

    store.setLoading(true);
    await tester.pump();
    expect(find.text("StateLoading"), findsOneWidget);

    store.setLoading(false);
    await tester.pump();
    expect(find.text("IsState"), findsOneWidget);

    store.setError(Exception("123456"));
    await tester.pump();
    expect(find.text("StateError Exception: 123456"), findsOneWidget);

    store.state.value = 20;
    await tester.pump();
    expect(find.text("IsState"), findsOneWidget);
  });
}
