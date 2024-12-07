import 'dart:async';
import 'state_holder.dart';

class StateNotifier<T> {
  final _stateController = StreamController<T?>.broadcast();
  final StateHolder<T?> _stateHolder;
  final T? _initialState;

  StateNotifier(this._stateHolder, T? initialState) : _initialState = initialState;

  StateHolder<T?> get stateHolder => _stateHolder;

  Stream<T?> get stateStream => _stateController.stream;

  T? getData() {
    return _stateHolder.state;
  }

  StreamSubscription<T?> listen(
      void Function(T?) onData, {
        Function? onError,
        void Function()? onDone,
        bool cancelOnError = true,
      }) {
    return _stateController.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void updateState(T newState) {
    if (_stateHolder.state != newState) {
      _stateHolder.state = newState;
      _stateController.add(newState);
    }
  }
  /*
  Future<void> updateStateAsync(Future<T> newStateFuture) async {
    try {
      T newState = await newStateFuture;
      if (_stateHolder.state != newState) {
        _stateHolder.state = newState;
        _stateController.add(newState);
      }
    } catch (e) {
      _stateController.addError(e);  // Notify listeners of the error if any
    }
  }
   */
  Future<void> updateStateAsync(Future<T> newStateFuture) async {
    try {
      T newState = await newStateFuture;
      if (_stateHolder.state != newState) {
        _stateHolder.state = newState;
        _stateController.add(newState);
      }
    } catch (e) {
      _stateController.addError(e);  // Notify listeners of the error if any
    }
  }

  void resetState() {
    if (_stateHolder.state != _initialState) {
      _stateHolder.state = _initialState;
      _stateController.add(_initialState); // Notify listeners
    }
  }

  void deleteState() {
    if (_stateHolder.state != null) {
      _stateHolder.state = null;
      _stateController.add(null); // Notify listeners
    }
  }

  void dispose() {
    _stateController.close();
  }
}