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

  const HouseHold({
    Key? key,
    this.onComplete,
  }) : super(key: key);

  @override
  State<HouseHold> createState() => _HouseHoldState();
}

class _HouseHoldState extends State<HouseHold> {
  final _surveyState = SurveyState();
  final PageController _pageController = PageController();

  int _currentPageIndex = 0;
  int _combinedPageSubIndex = 0;
  final int _totalPages = 10;
  final int _totalCombinedSubPages = 4;

  bool _isSubmitted = false;
  bool _isSensitizationChecked = false;

  bool get _isOnCombinedPage => _currentPageIndex == 3;

  double get _progress => (_currentPageIndex + 1) / _totalPages;

  CoverPageData _coverData = CoverPageData.test();
  ConsentData _consentData = ConsentData.empty();
  FarmerIdentificationData _farmerData = FarmerIdentificationData(
    ghanaCardNumberController: TextEditingController(),
    reasonController: TextEditingController(),
    idNumberController: TextEditingController(),
    contactNumberController: TextEditingController(),
    childrenCountController: TextEditingController(),
  );

  int _currentChildNumber = 1;
  int _totalChildren5To17 = 0;
  List<dynamic> _childrenDetails = [];

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _saveCoverPageData() async {
    if (_coverData.selectedTownCode == null ||
        _coverData.selectedFarmerCode == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select both society and farmer')),
        );
      }
      return false;
    }
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

  void _onPrevious() {
    if (_isOnCombinedPage && _combinedPageSubIndex > 0) {
      setState(() {
        _combinedPageSubIndex--;
      });
    } else if (_currentPageIndex == 5 && _currentChildNumber > 1) {
      setState(() {
        _currentChildNumber--;
        if (_childrenDetails.isNotEmpty) {
          _childrenDetails.removeLast();
        }
      });
    } else if (_currentPageIndex > 0) {
      final previousPageIndex = _currentPageIndex - 1;
      _pageController.animateToPage(
        previousPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateConsentData() {
    if (_currentPageIndex == 1) {
      // Consent page index is 1
      if (_consentData.consentGiven == null) {
        // No selection made yet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please either accept or decline the consent')),
        );
        return false;
      }

      if (_consentData.consentGiven == false &&
          (_consentData.otherSpecification?.trim().isEmpty ?? true)) {
        // If declined, require a reason
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please provide a reason for declining')),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _onNext() async {
    final currentPage = _pageController.positions.isNotEmpty
        ? _pageController.page?.round() ?? _currentPageIndex
        : _currentPageIndex;

    if (currentPage == 0) {
      final success = await _saveCoverPageData();
      if (!success) return;
    }

    // Validate consent form if on consent page
    if (currentPage == 1 && !_validateConsentData()) {
      return;
    }

    if (_isOnCombinedPage &&
        _combinedPageSubIndex < _totalCombinedSubPages - 1) {
      setState(() {
        _combinedPageSubIndex++;
      });
    } else if (_currentPageIndex == 7) {
      _pageController.animateToPage(
        8,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPageIndex == 8) {
      _pageController.animateToPage(
        9,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPageIndex == 4) {
      String childrenCountText =
          _farmerData.childrenCountController.text.trim();
      print('=== DEBUG: Children Count Check ===');
      print('Text: "$childrenCountText"');
      print('Is empty: ${childrenCountText.isEmpty}');
      print('Is valid number: ${int.tryParse(childrenCountText) != null}');

      _totalChildren5To17 = int.tryParse(childrenCountText) ?? 0;

      if (_totalChildren5To17 > 0) {
        print(
            'DEBUG: Navigating to ChildDetailsPage for $_totalChildren5To17 children');
        setState(() {
          _currentChildNumber = 1;
          _childrenDetails = [];
        });
        _pageController.animateToPage(
          5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        print('DEBUG: No children 5-17, navigating to final page');
        _pageController.animateToPage(
          _totalPages - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentPageIndex < _totalPages - 1) {
      _navigateToNextPage();
    }
  }

  Widget _buildDebugInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      color: Colors.yellow[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DEBUG INFO:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
              'Children Count Controller Text: "${_farmerData.childrenCountController.text}"'),
          Text(
              'Parsed Number: ${int.tryParse(_farmerData.childrenCountController.text) ?? "Invalid"}'),
          Text('Current Page: $_currentPageIndex'),
        ],
      ),
    );
  }

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

  void _recordInterviewTime() {
    if (!_surveyState.isInterviewTimeRecorded) {
      setState(() {
        _surveyState.interviewStartTime = DateTime.now();
        _surveyState.timeStatus =
            '${_surveyState.formatTime(_surveyState.interviewStartTime!)} (${_surveyState.formatTimeAgo(_surveyState.interviewStartTime!)})';
        _surveyState.isInterviewTimeRecorded = true;
        _consentData = _consentData.updateSurveyState(
          interviewStartTime: _surveyState.interviewStartTime,
          timeStatus: _surveyState.timeStatus,
        );
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _surveyState.isGettingLocation = true;
      _surveyState.locationStatus = 'Getting location...';
      _consentData = _consentData.updateSurveyState(
        locationStatus: _surveyState.locationStatus,
        isGettingLocation: _surveyState.isGettingLocation,
      );
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _surveyState.locationStatus = 'Location services are disabled.';
          _surveyState.isGettingLocation = false;
          _consentData = _consentData.updateSurveyState(
            locationStatus: _surveyState.locationStatus,
            isGettingLocation: _surveyState.isGettingLocation,
          );
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _surveyState.locationStatus = 'Location permissions are denied';
            _surveyState.isGettingLocation = false;
            _consentData = _consentData.updateSurveyState(
              locationStatus: _surveyState.locationStatus,
              isGettingLocation: _surveyState.isGettingLocation,
            );
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _surveyState.locationStatus =
              'Location permissions are permanently denied';
          _surveyState.isGettingLocation = false;
          _consentData = _consentData.updateSurveyState(
            locationStatus: _surveyState.locationStatus,
            isGettingLocation: _surveyState.isGettingLocation,
          );
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _surveyState.currentPosition = position;
        _surveyState.locationStatus =
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _surveyState.isGettingLocation = false;
        _consentData = _consentData.updateSurveyState(
          currentPosition: _surveyState.currentPosition,
          locationStatus: _surveyState.locationStatus,
          isGettingLocation: _surveyState.isGettingLocation,
        );
      });
    } catch (e) {
      setState(() {
        _surveyState.locationStatus = 'Error getting location: $e';
        _surveyState.isGettingLocation = false;
        _consentData = _consentData.updateSurveyState(
          locationStatus: _surveyState.locationStatus,
          isGettingLocation: _surveyState.isGettingLocation,
        );
      });
    }
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

  @override
  void dispose() {
    _pageController.dispose();
    _consentData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          children: [
            Text(
              'Household Survey',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 20,
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
            valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
            minHeight: 4.0,
          ),
        ),
      ),
      body: Column(
        children: [
          if (_currentPageIndex == 4) _buildDebugInfo(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                  if (!_isOnCombinedPage) _combinedPageSubIndex = 0;
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
                  onNextPressed: _saveCoverPageData,
                ),
                ConsentPage(
                  key: const ValueKey('consent_page'),
                  data: _consentData,
                  onDataChanged: _onConsentDataChanged,
                  onRecordTime: _recordInterviewTime,
                  onGetLocation: _getCurrentLocation,
                  onNext: _onNext,
                  onPrevious: _onPrevious,
                  onSurveyEnd: _onSurveyEnd,
                ),
                FarmerIdentification1Page(
                  key: const ValueKey('farmer_identification_page'),
                  data: _farmerData,
                  onDataChanged: _onFarmerDataChanged,
                  onComplete: (data) {
                    _onFarmerDataChanged(data);
                    _onNext();
                  },
                ),
                CombinedFarmIdentificationPage(
                  key: ValueKey('combined_page_$_combinedPageSubIndex'),
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
                  children5To17Controller: _farmerData.childrenCountController,
                  onComplete: (int children5To17) {
                    print('=== DEBUG: ChildrenHouseholdPage callback ===');
                    print('Children 5-17 count: $children5To17');

                    if (children5To17 > 0) {
                      print(
                          'DEBUG: Navigating to ChildDetailsPage for $children5To17 children');
                      setState(() {
                        _totalChildren5To17 = children5To17;
                        _currentChildNumber = 1;
                        _childrenDetails = [];
                      });
                      _pageController.animateToPage(
                        5,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      print(
                          'DEBUG: No children 5-17, navigating to final page');
                      _pageController.animateToPage(
                        _totalPages - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
                ChildDetailsPage(
                  key: ValueKey('child_details_page_$_currentChildNumber'),
                  childNumber: _currentChildNumber,
                  totalChildren: _totalChildren5To17,
                  childrenDetails: _childrenDetails,
                  onComplete: _handleChildDetailsComplete,
                ),
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
                const SensitizationQuestionsPage(),
                const RemediationPage(),
                const EndOfCollectionPage(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastPage = _currentPageIndex == _totalPages - 1;
    final isChildrenHouseholdPage = _currentPageIndex == 4;
    final isSensitizationPage = _currentPageIndex == 6;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _onPrevious,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.green.shade600, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios,
                        size: 18, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Previous',
                      style: GoogleFonts.inter(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isLastPage
                    ? _submitForm
                    : () async {
                        final currentPage = _pageController.positions.isNotEmpty
                            ? _pageController.page?.round() ?? _currentPageIndex
                            : _currentPageIndex;

                        if (currentPage == 0) {
                          final success = await _saveCoverPageData();
                          if (!success) return;
                        }

                        if (isSensitizationPage && !_isSensitizationChecked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please acknowledge that you have read and understood the sensitization information'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        if (isChildrenHouseholdPage) {
                          String childrenCountText =
                              _farmerData.childrenCountController.text.trim();
                          if (childrenCountText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please enter the number of children aged 5-17'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (int.tryParse(childrenCountText) == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please enter a valid number for children count'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        }

                        _onNext();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  shadowColor: Colors.green.shade600.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastPage ? 'Submit' : 'Next',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (!isLastPage) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios,
                          size: 18, color: Colors.white),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Cover Page';
      case 1:
        return 'Consent Form';
      case 2:
        return 'Farmer Identification';
      case 3:
        return 'Farm Details';
      case 4:
        return 'Children Information';
      case 5:
        return 'Child $_currentChildNumber of $_totalChildren5To17 Details';
      case 6:
        return 'Sensitization';
      case 7:
        return 'Sensitization Questions';
      case 8:
        return 'Remediation';
      case 9:
        return 'End of Collection';
      default:
        return 'Household Survey';
    }
  }
}
