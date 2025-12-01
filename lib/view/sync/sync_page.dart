import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_rights_monitor/controller/api/get_methods.dart';
import 'package:human_rights_monitor/controller/connectivity_verify/connectivity_verify.dart';
import 'package:human_rights_monitor/view/screen_wrapper/screen_wrapper.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  _SyncPageState createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isSyncing = false;
  int _retryCount = 0;
  // CmUser? userInfo;
  final Set<int> _failedSteps = {};
  final Map<int, String> _syncStatusMessages = {};
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Future<void> Function()> _syncFunctions = [
    () => GetService().fetchFarmers(),
    () => GetService().fetchDistricts(),
  ];

  final List<String> syncTitles = [
    "Farmer Data",
    "District Data",

  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _startSync();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startSync({bool retryOnlyFailed = false}) async {
    // Check connection
    final hasConnection = await ConnectionVerify.connectionIsAvailable();
    if (!hasConnection) {
      if (mounted) {
        Get.offAll(() => ScreenWrapper());
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSyncing = true;
        if (!retryOnlyFailed) {
          _currentStep = 0;
          _failedSteps.clear();
          _syncStatusMessages.clear();
          _retryCount = 0;
        }
      });
      _animationController.reset();
      _animationController.forward();
    }

    try {
      List<int> stepsToSync = retryOnlyFailed
          ? _failedSteps.toList()
          : List.generate(_syncFunctions.length, (index) => index);

      _failedSteps.clear();

      for (int i in stepsToSync) {
        if (!mounted) return;

        if (mounted) {
          setState(() {
            _syncStatusMessages[i] = "Syncing...";
          });
        }

        try {
          await _syncFunctions[i]();
          if (mounted) {
            setState(() {
              _syncStatusMessages[i] = "Success";
            });
          }
        } catch (e) {
          debugPrint('Error in sync step $i: $e');
          if (mounted) {
            setState(() {
              _syncStatusMessages[i] = "Failed: ${e.toString().split('\n').first}";
              _failedSteps.add(i);
            });
          }
        }

        if (mounted) {
          setState(() {
            _currentStep = i;
          });
        }
      }

      // Handle completion
      if (!mounted) return;

      setState(() {
        _isSyncing = false;
      });

      if (_failedSteps.isEmpty) {
        // Success case - navigate to home
        debugPrint('Sync completed successfully, navigating to home');
        if (Get.isSnackbarOpen) {
          await Get.closeCurrentSnackbar();
        }
        if (mounted) {
          Get.offAll(() => ScreenWrapper());
        }
      } else if (_retryCount < 2) {
        // Retry failed steps
        _retryCount++;
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          _startSync(retryOnlyFailed: true);
        }
      } else {
        // Max retries reached
        debugPrint('Max retries reached, showing error');
        if (Get.isSnackbarOpen) {
          await Get.closeCurrentSnackbar();
        }
        Get.snackbar(
          'Sync Incomplete',
          'Some data failed to sync. Please check your connection and try again.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          Get.offAll(() => ScreenWrapper());
        }
      }
    } catch (e) {
      debugPrint('Unexpected error in _startSync: $e');
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
        Get.offAll(() => ScreenWrapper());
      }
    }
  }

  // Future<void> fetchUserInfo() async {
  //   userInfo = await UserInfoApiInterface().retrieveUserInfoFromSharedPrefs();
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // backgroundColor: theme.colorScheme.secondary,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        title: Text(
          "Data Synchronization",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
          onPressed: () => Get.offAll(() => ScreenWrapper()),
        ),
      ),
      body: Column(
        children: [
          if (_isSyncing)
            LinearProgressIndicator(
              value: _currentStep / _syncFunctions.length,
              backgroundColor: theme.colorScheme.secondary,
              color: theme.primaryColor,
              minHeight: 4,
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _animation.value)),
                      child: child,
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.sync,
                              color: theme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Sync Progress",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "${_currentStep + 1}/${_syncFunctions.length}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _syncFunctions.length,
                            itemBuilder: (context, index) {
                              final isFailed = _failedSteps.contains(index);
                              final isSynced = _syncStatusMessages[index] == "Success";
                              final isSyncing = _syncStatusMessages[index] == "Syncing...";
                              final isPending = _syncStatusMessages[index] == null;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isFailed
                                      ? theme.colorScheme.error.withOpacity(0.1)
                                      : isSynced
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isFailed
                                        ? theme.colorScheme.error.withOpacity(0.3)
                                        : isSynced
                                        ? Colors.green.withOpacity(0.3)
                                        : theme.colorScheme.outline.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isFailed
                                            ? theme.colorScheme.error
                                            : isSynced
                                            ? Colors.green
                                            : isSyncing
                                            ? theme.primaryColor
                                            : theme.colorScheme.outline.withOpacity(0.3),
                                      ),
                                      child: Center(
                                        child: isSyncing
                                            ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                        )
                                            : Icon(
                                          isFailed
                                              ? Icons.error_outline
                                              : isSynced
                                              ? Icons.check
                                              : Icons.circle,
                                          color: theme.colorScheme.onPrimary,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            syncTitles[index],
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          if (_syncStatusMessages[index] != null && _syncStatusMessages[index] != "Success")
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                _syncStatusMessages[index]!,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: isFailed
                                                      ? theme.colorScheme.error
                                                      : theme.colorScheme.onSurface.withOpacity(0.6),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (index <= _currentStep && !isFailed && !isSynced)
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            theme.primaryColor,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_failedSteps.isNotEmpty && _retryCount < 2)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh, size: 20),
                      label: Text(
                        "Retry Failed (${2 - _retryCount} attempts left)",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: theme.colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _startSync(retryOnlyFailed: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text(
                        "Continue Anyway",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                        side: BorderSide(color: theme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // fetchUserInfo();
                        Get.offAll(() => ScreenWrapper());
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}