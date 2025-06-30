import 'package:flutter/cupertino.dart';

class SwitchCaseWidget<T> extends StatelessWidget {
  final Widget? Function(T? t) stateBuilder;
  final T activeState;

  const SwitchCaseWidget({
    super.key,
    required this.stateBuilder,
    required this.activeState,
  });

  @override
  Widget build(BuildContext context) {
    return stateBuilder(activeState) ?? const SizedBox.shrink();
  }
}

abstract class WidgetSwitchCase {}

class LoadingWidgetCase extends WidgetSwitchCase {}

class ErrorWidgetCase extends WidgetSwitchCase {}

class StudentDetailsLoadedCase extends WidgetSwitchCase {}

class StudentSuggestionListLoadedCase extends WidgetSwitchCase {}

class StudentImportantDatesLoadedCase extends WidgetSwitchCase {}

class StudentArchiveLoadedCase extends WidgetSwitchCase {}

class TeacherLoadedCase extends WidgetSwitchCase {}

class AdminLoadedCase extends WidgetSwitchCase {}
