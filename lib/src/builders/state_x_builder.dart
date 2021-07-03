import 'package:flutter/material.dart';
import '../stores/state_x_store.dart';

typedef CallBuilder = Widget Function(
    BuildContext context, FluxSnapshot snapshot);

class FluxSnapshot<T> {
  final StateXType type;
  final T data;

  FluxSnapshot(this.type, this.data);
}

class StateXBuilder extends StatefulWidget {
  final StateXStore store;
  final CallBuilder builder;
  final List<Object>? states;
  final bool includeLoading;
  const StateXBuilder({
    required this.store,
    required this.builder,
    this.states,
    this.includeLoading = false,
  });

  @override
  _StateXBuilderState createState() => _StateXBuilderState();
}

class _StateXBuilderState extends State<StateXBuilder> {
  late Widget Function(BuildContext cxt) _currentBuilder;
  StateXType? _lastStateType;
  void _observer(StateXType type, Object? state, int ownerCode) {
    if (widget.states != null &&
        (type == StateXType.isState ||
            (!widget.includeLoading && StateXType.isLoading == type))) {
      var contains =
          widget.states!.where((rx) => rx.hashCode == ownerCode).isNotEmpty;
      if (!contains) {
        return;
      }
    }

    setState(() {
      switch (type) {
        case StateXType.isLoading:
          var status = (state as StateXLoading).inLoading;
          if (status) {
            _currentBuilder = (ctx) =>
                widget.builder(context, FluxSnapshot<bool>(type, status));
          } else if (_lastStateType == StateXType.isLoading) {
            _currentBuilder = (ctx) =>
                widget.builder(context, FluxSnapshot(StateXType.isState, null));
          }
          break;
        case StateXType.isError:
          _currentBuilder = (ctx) => widget.builder(
              context, FluxSnapshot<Exception?>(type, state as Exception?));
          break;
        default:
          _currentBuilder =
              (ctx) => widget.builder(context, FluxSnapshot(type, null));
      }
    });
    _lastStateType = type;
  }

  @override
  void initState() {
    _currentBuilder =
        (ctx) => widget.builder(ctx, FluxSnapshot(StateXType.isState, null));

    widget.store.addObserver(_observer);
    super.initState();
  }

  @override
  void dispose() {
    widget.store.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _currentBuilder(context);
  }
}
