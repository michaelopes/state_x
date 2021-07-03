import 'package:flutter/material.dart';
import '../stores/state_x_store.dart';

typedef CallState = Widget Function();
typedef CallError = Widget Function(Exception error);
typedef CallLoading = Widget Function();

class StateXScopedBuilder extends StatefulWidget {
  final StateXStore store;
  final CallState onState;
  final CallError? onError;
  final CallLoading? onLoading;
  final List<Object>? states;

  StateXScopedBuilder({
    required this.store,
    required this.onState,
    this.states,
    this.onLoading,
    this.onError,
  });

  @override
  _State createState() => _State();
}

class _State extends State<StateXScopedBuilder> {
  Widget _currentResult = Container();
  StateXType? _lastStateType;
  void _observer(StateXType type, Object? state, int ownerCode) {
    if (widget.states != null &&
        (type == StateXType.isState ||
            (widget.onLoading == null && StateXType.isLoading == type))) {
      var contains =
          widget.states!.where((rx) => rx.hashCode == ownerCode).isNotEmpty;
      if (!contains) {
        return;
      }
    }
    if (type == StateXType.isLoading) {
      var status = (state as StateXLoading).inLoading;

      if (widget.onLoading != null && status) {
        setState(() {
          _currentResult = widget.onLoading!();
        });
      } else if (!status) {
        if (_lastStateType == StateXType.isLoading) {
          setState(() {
            _currentResult = widget.onState();
          });
        }
      }
    } else if (type == StateXType.isError) {
      if (widget.onError != null) {
        setState(() {
          _currentResult = widget.onError!(state as Exception);
        });
      } else {
        setState(() {
          _currentResult = widget.onState();
        });
      }
    } else {
      setState(() {
        _currentResult = widget.onState();
      });
    }
    _lastStateType = type;
  }

  @override
  void initState() {
    _currentResult = widget.onState();
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
    return _currentResult;
  }
}
