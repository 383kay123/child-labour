import 'package:flutter/material.dart';
import '../state/household_survey_state.dart';

class HouseholdProvider extends InheritedNotifier<HouseholdSurveyState> {
  const HouseholdProvider({
    Key? key,
    required HouseholdSurveyState state,
    required Widget child,
  }) : super(key: key, notifier: state, child: child);

  static HouseholdSurveyState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HouseholdProvider>()!.notifier!;
  }

  static HouseholdSurveyState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HouseholdProvider>()?.notifier;
  }

  @override
  bool updateShouldNotify(covariant HouseholdProvider oldWidget) {
    return true;
  }
}
