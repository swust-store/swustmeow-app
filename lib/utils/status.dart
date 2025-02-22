enum Status {
  ok,
  fail,
  permissionRequired,
  manualCaptchaRequired,
  captchaFailed,
  notAuthorized;
}

class StatusContainer<T> {
  final Status status;
  final T? value;

  const StatusContainer(this.status, [this.value]);

  @override
  String toString() => 'status: ${status.toString()}, value: $value';
}
