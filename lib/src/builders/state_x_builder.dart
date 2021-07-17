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
    this.includeLoading = true,
  });

  @override
  _StateXBuilderState createState() => _StateXBuilderState();
}

class _StateXBuilderState extends State<StateXBuilder> {
  late Widget Function(BuildContext cxt) _currentBuilder;
  //StateXType? _lastStateType;
  bool _inLoading = false;
  void _observer(StateXType type, Object? state, int ownerCode) {
    if (widget.states != null && type == StateXType.isState) {
      var contains =
          widget.states!.where((rx) => rx.hashCode == ownerCode).isNotEmpty;
      if (!contains) {
        return;
      }
    }

    var _changeState = true;
    var _builder;
    switch (type) {
      case StateXType.isLoading:
        _changeState = widget.includeLoading;
        var status = (state as StateXLoading).inLoading;
        _inLoading = status;
        if (status) {
          _builder = (ctx) =>
              widget.builder(context, FluxSnapshot<bool>(type, status));
        } else {
          _builder = (ctx) =>
              widget.builder(context, FluxSnapshot(StateXType.isState, null));
        }
        break;
      case StateXType.isError:
        _changeState = true;
        _builder = (ctx) => widget.builder(
            context, FluxSnapshot<Exception?>(type, state as Exception?));
        break;
      default:
        if (_inLoading) {
          _changeState = false;
        }
        _builder = (ctx) => widget.builder(context, FluxSnapshot(type, null));
    }

    if (_changeState) {
      setState(() {
        _currentBuilder = _builder;
      });
    }
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
