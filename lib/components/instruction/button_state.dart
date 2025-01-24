enum ButtonState { ok, dissatisfied, error, loading }

class ButtonStateContainer {
  final ButtonState state;
  final String? message;

  const ButtonStateContainer(this.state, [this.message]);
}
