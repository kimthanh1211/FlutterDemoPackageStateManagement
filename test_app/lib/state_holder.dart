class StateHolder<T> {
  T? _state;

  StateHolder(this._state);

  T? get state => _state;

  set state(T? newState) {
    _state = newState;
  }
}