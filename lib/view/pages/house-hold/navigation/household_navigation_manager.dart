import 'package:flutter/material.dart';

/// Manages all navigation-related logic for the household survey
class SurveyNavigationManager {
  final PageController pageController;
  final VoidCallback onStateUpdate;

  int _currentPageIndex = 0;
  int _combinedPageSubIndex = 0;
  final int totalPages = 10;
  final int totalCombinedSubPages = 4;

  SurveyNavigationManager({
    required this.pageController,
    required this.onStateUpdate,
  });

  // Getters
  int get currentPageIndex => _currentPageIndex;
  int get combinedPageSubIndex => _combinedPageSubIndex;
  bool get isOnCombinedPage => _currentPageIndex == 3;
  bool get isLastPage => _currentPageIndex == totalPages - 1;
  bool get isLastSubPage => _combinedPageSubIndex == totalCombinedSubPages - 1;
  double get progress => (_currentPageIndex + 1) / totalPages;

  // Setters with state updates
  set currentPageIndex(int value) {
    _currentPageIndex = value;
    onStateUpdate();
  }

  set combinedPageSubIndex(int value) {
    _combinedPageSubIndex = value;
    onStateUpdate();
  }

  /// Navigate to a specific page index
  Future<void> navigateToPage(int pageIndex, {bool animate = true}) async {
    if (pageIndex < 0 || pageIndex >= totalPages) {
      debugPrint('❌ Invalid page index: $pageIndex');
      return;
    }

    if (!pageController.hasClients) {
      debugPrint('❌ PageController has no clients');
      return;
    }

    try {
      if (animate) {
        await pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        pageController.jumpToPage(pageIndex);
      }

      _currentPageIndex = pageIndex;
      onStateUpdate();

      debugPrint('✅ Navigated to page: $pageIndex');
    } catch (e, stackTrace) {
      debugPrint('❌ Error navigating to page $pageIndex: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Navigate to the next page
  Future<void> navigateToNext() async {
    if (_currentPageIndex < totalPages - 1) {
      await navigateToPage(_currentPageIndex + 1);
    } else {
      debugPrint('ℹ️ Already on last page');
    }
  }

  /// Navigate to the previous page
  Future<void> navigateToPrevious() async {
    if (_currentPageIndex > 0) {
      await navigateToPage(_currentPageIndex - 1);
    } else {
      debugPrint('ℹ️ Already on first page');
    }
  }

  /// Navigate to next sub-page in combined page
  Future<void> navigateToNextSubPage() async {
    if (!isOnCombinedPage) {
      debugPrint('❌ Not on combined page');
      return;
    }

    if (_combinedPageSubIndex < totalCombinedSubPages - 1) {
      _combinedPageSubIndex++;
      onStateUpdate();
      debugPrint('✅ Moved to sub-page: $_combinedPageSubIndex');
    } else {
      debugPrint('ℹ️ Already on last sub-page, moving to next main page');
      await navigateToNext();
    }
  }

  /// Navigate to previous sub-page in combined page
  Future<void> navigateToPreviousSubPage() async {
    if (!isOnCombinedPage) {
      debugPrint('❌ Not on combined page');
      return;
    }

    if (_combinedPageSubIndex > 0) {
      _combinedPageSubIndex--;
      onStateUpdate();
      debugPrint('✅ Moved to previous sub-page: $_combinedPageSubIndex');
    } else {
      debugPrint('ℹ️ Already on first sub-page, moving to previous main page');
      await navigateToPrevious();
    }
  }

  /// Jump to a specific sub-page in combined page
  void jumpToSubPage(int subPageIndex) {
    if (!isOnCombinedPage) {
      debugPrint('❌ Not on combined page');
      return;
    }

    if (subPageIndex >= 0 && subPageIndex < totalCombinedSubPages) {
      _combinedPageSubIndex = subPageIndex;
      onStateUpdate();
      debugPrint('✅ Jumped to sub-page: $subPageIndex');
    } else {
      debugPrint('❌ Invalid sub-page index: $subPageIndex');
    }
  }

  /// Reset navigation state to initial values
  void reset() {
    _currentPageIndex = 0;
    _combinedPageSubIndex = 0;
    onStateUpdate();
    debugPrint('🔄 Navigation state reset');
  }

  /// Get page title based on current navigation state
  String getPageTitle() {
    if (isOnCombinedPage) {
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
      'Child Details',
      'Remediation',
      'Sensitization',
      'Sensitization Questions',
      'End of Collection'
    ];

    if (_currentPageIndex >= 0 && _currentPageIndex < titles.length) {
      return titles[_currentPageIndex];
    }
    return 'Household Survey';
  }

  /// Get next button text based on current state
  String getNextButtonText() {
    if (isLastPage) {
      return 'Submit';
    }

    if (isOnCombinedPage) {
      return isLastSubPage
          ? 'Next Page'
          : 'Next (${_combinedPageSubIndex + 2}/4)';
    }

    return 'Next';
  }

  /// Check if previous button should be visible
  bool get shouldShowPreviousButton {
    if (isOnCombinedPage) {
      return _combinedPageSubIndex > 0 || _currentPageIndex > 0;
    }
    return _currentPageIndex > 0;
  }

  /// Get the current progress description
  String get progressDescription {
    return 'Page ${_currentPageIndex + 1} of $totalPages';
  }

  /// Debug information about current navigation state
  void debugPrintState() {
    debugPrint('=== NAVIGATION STATE ===');
    debugPrint('Current Page: $_currentPageIndex');
    debugPrint('Combined Sub-page: $_combinedPageSubIndex');
    debugPrint('Is On Combined Page: $isOnCombinedPage');
    debugPrint('Is Last Page: $isLastPage');
    debugPrint('Is Last Sub-page: $isLastSubPage');
    debugPrint('Progress: ${(progress * 100).toStringAsFixed(1)}%');
    debugPrint('Page Title: ${getPageTitle()}');
    debugPrint('Next Button Text: ${getNextButtonText()}');
    debugPrint('Show Previous Button: $shouldShowPreviousButton');
    debugPrint('========================');
  }

  /// Validate if navigation to a specific page is possible
  bool canNavigateToPage(int pageIndex) {
    return pageIndex >= 0 && pageIndex < totalPages;
  }

  /// Validate if navigation to a specific sub-page is possible
  bool canNavigateToSubPage(int subPageIndex) {
    return isOnCombinedPage &&
        subPageIndex >= 0 &&
        subPageIndex < totalCombinedSubPages;
  }

  /// Get all available page indices (for debugging/testing)
  List<int> get availablePageIndices {
    return List.generate(totalPages, (index) => index);
  }

  /// Get all available sub-page indices (for debugging/testing)
  List<int> get availableSubPageIndices {
    return List.generate(totalCombinedSubPages, (index) => index);
  }
}
