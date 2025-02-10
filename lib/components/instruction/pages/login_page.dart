import 'package:flutter/material.dart';

import '../button_state.dart';

abstract class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.sc,
    required this.onStateChange,
    required this.onComplete,
    required this.onlyThis,
  });

  final ButtonStateContainer sc;
  final Function(ButtonStateContainer sc) onStateChange;
  final Function() onComplete;
  final bool onlyThis;
}