import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/farm identification/sensitization_page.dart';
import 'package:human_rights_monitor/controller/db/db_tables/helpers/household_db_helper.dart';
import 'package:human_rights_monitor/controller/models/consent_model.dart';
import 'package:human_rights_monitor/controller/models/farmeridentification_model.dart';
import 'package:human_rights_monitor/controller/models/household_models.dart' show CoverPageData;
import 'package:human_rights_monitor/controller/models/sensitization_model.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/children_household_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/end_of_collection_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/farmer_identification.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/remediation_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/sensitization_questions_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/combined_farmer_identification.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/consent_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/cover_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'child_details_page.dart';

class SurveyState {
  bool isInterviewTimeRecorded = false;
  Position? currentPosition;
  String locationStatus = 'Not recorded';
  DateTime? interviewStartTime;
  String timeStatus = 'Not recorded';
  bool isGettingLocation = false;

  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60)
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    if (difference.inHours < 24)
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  }
}

class HouseHold extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onNext;

  const HouseHold({
    Key? key,
    this.onComplete,
    this.onNext,
  }) : super(key: key);

  @override
  State<HouseHold> createState() => _HouseHoldState();
}

class _HouseHoldState extends State<HouseHold> {
  final _surveyState = SurveyState();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final PageController _pageController;
  int _currentPageIndex = 0;
  final GlobalKey<State<ChildDetailsPage>> _childDetailsPageKey = GlobalKey();
  final GlobalKey<ConsentPageState> _consentPageKey =
      GlobalKey<ConsentPageState>();
  final GlobalKey<FarmerIdentification1PageState> _farmerPageKey =
      GlobalKey<FarmerIdentification1PageState>();
  final GlobalKey<CombinedFarmIdentificationPageState> _combinedPageKey =
      GlobalKey<CombinedFarmIdentificationPageState>();
  final GlobalKey<State<SensitizationQuestionsPage>>
      _sensitizationQuestionsKey = GlobalKey();
  final GlobalKey<RemediationPageState> _remediationPageKey =
      GlobalKey<RemediationPageState>();
  final GlobalKey<State<SensitizationPage>> _sensitizationPageKey =
      GlobalKey<State<SensitizationPage>>();
  final GlobalKey<ChildrenHouseholdPageState> _childrenHouseholdKey =
      GlobalKey<ChildrenHouseholdPageState>();
  int _combinedPageSubIndex = 0;
  final int _totalPages = 10;
  final int _totalCombinedSubPages = 4;

  // Form keys for each page that needs validation
  final List<GlobalKey<FormState>> _pageKeys = List.generate(
    10, // Total number of pages
    (index) => GlobalKey<FormState>(),
  );

  bool _isSubmitted = false;
  bool _isSensitizationChecked = false;
  bool _isSaving = false;

  bool get _isOnCombinedPage => _currentPageIndex == 3;

  double get _progress => (_currentPageIndex + 1) / _totalPages;

  CoverPageData _coverData = CoverPageData.empty();
  ConsentData? _consentData;
  late FarmerIdentificationData _farmerData;
  String? _currentFarmIdentificationId;

  int _currentChildNumber = 1;
  int _totalChildren5To17 = 0;
  List<dynamic> _childrenDetails = [];
  bool _showChildDetailsPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
    _initFarmerData();
  }

  void _initFarmerData() {
    _farmerData = FarmerIdentificationData(
      ghanaCardNumberController: TextEditingController(),
      idNumberController: TextEditingController(),
      contactNumberController: TextEditingController(),
      childrenCountController: TextEditingController(),
      noConsentReasonController: TextEditingController(),
    );
  }

  void _resetCoverData() {
    setState(() {
      _coverData = CoverPageData.empty();
    });
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    try {
      setState(() {
        _surveyState.isGettingLocation = true;
        _surveyState.locationStatus = 'Getting location...';
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _surveyState.locationStatus = 'Location services are disabled';
          _surveyState.isGettingLocation = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Please enable location services to continue'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'SETTINGS',
                textColor: Colors.white,
                onPressed: () => Geolocator.openLocationSettings(),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _surveyState.locationStatus = 'Location permissions are denied';
            _surveyState.isGettingLocation = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Location permission is required to continue. Please grant permission.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _surveyState.locationStatus =
              'Location permissions are permanently denied';
          _surveyState.isGettingLocation = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Location permissions are permanently denied. Please enable them in app settings.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'SETTINGS',
                textColor: Colors.white,
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (mounted) {
        setState(() {
          _surveyState.currentPosition = position;
          _surveyState.locationStatus = 'Location captured';
          _surveyState.isGettingLocation = false;

          final updatedConsentData = _consentData?.copyWith(
            currentPosition: position,
            locationStatus:
                'Location captured (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})',
          );

          _consentData = updatedConsentData;
        });

        _onConsentDataChanged(_consentData!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location captured! Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
            ),
            backgroundColor: Colors.green,
            // duration: const Duration(seconds: 3)
          ),
        );
      }
    } on TimeoutException {
      setState(() {
        _surveyState.locationStatus = 'Location request timed out';
        _surveyState.isGettingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location request timed out. Please try again in an open area.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _surveyState.locationStatus = 'Error: ${e.toString()}';
        _surveyState.isGettingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _handleCombinedPageNavigation() async {
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    debugPrint('=== COMBINED PAGE NAVIGATION ===');
    debugPrint('Current sub-page index: $_combinedPageSubIndex');
    debugPrint('Total sub-pages: $_totalCombinedSubPages');

    final combinedPageState = _combinedPageKey.currentState;

    if (combinedPageState == null || !mounted) {
      debugPrint(
          'ERROR: Combined page state is null or widget is not mounted!');

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      final retryState = _combinedPageKey.currentState;
      if (retryState == null || !mounted) {
        debugPrint(
            'ERROR: Still unable to get combined page state after retry');
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Form is not ready. Please try again in a moment.'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
        }
        return;
      }

      await _handleCombinedPageNavigation();
      return;
    }

    debugPrint('Validating current sub-page...');
    bool isValid = false;
    try {
      isValid = combinedPageState.validateCurrentPage();
      debugPrint('Validation result: $isValid');
    } catch (e, stackTrace) {
      debugPrint('Error during validation: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Validation error. Please check your input.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
      }
      return;
    }

    if (!isValid) {
      final errors = combinedPageState.getCurrentPageErrors();
      void _showErrorSnackBar(String message) {
        if (!mounted) return;

        // Clear any existing snackbars
        ScaffoldMessenger.of(context).clearSnackBars();

        // Show the new snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (errors.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errors.first),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return;
    }

    if (_combinedPageSubIndex < _totalCombinedSubPages - 1) {
      debugPrint('Moving to next sub-page: ${_combinedPageSubIndex + 1}');
      setState(() {
        _combinedPageSubIndex++;
      });

      if (combinedPageState.mounted &&
          combinedPageState.pageController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (combinedPageState.mounted &&
              combinedPageState.pageController.hasClients) {
            try {
              combinedPageState.pageController.animateToPage(
                _combinedPageSubIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } catch (e) {
              debugPrint('Error animating to page: $e');
            }
          }
        });
      }
    } else {
      debugPrint('Last sub-page reached, moving to next main page');
      if (mounted) {
        _pageController.animateToPage(
          4,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _recordInterviewTime() {
    final now = DateTime.now();
    setState(() {
      _surveyState.interviewStartTime = now;
      _surveyState.timeStatus = 'Started at ${_surveyState.formatTime(now)}';

      final updatedConsentData = _consentData?.copyWith(
        interviewStartTime: now,
        timeStatus: 'Started at ${_surveyState.formatTime(now)}',
      );

      _consentData = updatedConsentData;
    });
  }

  // Cover page data saving removed - always return true since validation is handled elsewhere
  void _onConsentDataChanged(ConsentData newData) {
    // Update the consent data in the state
    setState(() {
      _consentData = newData;
    });
    debugPrint('Consent data updated: ${newData.consentGiven}');
  }

  void _onFarmerDataChanged(FarmerIdentificationData newData) {
    setState(() {
      _farmerData = newData;
      _currentFarmIdentificationId = newData.id?.toString();
    });
  }

  void _navigateToNextPage() {
    if (!mounted) return;

    final nextPage = _currentPageIndex + 1;
    if (nextPage < _totalPages) {
      if (_pageController.hasClients) {
        _pageController
            .animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
            .then((_) {
          if (mounted) {
            setState(() {
              _currentPageIndex = nextPage;
              debugPrint('🔄 Updated _currentPageIndex to: $_currentPageIndex');
            });
          }
        });
      }
    }
  }

  void _onPrevious() {
    if (!mounted) return;

    try {
      if (_isOnCombinedPage && _combinedPageSubIndex > 0) {
        final combinedPageState = _combinedPageKey.currentState;
        if (combinedPageState != null && combinedPageState.mounted) {
          if (combinedPageState.pageController.hasClients) {
            setState(() {
              _combinedPageSubIndex--;
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              try {
                if (combinedPageState.mounted &&
                    combinedPageState.pageController.hasClients) {
                  combinedPageState.pageController.animateToPage(
                    _combinedPageSubIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              } catch (e) {
                debugPrint('Error animating combined page: $e');
              }
            });
          }
        }
      } else if (_currentPageIndex > 0) {
        final previousPageIndex = _currentPageIndex - 1;
        if (_pageController.hasClients) {
          _pageController
              .animateToPage(
            previousPageIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
              .catchError((error) {
            debugPrint('Error navigating to previous page: $error');
            if (mounted) {
              _showErrorSnackBar('Error navigating to previous page');
            }
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _onPrevious: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        _showErrorSnackBar('Error navigating to previous page');
      }
    }
  }

  String _getPageTitle(int index) {
    if (index == 3 && _isOnCombinedPage) {
      final subPageTitles = [
        'Visit Information',
        'Owner Identification',
        'Workers in Farm',
        'Adults Information'
      ];
      return 'Farm Details - ${subPageTitles[_combinedPageSubIndex]} (${_combinedPageSubIndex + 1}/4)';
    }

    final titles = [
      'Cover Page',
      'Consent Form',
      'Farmer Identification',
      'Farm Details',
      'Children in Household',
      'Child $_currentChildNumber of $_totalChildren5To17 Details',
      'Remediation',
      'Sensitization',
      'Sensitization Questions',
      'End of Collection'
    ];

    if (index >= 0 && index < titles.length) {
      return titles[index];
    }
    return 'Household Survey';
  }

  bool _validateConsentData() {
    if (_consentPageKey.currentState != null) {
      final validationError = _consentPageKey.currentState!.validateForm();
      if (validationError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validationError),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
        return false;
      }
      return true;
    }
    return false;
  }

  Future<bool> _validateChildDetailsPage() async {
    // Always return true to bypass validation
    return true;
  }

  bool _validateSensitizationPage() {
    try {
      // Check if the checkbox is checked
      if (!_isSensitizationChecked) {
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Error in _validateSensitizationPage: $e');
      if (mounted) {
        _showErrorSnackBar('Error validating sensitization');
      }
      return false;
    }
  }

  bool _validateSensitizationQuestionsPage() {
    final state = _sensitizationQuestionsKey.currentState
        as SensitizationQuestionsPageState?;
    if (state == null) return false;
    return state.validateForm(silent: true);
  }

  bool _validateRemediationPage() {
    final state = _remediationPageKey.currentState;
    if (state == null) return false;

    // Check if school fees question is answered
    if (state.hasSchoolFees == null) {
      _showErrorSnackBar('Please answer the school fees question');
      return false;
    }

    // If school fees is yes, at least one support option must be selected
    if (state.hasSchoolFees == true &&
        !state.childProtectionEducation &&
        !state.schoolKitsSupport &&
        !state.igaSupport &&
        !state.otherSupport) {
      _showErrorSnackBar('Please select at least one support option');
      return false;
    }

    // If other support is selected, the text field must not be empty
    if (state.otherSupport && state.otherSupportText.trim().isEmpty) {
      _showErrorSnackBar('Please specify the other support needed');
      return false;
    }

    return true;
  }

  void _logCurrentState(int currentPage) {
    debugPrint('=== CURRENT FORM STATE ===');
    debugPrint('Current Page: $currentPage');

    if (_childrenDetails.isNotEmpty &&
        _currentChildNumber > 0 &&
        _currentChildNumber <= _childrenDetails.length) {
      final childData = _childrenDetails[_currentChildNumber - 1];
      debugPrint('Child ${_currentChildNumber} Details:');
      debugPrint('- Name: ${childData.childName}');
      debugPrint('- Surname: ${childData.surname}');
      debugPrint('- Gender: ${childData.gender}');
      debugPrint('- Date of Birth: ${childData.dateOfBirth}');
      debugPrint('- Worked on Cocoa Farm: ${childData.workedOnCocoaFarm}');
      debugPrint('- Work Frequency: ${childData.workFrequency}');
      debugPrint('- School Enrollment: ${childData.isEnrolledInSchool}');
    } else {
      debugPrint(
          'No child data available for current child number: $_currentChildNumber');
    }

    debugPrint('Sensitization Acknowledged: $_isSensitizationChecked');
    debugPrint('==========================');
  }

  void _showErrorSnackBar(String message) {
    try {
      if (!mounted) return;

      // Ensure we have a valid context with Scaffold
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      if (scaffoldMessenger == null) {
        debugPrint('Warning: No ScaffoldMessenger found for context');
        return;
      }

      // Clear any existing snackbars
      scaffoldMessenger.clearSnackBars();

      // Show the new snackbar in the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        } catch (e) {
          debugPrint('Error showing snackbar: $e');
          // Fallback to printing the error if we can't show a snackbar
          debugPrint('Error: $message');
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Error in _showErrorSnackBar: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _onNext() async {
    if (!mounted) return;

    try {
      final currentPage = _pageController.positions.isNotEmpty
          ? _pageController.page?.round() ?? _currentPageIndex
          : _currentPageIndex;

      // Log current state before validation
      _logCurrentState(currentPage);

      debugPrint('=== NAVIGATION REQUEST ===');
      debugPrint('Current page: $currentPage');
      debugPrint('Is on combined page: $_isOnCombinedPage');
      debugPrint('Combined sub-page index: $_combinedPageSubIndex');
      debugPrint('Current children 5-17: $_totalChildren5To17');
      debugPrint(
          'Children count controller text: ${_farmerData.childrenCountController.text}');

      bool canProceed = true;
      String? errorMessage;

      switch (currentPage) {
        case 0:
          debugPrint('🔄 Processing cover page (page 0)');
          try {
            canProceed = true;
            if (!mounted) {
              debugPrint('  - Widget not mounted, returning early');
              return;
            }
            errorMessage =
                'Please complete all required fields on the cover page';
          } catch (e, stackTrace) {
            debugPrint('❌ Error in cover page save: $e');
            debugPrint('Stack trace: $stackTrace');
            canProceed = false;
            errorMessage = 'Error saving cover page data';
          }
          break;

        case 1:
          canProceed = _validateConsentData();
          errorMessage =
              'Please complete all required fields on the consent form';
          break;

        case 2:
          try {
            if (_farmerPageKey.currentState != null) {
              final form = _farmerPageKey.currentState!.formKey.currentState;
              if (form != null) {
                form.save();
              }
              canProceed = _farmerPageKey.currentState!.validateForm();
              if (!canProceed) {
                final firstError = _farmerPageKey
                    .currentState!.validationErrors.values.firstOrNull;
                errorMessage = firstError ??
                    'Please complete all required fields in the farmer identification form';
              }
            } else {
              canProceed = false;
              errorMessage = 'Validation not available';
            }
          } catch (e) {
            debugPrint('Error validating farmer form: $e');
            canProceed = false;
            errorMessage = 'Error validating form';
          }
          break;

        case 3:
          try {
            await _handleCombinedPageNavigation();
            return;
          } catch (e) {
            debugPrint('Error in combined page navigation: $e');
            _showErrorSnackBar('Error navigating to next page');
            return;
          }

        case 4:
          try {
            final childrenCount =
                int.tryParse(_farmerData.childrenCountController.text) ?? 0;
            if (mounted) {
              setState(() {
                _totalChildren5To17 = childrenCount;
                _currentChildNumber = 1;
                _childrenDetails = [];
              });
            }
            debugPrint('Updated children 5-17 to: $_totalChildren5To17');
            canProceed = true;
          } catch (e) {
            debugPrint('Error updating children count: $e');
            canProceed = false;
            errorMessage = 'Error updating children count';
          }
          break;

        case 5:
          // Child Details page - directly navigate to remediation page
          debugPrint('Child details page - navigating to remediation page');
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              6, // Remediation page index
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            _currentPageIndex = 6;
            canProceed = true;
          } else {
            debugPrint('PageController not ready for navigation');
            canProceed = false;
          }
          break;

        case 6:
          // Remediation page - no validation needed
          canProceed = true;
          debugPrint('✅ Proceeding from remediation page to next page');
          break;

        case 7:
          try {
            canProceed = _validateSensitizationPage();
            errorMessage = 'Please acknowledge the sensitization information';
          } catch (e) {
            debugPrint('Error validating sensitization: $e');
            canProceed = false;
            errorMessage = 'Error validating sensitization';
          }
          break;

        case 7:
          try {
            canProceed = _validateSensitizationQuestionsPage();
            errorMessage =
                'Please complete all required fields on the sensitization questions page';
          } catch (e) {
            debugPrint('Error validating sensitization questions: $e');
            canProceed = false;
            errorMessage = 'Error validating sensitization questions';
          }
          break;

        case 8:
        case 9:
          canProceed = true;
          break;
      }

      if (!canProceed && errorMessage != null) {
        debugPrint('Validation failed: $errorMessage');
        if (mounted) {
          _showErrorSnackBar(errorMessage);
        }
        return;
      }

      if (!mounted) return;

      if (_currentPageIndex < _totalPages - 1) {
        // For child details page, we handle navigation in the _handleChildDetailsComplete callback
        if (_currentPageIndex != 5) {
          // 5 is the child details page index
          _navigateToNextPage();
        } else {
          // Special handling for child details page - navigation is handled in _handleChildDetailsComplete
          debugPrint(
              'Child details page - navigation will be handled by _handleChildDetailsComplete');
        }
      } else {
        _submitForm();
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _onNext: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        _showErrorSnackBar('Error processing navigation');
      }
    }
  }

  Future<void> _handleChildDetailsComplete(dynamic result) async {
    debugPrint('🔵 _handleChildDetailsComplete called');

    if (!mounted) return;

    try {
      // First update the state to reflect we're on the remediation page
      if (mounted) {
        setState(() {
          _currentPageIndex = 6; // Set to remediation page index
          debugPrint('🔄 Updated _currentPageIndex to: 6 (Remediation Page)');
        });
      }

      // Ensure the page controller is ready
      if (!_pageController.hasClients) {
        debugPrint('⚠️ PageController has no clients, waiting...');
        await Future.delayed(const Duration(milliseconds: 100));

        if (!_pageController.hasClients) {
          debugPrint('❌ PageController still has no clients after delay');
          if (mounted) {
            _showErrorSnackBar('Error navigating to remediation page');
          }
          return;
        }
      }

      // Add a small delay to ensure state is updated
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) return;

      debugPrint('🚀 Starting navigation to remediation page (index 6)');

      // Navigate to the remediation page
      await _pageController.animateToPage(
        6, // Remediation page index
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      debugPrint('✅ Navigation to remediation page completed');

      // Verify the current page after navigation
      if (mounted) {
        debugPrint('✅ Current page index after navigation: $_currentPageIndex');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _handleChildDetailsComplete: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        _showErrorSnackBar('Error navigating to next page');

        // Fallback: Try direct navigation to remediation page
        try {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(6); // Jump to remediation page
            if (mounted) {
              setState(() {
                _currentPageIndex = 6;
                debugPrint(
                    '🔄 Fallback: Set _currentPageIndex to 6 (Remediation Page)');
              });
            }
          }
        } catch (e) {
          debugPrint('❌ Fallback navigation to remediation page failed: $e');
          if (mounted) {
            _showErrorSnackBar('Failed to navigate to remediation page');
          }
        }
      }
    }
  }

  void _onSurveyEnd() {
    Navigator.of(context).pop();
  }

  Future<bool> _saveFormData() async {
    if (!mounted) return false;

    // Create overlay entry for loading indicator
    final overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 16),
              Text(
                'Saving form data...',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Show loading indicator
      Overlay.of(context).insert(overlayEntry);

      // Get the database instance
      final db = await HouseholdDBHelper.instance.database;
      bool success = false;
      bool hasAnyData = false;

      // Start a transaction to ensure all data is saved atomically
      await db.transaction((txn) async {
        try {
          debugPrint('\n🔄 ===== STARTING FORM DATA SAVE =====');

          // Cover page data saving removed
          debugPrint('\n📝 1. SKIPPING COVER PAGE DATA SAVE (REMOVED)');
          hasAnyData = true;

          // 2. Save consent data
          debugPrint('\n📝 2. SAVING CONSENT DATA...');
          if (_consentData != null) {
            try {
              // Detailed field logging for consent data
              final consentMap = _consentData!.toMap();
              debugPrint('📋 CONSENT DATA FIELDS:');
              consentMap.forEach((key, value) {
                debugPrint('   • $key: ${value?.toString() ?? 'null'}');
              });
              final db = await HouseholdDBHelper.instance.database;

              if (_consentData!.id == null) {
                // Insert new record
                final id = await db.insert(
                  'consentTBL',
                  _consentData!.toMap(),
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
                debugPrint('✅ Consent data inserted successfully with ID: $id');
                _consentData = _consentData!.copyWith(id: id);
              } else {
                // Update existing record
                await db.update(
                  'consentTBL',
                  _consentData!.toMap(),
                  where: 'id = ?',
                  whereArgs: [_consentData!.id],
                );
                debugPrint(
                    '✅ Consent data updated successfully for ID: ${_consentData!.id}');
              }

              hasAnyData = true;
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Consent data saved successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              debugPrint('❌ Error saving consent data: $e');
              rethrow;
            }
          } else {
            debugPrint('ℹ️ No consent data to save');
          }

          // 3. Save farmer identification data
          debugPrint('\n👨\u200d🌾 3. SAVING FARMER IDENTIFICATION DATA...');
          if (_farmerPageKey.currentState != null) {
            try {
              debugPrint('💾 FARMER IDENTIFICATION DATA:');
              // Log the state data if available
              try {
                final state = _farmerPageKey.currentState!;
                final stateData = state.toString();
                // Extract and log relevant fields from the state
                final fieldRegex = RegExp(r'(\w+):\s*([^\n]+)');
                final matches = fieldRegex.allMatches(stateData);
                for (final match in matches) {
                  final fieldName = match.group(1);
                  final fieldValue = match.group(2);
                  if (fieldName != null && fieldValue != null) {
                    debugPrint(
                        '   • $fieldName: ${fieldValue.length > 100 ? fieldValue.substring(0, 100) + '...' : fieldValue}');
                  }
                }
              } catch (e) {
                debugPrint('   Could not extract detailed field data: $e');
              }
              await _farmerPageKey.currentState!.saveForm();
              debugPrint('✅ Farmer identification data saved successfully');
              hasAnyData = true;
            } catch (e) {
              debugPrint('⚠️ Error saving farmer identification data: $e');
              // Continue with other saves
            }
          } else {
            debugPrint(
                'ℹ️ Farmer identification page not initialized or no data to save');
          }

          // 4. Save combined farm identification data
          debugPrint('\n🏡 4. SAVING FARM IDENTIFICATION DATA...');
          if (_combinedPageKey.currentState != null) {
            try {
              debugPrint('💾 FARM IDENTIFICATION DATA:');
              try {
                // Log the current page state data
                final state = _combinedPageKey.currentState!;
                final stateData = state.toString();
                // Log the current page index and other relevant state
                debugPrint(
                    '   • Current Page Index: ${state.currentPageIndex}');
                // Log the data models being used
                debugPrint(
                    '   • Visit Info Data: ${state.visitInfoData.toJson()}');
                debugPrint('   • Owner Data: ${state.ownerData.toJson()}');
                debugPrint('   • Workers Data: ${state.workersData.toJson()}');
                debugPrint('   • Adults Data: ${state.adultsData.toJson()}');
              } catch (e) {
                debugPrint('   Could not extract detailed field data: $e');
              }
              await _combinedPageKey.currentState!.saveCurrentPageData();
              debugPrint('✅ Farm identification data saved successfully');
              hasAnyData = true;
            } catch (e) {
              debugPrint('⚠️ Error saving farm identification data: $e');
            }
          } else {
            debugPrint(
                'ℹ️ Farm identification page not initialized or no data to save');
          }

          // 5. Save children household data
          debugPrint('\n👨‍👩‍👧‍👦 5. SAVING CHILDREN HOUSEHOLD DATA...');
          if (_childrenHouseholdKey.currentState != null &&
              _currentFarmIdentificationId != null) {
            try {
              debugPrint('💾 Attempting to save children household data...');
              if (_childrenHouseholdKey.currentState!.mounted) {
                await _childrenHouseholdKey.currentState!.saveFormData();
                debugPrint('✅ Children household data saved successfully');
                hasAnyData = true;
              }
            } catch (e) {
              debugPrint('⚠️ Error saving children household data: $e');
            }
          } else {
            debugPrint(
                'ℹ️ Children household page not initialized or no farm ID available');
          }

          // 6. Save remediation data
          debugPrint('\n🛠️ 6. SAVING REMEDIATION DATA...');
          if (_remediationPageKey.currentState != null &&
              _currentFarmIdentificationId != null) {
            try {
              debugPrint(
                  '💾 Attempting to save remediation data for farm ID: $_currentFarmIdentificationId');
              await _remediationPageKey.currentState!
                  .saveData(int.parse(_currentFarmIdentificationId!));
              debugPrint('✅ Remediation data saved successfully');
              hasAnyData = true;
            } catch (e) {
              debugPrint('⚠️ Error saving remediation data: $e');
            }
          } else {
            debugPrint(
                'ℹ️ Remediation page not initialized or no farm ID available');
          }

          // 7. Save sensitization data
          debugPrint('\n📋 7. SAVING SENSITIZATION DATA...');
          if (_sensitizationPageKey.currentState != null &&
              _currentFarmIdentificationId != null) {
            try {
              debugPrint('💾 Attempting to save sensitization data...');
              final sensitizationState = _sensitizationPageKey.currentState;
              if (sensitizationState is State<SensitizationPage> &&
                  sensitizationState.mounted) {
                final sensitizationPageState = sensitizationState as dynamic;
                if (sensitizationPageState.saveData != null) {
                  await sensitizationPageState
                      .saveData(int.parse(_currentFarmIdentificationId!));
                  debugPrint('✅ Sensitization data saved successfully');
                  hasAnyData = true;
                } else {
                  debugPrint(
                      'ℹ️ saveData method not found in sensitization page');
                }
              } else {
                debugPrint('ℹ️ Sensitization page not properly initialized');
              }
            } catch (e) {
              debugPrint('⚠️ Error saving sensitization data: $e');
            }
          } else {
            debugPrint(
                'ℹ️ Sensitization page not initialized or no farm ID available');
          }

          // 8. Save sensitization questions data
          debugPrint('\n❓ 8. SAVING SENSITIZATION QUESTIONS...');
          if (_sensitizationQuestionsKey.currentState != null &&
              _currentFarmIdentificationId != null) {
            try {
              debugPrint('💾 Attempting to save sensitization questions...');
              final state = _sensitizationQuestionsKey.currentState;
              if (state is SensitizationQuestionsPageState) {
                await state.saveData(int.parse(_currentFarmIdentificationId!));
                debugPrint('✅ Sensitization questions saved successfully');
                hasAnyData = true;
              } else {
                debugPrint(
                    'ℹ️ Unexpected state type for sensitization questions');
              }
            } catch (e) {
              debugPrint('⚠️ Error saving sensitization questions: $e');
            }
          } else {
            debugPrint(
                'ℹ️ Sensitization questions page not initialized or no farm ID available');
          }

          if (!hasAnyData) {
            debugPrint('\n⚠️ WARNING: No data was saved during this operation');
          } else {
            debugPrint('\n✅ ALL AVAILABLE FORM DATA SAVED SUCCESSFULLY');
          }

          success = true;
        } catch (e) {
          debugPrint('\n❌ ERROR IN TRANSACTION: $e');
          rethrow;
        }
      });

      if (success && mounted) {
        final message = hasAnyData
            ? 'Form data saved successfully!'
            : 'No data was available to save.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: hasAnyData ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      return success;
    } catch (e) {
      debugPrint('\n❌ CRITICAL ERROR SAVING FORM DATA: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save form data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
      debugPrint('\n🏁 FORM DATA SAVE PROCESS COMPLETED\n');
    }
  }

  Future<void> _submitForm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Submit Survey',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
        content: Text('Are you sure you want to submit the household survey?',
            style: GoogleFonts.inter(color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child:
                Text('Submit', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final overlaySize = overlay.size;
      final loader = Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 16),
              Text('Saving form data...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );

      final overlayEntry = OverlayEntry(builder: (context) => loader);
      Overlay.of(context).insert(overlayEntry);

      try {
        // Save all form data
        await _saveFormData();

        // Mark as submitted
        if (mounted) {
          setState(() {
            _isSubmitted = true;
          });
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Survey submitted successfully!',
                  style: GoogleFonts.inter()),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate back after a short delay
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        debugPrint('❌ Error during form submission: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save form data: ${e.toString()}',
                  style: GoogleFonts.inter()),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } finally {
        overlayEntry.remove();
      }
    } catch (e) {
      debugPrint('❌ Error showing loading overlay: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToLastPage() {
    if (_pageController.hasClients) {
      _pageController
          .animateToPage(
        _totalPages - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    }
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Submit',
        style: GoogleFonts.inter(color: Colors.white),
      ),
    );
  }

  void _handleCombinedPageSubmit() {
    _pageController.animateToPage(
      4,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _resetFormData() async {
    try {
      // Clear all data from all tables
      await HouseholdDBHelper.instance.clearAllSurveyData();

      // Reset all form data
      _coverData = CoverPageData.empty();
      _consentData = ConsentData.empty();

      // Re-initialize farmer data to get fresh controllers
      _farmerData = FarmerIdentificationData();

      // Reset all state variables
      setState(() {
        _currentPageIndex = 0;
        _combinedPageSubIndex = 0;
        _currentChildNumber = 1;
        _totalChildren5To17 = 0;
        _childrenDetails = [];
        _isSensitizationChecked = false;
        _isSubmitted = false;
        _showChildDetailsPage = false;
      });

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_town');
      await prefs.remove('selected_farmer');

      // Reset page controller to first page
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }

      debugPrint('Form data reset successfully');
    } catch (e) {
      debugPrint('❌ Error resetting form data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting form: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // First dispose all controllers
    try {
      _pageController.dispose();
      _consentData?.dispose();
      _farmerData.ghanaCardNumberController.dispose();
      _farmerData.idNumberController.dispose();
      _farmerData.contactNumberController.dispose();
      _farmerData.childrenCountController.dispose();
      _farmerData.noConsentReasonController.dispose();
    } catch (e) {
      debugPrint('Error disposing controllers: $e');
    }

    // Then clear form data without accessing widget tree
    try {
      // Clear local data without async operations that might access context
      _coverData = CoverPageData.empty();
      _consentData = ConsentData.empty();
      _currentPageIndex = 0;
      _combinedPageSubIndex = 0;
      _currentChildNumber = 1;
      _totalChildren5To17 = 0;
      _childrenDetails = [];
      _isSensitizationChecked = false;
      _isSubmitted = false;

      // Clear SharedPreferences in a way that won't trigger widget tree access
      Future.microtask(() async {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('selected_town');
          await prefs.remove('selected_farmer');
        } catch (e) {
          debugPrint('Error clearing SharedPreferences: $e');
        }
      });
    } catch (e) {
      debugPrint('Error in dispose cleanup: $e');
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HouseHold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onComplete != oldWidget.onComplete) {
      _resetFormData();
    }
  }

  Future<bool> _onWillPop() async {
    await _resetFormData();
    return true;
  }

  void _navigateToChildDetailsPage(int childNumber) {
    if (!mounted) return;

    debugPrint('🔹 _navigateToChildDetailsPage called for child $childNumber');

    setState(() {
      _currentChildNumber = childNumber;
      _showChildDetailsPage = true;
    });

    if (_pageController.hasClients) {
      // Find the index of the child details page
      int targetPage = _totalPages - 1; // Default to last page if not found

      debugPrint('🔹 Navigating to child details page at index $targetPage');

      _pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToPage(int pageIndex) {
    if (!mounted) return;

    debugPrint('🔹 _navigateToPage called for page $pageIndex');

    if (_pageController.hasClients) {
      debugPrint('🔹 Animating to page $pageIndex');

      _pageController
          .animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        if (mounted) {
          setState(() {
            _currentPageIndex = pageIndex;
          });
        }
      });
    }
  }

  Widget _buildNavigationButtons() {
    debugPrint('🔹 Building navigation buttons');

    // Calculate navigation states
    final isLastPage = _currentPageIndex == _totalPages - 1;
    final isLastSubPage =
        _combinedPageSubIndex >= 3; // Assuming 4 sub-pages (0-3)

    return GestureDetector(
      onTapDown: (details) {
        debugPrint('🔹 Navigation button tapped at ${details.globalPosition}');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPageIndex > 0 ||
                (_isOnCombinedPage && _combinedPageSubIndex > 0))
              ElevatedButton(
                onPressed: _onPrevious,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Previous'),
              )
            else
              const SizedBox(width: 100),
            ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isLastPage
                    ? 'Submit'
                    : _isOnCombinedPage
                        ? isLastSubPage
                            ? 'Next Page'
                            : 'Next (${_combinedPageSubIndex + 2}/4)'
                        : 'Next',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              await _onWillPop();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Column(
            children: [
              Text(
                'Household Survey',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getPageTitle(_currentPageIndex),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.green.shade600,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.green.shade400,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 4.0,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                children: [
                  CoverPage(
                    key: const ValueKey('cover_page'),
                    data: _coverData,
                    onDataChanged: (newData) {
                      setState(() {
                        _coverData = newData;
                      });
                    },
                    onNext: _onNext,
                  ),
                  ConsentPage(
                    key: _consentPageKey,
                    data: _consentData ?? ConsentData.empty(),
                    onDataChanged: _onConsentDataChanged,
                    onRecordTime: _recordInterviewTime,
                    onGetLocation: _getCurrentLocation,
                    onNext: _onNext,
                    onPrevious: _onPrevious,
                    onSurveyEnd: _onSurveyEnd,
                  ),
                  FarmerIdentification1Page(
                    key: _farmerPageKey,
                    data: _farmerData,
                    onDataChanged: _onFarmerDataChanged,
                    onNext: _onNext,
                    onComplete: (data) {
                      _onFarmerDataChanged(data);
                      _onNext();
                    },
                  ),
                  CombinedFarmIdentificationPage(
                    key: _combinedPageKey,
                    initialPageIndex: _combinedPageSubIndex,
                    onPageChanged: (index) {
                      setState(() {
                        _combinedPageSubIndex = index;
                      });
                    },
                    onPrevious: _onPrevious,
                    onNext: _onNext,
                    onSubmit: _handleCombinedPageSubmit,
                  ),
                  ChildrenHouseholdPage(
                    key: const ValueKey('children_household_page'),
                    producerDetails: {
                      'ghanaCardNumber':
                          _farmerData.ghanaCardNumberController.text,
                      'idNumber': _farmerData.idNumberController.text,
                      'contactNumber': _farmerData.contactNumberController.text,
                      'childrenCount': _farmerData.childrenCountController.text,
                    },
                    children5To17Controller:
                        _farmerData.childrenCountController,
                    onNext: () {
                      final children5To17 = int.tryParse(
                              _farmerData.childrenCountController.text) ??
                          0;
                      debugPrint('=== DEBUG: ChildrenHouseholdPage onNext ===');
                      debugPrint('Children 5-17 count: $children5To17');

                      setState(() {
                        _totalChildren5To17 = children5To17;
                        _currentChildNumber = 1;
                        _childrenDetails = [];
                      });

                      if (children5To17 > 0) {
                        debugPrint(
                            'DEBUG: Navigating to ChildDetailsPage for $children5To17 children');
                        _pageController.animateToPage(
                          5,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        debugPrint(
                            'DEBUG: No children 5-17, navigating to sensitization page');
                        _pageController.jumpToPage(
                          6,
                        );
                      }
                    },
                    onPrevious: _onPrevious,
                  ),
                  ChildDetailsPage(
                    key: _childDetailsPageKey,
                    childNumber: _currentChildNumber,
                    totalChildren: _totalChildren5To17,
                    childrenDetails: _childrenDetails,
                    onComplete: _handleChildDetailsComplete,
                  ),
                  // Remediation Page (index 6)
                  RemediationPage(
                    key: _remediationPageKey,
                    onPrevious: _onPrevious,
                    onNext: _onNext,
                  ),
                  SensitizationPage(
                    key: _sensitizationPageKey,
                    sensitizationData: SensitizationData(
                      isAcknowledged: _isSensitizationChecked,
                    ),
                    onSensitizationChanged: (SensitizationData data) {
                      if (mounted) {
                        setState(() {
                          _isSensitizationChecked = data.isAcknowledged;
                        });
                      }
                    },
                  ),
                  Form(
                    key: _pageKeys[7],
                    child: SensitizationQuestionsPage(
                      key: _sensitizationQuestionsKey,
                      onNext: _onNext,
                      onPrevious: _onPrevious,
                      validateOnly: true, // Let parent handle the validation
                    ),
                  ),
                  EndOfCollectionPage(
                    onPrevious: _onPrevious,
                    onComplete: () {
                      if (widget.onComplete != null) {
                        widget.onComplete!();
                      }
                    },
                  ),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }
}
