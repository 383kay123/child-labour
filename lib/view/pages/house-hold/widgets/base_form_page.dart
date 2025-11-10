import 'package:flutter/material.dart';
import 'package:human_rights_monitor/view/pages/house-hold/state/household_survey_state.dart';
import 'package:human_rights_monitor/view/pages/house-hold/providers/household_provider.dart';

abstract class BaseFormPage extends StatefulWidget {
  final String title;
  final bool showAppBar;
  final bool showNavigationButtons;
  final Widget child;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool isLastPage;
  final bool isFirstPage;

  const BaseFormPage({
    Key? key,
    required this.title,
    this.showAppBar = true,
    this.showNavigationButtons = true,
    required this.child,
    this.onNext,
    this.onPrevious,
    this.isLastPage = false,
    this.isFirstPage = false,
  }) : super(key: key);

  @override
  BaseFormPageState createState();
}

abstract class BaseFormPageState<T extends BaseFormPage> extends State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final HouseholdSurveyState surveyState;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    surveyState = HouseholdProvider.of(context);
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  void saveForm() {
    formKey.currentState?.save();
  }

  void setLoading(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(widget.title),
              centerTitle: true,
              elevation: 0,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: widget.child,
                      ),
                    ),
                    if (widget.showNavigationButtons) _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!widget.isFirstPage)
            ElevatedButton(
              onPressed: widget.onPrevious,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Previous'),
            )
          else
            const SizedBox(width: 100), // For consistent spacing
          
          ElevatedButton(
            onPressed: widget.onNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(widget.isLastPage ? 'Submit' : 'Next'),
          ),
        ],
      ),
    );
  }
}
