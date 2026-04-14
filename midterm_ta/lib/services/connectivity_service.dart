import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late List<ConnectivityResult> _connectionStatus;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  ConnectivityService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen((result) {
      _connectionStatus = result;
      _updateConnectionStatus();
    });
  }

  Future<void> _initConnectivity() async {
    try {
      _connectionStatus = await _connectivity.checkConnectivity();
      _updateConnectionStatus();
    } catch (e) {
      _isOnline = false;
    }
  }

  void _updateConnectionStatus() {
    _isOnline = _connectionStatus.any(
      (status) => status != ConnectivityResult.none,
    );
    notifyListeners();
  }
}
