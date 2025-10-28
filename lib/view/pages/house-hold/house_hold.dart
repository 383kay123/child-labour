import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/children_household_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/end_of_collection_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/farmer_identification.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/remediation_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/sensitization_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/farm%20identification/sensitization_questions_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/combined_farmer_identification.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/consent_page.dart';
import 'package:human_rights_monitor/view/pages/house-hold/pages/steps/cover_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../controller/db/db.dart';

import '../../../controller/models/consent_model.dart';
import '../../../controller/models/cover_model.dart';
import '../../../controller/models/farmeridentification_model.dart';
import '../../../controller/models/sensitization_model.dart';
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
  late final PageController _pageController;
  int _currentPageIndex = 0;
  final GlobalKey<ConsentPageState> _consentPageKey = GlobalKey<ConsentPageState>();
  final GlobalKey<FarmerIdentification1PageState> _farmerPageKey = GlobalKey<FarmerIdentification1PageState>();
  final GlobalKey<CombinedFarmIdentificationPageState> _combinedPageKey = GlobalKey<CombinedFarmIdentificationPageState>();
  int _combinedPageSubIndex = 0;
  final int _totalPages = 10;
  final int _totalCombinedSubPages = 4;

  bool _isSubmitted = false;
  bool _isSensitizationChecked = false;

  bool get _isOnCombinedPage => _currentPageIndex == 3;

  double get _progress => (_currentPageIndex + 1) / _totalPages;

  CoverPageData _coverData = CoverPageData.empty();
  ConsentData _consentData = ConsentData.empty();
  late FarmerIdentificationData _farmerData;

  int _currentChildNumber = 1;
  int _totalChildren5To17 = 0;
  List<dynamic> _childrenDetails = [];

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

  // Reset cover page data to initial state
  void _resetCoverData() {
    setState(() {
      _coverData = CoverPageData.empty();
    });
  }

  // Get current location and update consent data
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    try {
      setState(() {
        _surveyState.isGettingLocation = true;
        _surveyState.locationStatus = 'Getting location...';
      });

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _surveyState.locationStatus = 'Location services are disabled';
          _surveyState.isGettingLocation = false;
        });
        
        // Show a snackbar to inform the user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please enable location services to continue'),
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

      // Check location permissions
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
                content: Text('Location permission is required to continue. Please grant permission.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _surveyState.locationStatus = 'Location permissions are permanently denied';
          _surveyState.isGettingLocation = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permissions are permanently denied. Please enable them in app settings.'),
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

      // Get the current position with timeout and high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (mounted) {
        setState(() {
          _surveyState.currentPosition = position;
          _surveyState.locationStatus = 'Location captured';
          _surveyState.isGettingLocation = false;
          
          // Update consent data with the new position
          final updatedConsentData = _consentData.copyWith(
            currentPosition: position,
            locationStatus: 'Location captured (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})',
          );
          
          // Update the state and notify listeners
          setState(() {
            _consentData = updatedConsentData;
          });
          
          // Notify parent of the data change
          _onConsentDataChanged(updatedConsentData);
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location captured! Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
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
            content: Text('Location request timed out. Please try again in an open area.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
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

  // Add this method to handle combined page navigation
Future<void> _handleCombinedPageNavigation() async {
  if (!mounted) return;
  
  // Add a small delay to ensure the widget is built
  await Future.delayed(const Duration(milliseconds: 100));
  if (!mounted) return;
  
  debugPrint('=== COMBINED PAGE NAVIGATION ===');
  debugPrint('Current sub-page index: $_combinedPageSubIndex');
  debugPrint('Total sub-pages: $_totalCombinedSubPages');
  
  // Get the combined page state
  final combinedPageState = _combinedPageKey.currentState;
  
  if (combinedPageState == null || !mounted) {
    debugPrint('ERROR: Combined page state is null or widget is not mounted!');
    
    // Try one more time after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    
    final retryState = _combinedPageKey.currentState;
    if (retryState == null || !mounted) {
      debugPrint('ERROR: Still unable to get combined page state after retry');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Form is not ready. Please try again in a moment.'),
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
    
    // If we get here, the retry was successful
    await _handleCombinedPageNavigation();
    return;
  }
  
  // Validate the current sub-page with error handling
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
            SnackBar(
              content: const Text('Validation error. Please check your input.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
    return;
  }
  
  if (!isValid) {
    // Show the first error from validation
    final errors = combinedPageState.getCurrentPageErrors();
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
      // Navigate to next sub-page within combined page
      debugPrint('Moving to next sub-page: ${_combinedPageSubIndex + 1}');
      setState(() {
        _combinedPageSubIndex++;
      });
      
      // Animate the combined page's internal PageView with error handling
      if (combinedPageState.mounted && combinedPageState.pageController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (combinedPageState.mounted && combinedPageState.pageController.hasClients) {
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
      // We're on the last sub-page, move to next main page
      debugPrint('Last sub-page reached, moving to next main page');
      if (mounted) {
        _pageController.animateToPage(
          4, // Next main page (Children Household Page)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // Record interview start time
  void _recordInterviewTime() {
    final now = DateTime.now();
    setState(() {
      _surveyState.interviewStartTime = now;
      _surveyState.timeStatus = 'Started at ${_surveyState.formatTime(now)}';
      
      // Update consent data with the interview time
      _consentData = _consentData.copyWith(
        interviewStartTime: now,
        timeStatus: 'Started at ${_surveyState.formatTime(now)}',
      );
    });
  }

  Future<bool> _saveCoverPageData() async {
    // List to collect all validation errors
    final List<String> errors = [];

    // Validate required fields
    if (_coverData.selectedTownCode == null) {
      errors.add('Please select a society');
    }
    
    if (_coverData.selectedFarmerCode == null) {
      errors.add('Please select a farmer');
    }

    // // Validate basic member details
    // if (_coverData.member?['gender'] == null) {
    //   errors.add('Please specify gender for household member');
    // }

    // If there are validation errors, show them and return false
    if (errors.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please fix the following issues:', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...errors.map((error) => Text('• $error')).toList(),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      return false;
    }

    // If we get here, all validations passed
    return true;
  }

  void _onConsentDataChanged(ConsentData newData) {
    setState(() {
      _consentData = newData;
    });
  }

  void _onFarmerDataChanged(FarmerIdentificationData newData) {
    setState(() {
      _farmerData = newData;
    });
  }

  void _navigateToNextPage() {
    if (_currentPageIndex < _totalPages - 1) {
      final nextPageIndex = _currentPageIndex + 1;
      _pageController.animateToPage(
        nextPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

 // Update the _onPrevious method
void _onPrevious() {
  if (!mounted) return;
  
  // Handle combined page sub-navigation
  if (_isOnCombinedPage && _combinedPageSubIndex > 0) {
    // Go to previous sub-page within combined page
    if (_combinedPageKey.currentState != null) {
      setState(() {
        _combinedPageSubIndex--;
      });
      _combinedPageKey.currentState!.pageController.animateToPage(
        _combinedPageSubIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  } else if (_currentPageIndex > 0) {
    // Go to previous main page
    final previousPageIndex = _currentPageIndex - 1;
    _pageController.animateToPage(
      previousPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

// Get the current page title with sub-page info
String _getPageTitle(int index) {
  // Special case for combined page view
  if (index == 3 && _isOnCombinedPage) {
    final subPageTitles = [
      'Visit Information',
      'Owner Identification',
      'Workers in Farm',
      'Adults Information'
    ];
    return 'Farm Details - ${subPageTitles[_combinedPageSubIndex]} (${_combinedPageSubIndex + 1}/4)';
  }
  
  // Default page titles for the main survey flow
  final titles = [
    'Cover Page',
    'Consent Form',
    'Farmer Identification',
    'Children Information',
    'Children in Household',
    'Child $_currentChildNumber of $_totalChildren5To17 Details',
    'Sensitization',
    'Sensitization Questions',
    'Remediation',
    'End of Collection'
  ];
  
  if (index >= 0 && index < titles.length) {
    return titles[index];
  }
  return 'Household Survey';
}

  bool _validateConsentData() {
    // Call the validateForm method from the consent page
    if (_consentPageKey.currentState != null) {
      final validationError = _consentPageKey.currentState!.validateForm();
      if (validationError != null) {
        // Show the first error from the consent page
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

  // Update the _onNext method
Future<void> _onNext() async {
  if (!mounted) return;
  
  final currentPage = _pageController.positions.isNotEmpty
      ? _pageController.page?.round() ?? _currentPageIndex
      : _currentPageIndex;

  debugPrint('=== NAVIGATION REQUEST ===');
  debugPrint('Current page: $currentPage');
  debugPrint('Is on combined page: $_isOnCombinedPage');
  debugPrint('Combined sub-page index: $_combinedPageSubIndex');
  debugPrint('Current children 5-17: $_totalChildren5To17');
  debugPrint('Children count controller text: ${_farmerData.childrenCountController.text}');

  bool canProceed = true;
  String? errorMessage;

  // Page-specific validations
  switch (currentPage) {
    case 0: // Cover page
      canProceed = await _saveCoverPageData();
      errorMessage = 'Please complete all required fields on the cover page';
      break;
      
    case 1: // Consent page
      canProceed = _validateConsentData();
      errorMessage = 'Please complete all required fields on the consent form';
      break;
      
    case 4: // Children Household page
      // Update _totalChildren5To17 from the controller when Next is pressed
      final childrenCount = int.tryParse(_farmerData.childrenCountController.text) ?? 0;
      setState(() {
        _totalChildren5To17 = childrenCount;
        _currentChildNumber = 1;
        _childrenDetails = [];
      });
      debugPrint('Updated children 5-17 to: $_totalChildren5To17');
      break;
      
    case 2: // Farmer Identification page
      if (_farmerPageKey.currentState != null) {
        final form = _farmerPageKey.currentState!.formKey.currentState;
        if (form != null) {
          form.save();
        }
        canProceed = _farmerPageKey.currentState!.validateForm();
        if (!canProceed) {
          final firstError = _farmerPageKey.currentState!.validationErrors.values.firstOrNull;
          errorMessage = firstError ?? 'Please complete all required fields in the farmer identification form';
        }
      } else {
        canProceed = false;
        errorMessage = 'Validation not available';
      }
      break;
      
    case 3: // Combined Farm Identification Page (with sub-pages)
      // Handle combined page navigation separately
      await _handleCombinedPageNavigation();
      return; // Early return after handling combined page navigation
      
    // ... rest of the cases remain the same
  }

  // Show error if validation failed
  if (!canProceed && errorMessage != null && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    return;
  }

  // If we get here, validation passed - proceed with standard navigation
  if (_currentPageIndex < _totalPages - 1) {
    _navigateToNextPage();
  }
}


  // Widget _buildDebugInfo() {
  //   return Container(
  //     padding: const EdgeInsets.all(8),
  //     margin: const EdgeInsets.all(8),
  //     color: Colors.yellow[100],
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text('DEBUG INFO:',
  //             style: TextStyle(fontWeight: FontWeight.bold)),
  //         Text(
  //             'Children Count Controller Text: "${_farmerData.childrenCountController.text}"'),
  //         Text(
  //             'Parsed Number: ${int.tryParse(_farmerData.childrenCountController.text) ?? "Invalid"}'),
  //         Text('Current Page: $_currentPageIndex'),
  //       ],
  //     ),
  //   );
  // }

  void _handleChildDetailsComplete(dynamic childData) {
    _childrenDetails.add(childData);

    if (_currentChildNumber < _totalChildren5To17) {
      setState(() {
        _currentChildNumber++;
      });
    } else {
      _pageController.animateToPage(
        6,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSurveyEnd() {
    Navigator.of(context).pop();
  }

  void _submitForm() {
    showDialog(
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
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Survey submitted successfully!',
                      style: GoogleFonts.inter()),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
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
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                Text('Submit', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
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

  // Reset all form data
  Future<void> _resetFormData() async {
    try {
      // Clear the database entries
      final dbHelper = LocalDBHelper.instance;
      await dbHelper.clearAllSurveyData();
      
      // Reset all form data
      _coverData = CoverPageData.test();
      _consentData = ConsentData.empty();
      _farmerData.ghanaCardNumberController.clear();
      _farmerData.idNumberController.clear();
      _farmerData.contactNumberController.clear();
      _farmerData.childrenCountController.clear();
      _farmerData.noConsentReasonController.clear();
      _currentPageIndex = 0;
      _combinedPageSubIndex = 0;
      _currentChildNumber = 1;
      _totalChildren5To17 = 0;
      _childrenDetails = [];
      _isSensitizationChecked = false;
      _isSubmitted = false;
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_town');
      await prefs.remove('selected_farmer');
    } catch (e) {
      debugPrint('Error resetting form data: $e');
    }
  }

  @override
  void dispose() {
    // Reset form data and clean up when navigating away
    _resetFormData();
    
    // Dispose controllers
    _pageController.dispose();
    _consentData.dispose();
    _farmerData.ghanaCardNumberController.dispose();
    _farmerData.idNumberController.dispose();
    _farmerData.contactNumberController.dispose();
    _farmerData.childrenCountController.dispose();
    _farmerData.noConsentReasonController.dispose();
    
    super.dispose();
  }
  
  // Override didUpdateWidget to handle widget updates
  @override
  void didUpdateWidget(covariant HouseHold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset the form if the widget is being recreated
    if (widget.onComplete != oldWidget.onComplete) {
      _resetFormData();
    }
  }
  
  // Handle back button press
  Future<bool> _onWillPop() async {
    // Reset form data when navigating back
    await _resetFormData();
    return true;
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
            // if (_currentPageIndex == 4) _buildDebugInfo(),
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
                // Cover Page
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
                // Consent Page
                ConsentPage(
                  key: _consentPageKey,
                  data: _consentData,
                  onDataChanged: _onConsentDataChanged,
                  onRecordTime: _recordInterviewTime,
                  onGetLocation: _getCurrentLocation,
                  onNext: _onNext,
                  onPrevious: _onPrevious,
                  onSurveyEnd: _onSurveyEnd,
                ),
                // Farmer Identification Page
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
                // Combined Farm Identification Page
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
                // Children Household Page
                ChildrenHouseholdPage(
                  key: const ValueKey('children_household_page'),
                  producerDetails: {
                    'ghanaCardNumber': _farmerData.ghanaCardNumberController.text,
                    'idNumber': _farmerData.idNumberController.text,
                    'contactNumber': _farmerData.contactNumberController.text,
                    'childrenCount': _farmerData.childrenCountController.text,
                  },
                  children5To17Controller: _farmerData.childrenCountController,
                  onComplete: (int children5To17) {
                    print('=== DEBUG: ChildrenHouseholdPage callback ===');
                    print('Children 5-17 count: $children5To17');

                    // Always update the total children count, even if it's 0
                    setState(() {
                      _totalChildren5To17 = children5To17;
                      _currentChildNumber = 1;
                      _childrenDetails = [];
                    });

                    if (children5To17 > 0) {
                      print('DEBUG: Navigating to ChildDetailsPage for $children5To17 children');
                      _pageController.animateToPage(
                        5,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      print('DEBUG: No children 5-17, navigating to sensitization page');
                      _pageController.animateToPage(
                        6,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
                // Child Details Page
                ChildDetailsPage(
                  key: ValueKey('child_details_page_$_currentChildNumber'),
                  childNumber: _currentChildNumber,
                  totalChildren: _totalChildren5To17,
                  childrenDetails: _childrenDetails,
                  onComplete: _handleChildDetailsComplete,
                ),
                // Sensitization Page
                SensitizationPage(
                  sensitizationData: SensitizationData(
                    isAcknowledged: _isSensitizationChecked,
                  ),
                  onSensitizationChanged: (SensitizationData data) {
                    setState(() {
                      _isSensitizationChecked = data.isAcknowledged;
                    });
                  },
                ),
                // Other Pages
                  const SensitizationQuestionsPage(),
                  const RemediationPage(),
                  const EndOfCollectionPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastPage = _currentPageIndex == _totalPages - 1;
    final isLastSubPage = _isOnCombinedPage && _combinedPageSubIndex == _totalCombinedSubPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous button
        if (_currentPageIndex > 0 || (_isOnCombinedPage && _combinedPageSubIndex > 0))
          ElevatedButton(
            onPressed: _onPrevious,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Previous'),
          )
        else
          const SizedBox(width: 100), // Spacer for alignment

        // Next/Submit button
        ElevatedButton(
          onPressed: _onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
    );
  }
}