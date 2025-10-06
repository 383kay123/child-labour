import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/steps/consent_page.dart';
import 'pages/steps/cover_page.dart';
import 'pages/steps/farmer_identification_page.dart';

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
  const HouseHold({super.key});

  @override
  State<HouseHold> createState() => _HouseHoldState();
}

class _HouseHoldState extends State<HouseHold> {
  final _surveyState = SurveyState();
  final _formKey = GlobalKey<FormState>();

  int _currentPageIndex = 0;
  final int _totalPages = 3;

  double get _progress => (_currentPageIndex + 1) / _totalPages;

  String? _selectedTown;
  String? _selectedFarmer;
  final List<Map<String, String>> _towns = [
    {'name': 'Select Society', 'code': ''},
    {'name': 'Nairobi Central', 'code': 'NBO-001'},
    {'name': 'Mombasa CBD', 'code': 'MBA-001'},
  ];

  final List<Map<String, String>> _farmers = [
    {'id': '1', 'name': 'Farmer 1'},
    {'id': '2', 'name': 'Farmer 2'},
  ];

  String? _communityType;
  String? _residesInCommunityConsent;
  String? _farmerAvailable;
  String? _farmerStatus;
  String? _availablePerson;
  String? _otherSpecification;
  String? _otherCommunityName;
  bool _consentGiven = false;
  final TextEditingController _otherSpecController = TextEditingController();
  final TextEditingController _otherCommunityController =
      TextEditingController();

  void _recordInterviewTime() {
    if (!_surveyState.isInterviewTimeRecorded) {
      setState(() {
        _surveyState.interviewStartTime = DateTime.now();
        _surveyState.timeStatus =
            '${_surveyState.formatTime(_surveyState.interviewStartTime!)} (${_surveyState.formatTimeAgo(_surveyState.interviewStartTime!)})';
        _surveyState.isInterviewTimeRecorded = true;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _surveyState.isGettingLocation = true;
      _surveyState.locationStatus = 'Getting location...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _surveyState.locationStatus = 'Location services are disabled.';
          _surveyState.isGettingLocation = false;
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
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _surveyState.locationStatus =
              'Location permissions are permanently denied';
          _surveyState.isGettingLocation = false;
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
      });
    } catch (e) {
      setState(() {
        _surveyState.locationStatus = 'Error getting location: $e';
        _surveyState.isGettingLocation = false;
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

  @override
  void initState() {
    super.initState();
    _recordInterviewTime();
    _otherSpecController.addListener(() {
      _otherSpecification = _otherSpecController.text;
    });
    _otherCommunityController.addListener(() {
      _otherCommunityName = _otherCommunityController.text;
    });
  }

  Widget _buildCurrentPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: _buildPageContent(),
        );
      },
    );
  }

  Widget _buildPageContent() {
    switch (_currentPageIndex) {
      case 0:
        return CoverPage(
          selectedTown: _selectedTown,
          selectedFarmer: _selectedFarmer,
          towns: _towns,
          farmers: _farmers,
          onTownChanged: (value) {
            setState(() => _selectedTown = value);
          },
          onFarmerChanged: (value) {
            setState(() => _selectedFarmer = value);
          },
          onNext: () {
            setState(() => _currentPageIndex = 1);
          },
        );
      case 1:
        return SingleChildScrollView(
          child: ConsentPage(
            interviewStartTime: _surveyState.interviewStartTime,
            timeStatus: _surveyState.timeStatus,
            currentPosition: _surveyState.currentPosition,
            locationStatus: _surveyState.locationStatus,
            isGettingLocation: _surveyState.isGettingLocation,
            communityType: _communityType,
            residesInCommunityConsent: _residesInCommunityConsent,
            farmerAvailable: _farmerAvailable,
            farmerStatus: _farmerStatus,
            availablePerson: _availablePerson,
            otherSpecification: _otherSpecification,
            otherCommunityName: _otherCommunityName,
            consentGiven: _consentGiven,
            otherSpecController: _otherSpecController,
            otherCommunityController: _otherCommunityController,
            onRecordTime: _recordInterviewTime,
            onGetLocation: _getCurrentLocation,
            onCommunityTypeChanged: (value) {
              setState(() => _communityType = value);
            },
            onResidesInCommunityChanged: (value) {
              setState(() => _residesInCommunityConsent = value);
            },
            onFarmerAvailableChanged: (value) {
              setState(() => _farmerAvailable = value);
            },
            onFarmerStatusChanged: (value) {
              setState(() => _farmerStatus = value);
            },
            onAvailablePersonChanged: (value) {
              setState(() => _availablePerson = value);
            },
            onOtherSpecChanged: (value) {
              setState(() => _otherSpecification = value);
            },
            onOtherCommunityChanged: (value) {
              setState(() => _otherCommunityName = value);
            },
            onConsentChanged: (value) {
              setState(() => _consentGiven = value);
            },
            onNext: () {
              setState(() => _currentPageIndex = 2);
            },
          ),
        );
      case 2:
        return const FarmerIdentificationPage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget _buildNavigationButtons() {
    if (_currentPageIndex == 0) return const SizedBox.shrink();

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
                onPressed: () {
                  setState(() {
                    _currentPageIndex--;
                  });
                },
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
                onPressed: _currentPageIndex == _totalPages - 1
                    ? _submitForm
                    : () {
                        setState(() {
                          _currentPageIndex++;
                        });
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
                      _currentPageIndex == _totalPages - 1 ? 'Submit' : 'Next',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (_currentPageIndex < _totalPages - 1) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios,
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

  @override
  void dispose() {
    _otherSpecController.dispose();
    _otherCommunityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
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
              _currentPageIndex == 0
                  ? 'Cover Page'
                  : _currentPageIndex == 1
                      ? 'Consent Form'
                      : 'Farmer Identification',
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
        foregroundColor: Colors.white,
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
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildNavigationButtons(),
    );
  }
}
