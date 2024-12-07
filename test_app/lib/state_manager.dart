import 'state_holder.dart';
import 'state_notifier.dart';

class StateManager<T> {
  final StateHolder<T?> _stateHolder;
  late final StateNotifier<T?> _stateNotifier;

  StateManager(T? initialState)
      : _stateHolder = StateHolder<T?>(initialState) {
    _stateNotifier = StateNotifier<T?>(_stateHolder, initialState);
  }

  T? get state => _stateHolder.state;

  //updateState
  set state(T? newState) {
    _stateNotifier.updateState(newState);
  }

  T? getData() {
    return _stateNotifier.getData();
  }

  StateNotifier<T?> get notifier => _stateNotifier;

  void dispose() {
    _stateNotifier.dispose();
  }

  Future<void> updateStateAsynchronous(Future<T> future) async {
    try {
      await _stateNotifier.updateStateAsync(future);
    } catch (e) {
      // Handle the error if any occurs during async operation
      print('Error: $e');
    }
  }

  // Reset the state to the initial value
  void resetState() {
    _stateNotifier.resetState();
  }

  // Delete the state (set it to null)
  void deleteState() {
    _stateNotifier.deleteState();
  }
}