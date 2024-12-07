import 'dart:async';
import 'package:flutter/widgets.dart';
import 'state_notifier.dart';

class StateObserver<T> extends StatefulWidget {
  final StateNotifier<T> notifier;
  final Widget Function(BuildContext context, T? state) builder;
  final void Function(T?)? onStateChanged;
  final Function? onError;
  final void Function()? onDone;

  StateObserver({
    required this.notifier,
    required this.builder,
    this.onStateChanged,
    this.onError,
    this.onDone,
  });

  @override
  _StateObserverState<T> createState() => _StateObserverState<T>();
}

class _StateObserverState<T> extends State<StateObserver<T>> {
  late StreamSubscription<T?> _subscription;
  late T? _currentState;

  @override
  void initState() {
    super.initState();
    _currentState = widget.notifier.stateHolder.state;

    _subscription = widget.notifier.listen(
          (state) {
        setState(() {
          _currentState = state;
        });
        if (widget.onStateChanged != null) {
          widget.onStateChanged!(state);
        }
      },
      onError: widget.onError,
      onDone: widget.onDone,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentState);
  }
}