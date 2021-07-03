import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      body: StateXBuilder(
        store: store,
        builder: (context, snapshot) {
          if (snapshot.type == StateXType.isLoading) {
            return Text("StateLoading ${snapshot.data}");
          } else if (snapshot.type == StateXType.isError) {
            return Text("StateError ${snapshot.data}");
          } else if (snapshot.type == StateXType.isState) {
            return Text("IsState");
          }
          return Container();
        },
      ),
    );
  }
}

void main() {
  testWidgets('State x builder state flux', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TestApp(),
    ));

    expect(find.text("IsState"), findsOneWidget);

    store.setLoading(true);
    await tester.pump();
    expect(find.text("StateLoading true"), findsOneWidget);

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
