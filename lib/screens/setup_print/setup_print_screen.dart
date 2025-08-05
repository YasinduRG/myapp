import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/util/snack_bar.dart';
import 'package:myapp/widgets/app_footer.dart';
import 'package:permission_handler/permission_handler.dart';

class SetupPrintScreen extends StatefulWidget {
  const SetupPrintScreen({super.key});

  @override
  State<SetupPrintScreen> createState() => _SetupPrintScreenState();
}

class _SetupPrintScreenState extends State<SetupPrintScreen> {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  List<ScanResult> _scanResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Request permissions when the screen loads
    _requestPermissions();
  }

  @override
  void dispose() {
    // Clean up resources
    _stopSearch();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    // Request Bluetooth and Location permissions
    await [
      Permission.bluetooth,
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

// RECOMMENDED: A more robust way to handle starting a scan
Future<void> _startSearch() async {
  // 1. First, check permissions
  var scanStatus = await Permission.bluetoothScan.status;
  var locationStatus = await Permission.location.status;

  if (!scanStatus.isGranted || !locationStatus.isGranted) {
    // If permissions are not granted, request them
    final statuses = await [
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    // Check again after requesting
    if (!statuses[Permission.bluetoothScan]!.isGranted || !statuses[Permission.location]!.isGranted) {
      // If the user *still* denies permissions, show an informative message.
      if (mounted) {
          showSnackBar(
          message: 'Bluetooth Scan and Location permissions are required to find devices.',
          type: MessageType.warning, // Use 'warning' to inform the user of a prerequisite.
          );
      }
      return; // Exit the function
    }
  }

  // 2. If we get here, permissions are granted. Now check if Bluetooth is ON.
  if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
    if (mounted) {
        showSnackBar(
        message: 'Please turn on Bluetooth to scan for devices.',
        type: MessageType.warning, // 'warning' is also appropriate here.
        );
    }
    return; // Exit the function
  }

  // 3. Start the scan
  setState(() {
    _isSearching = true;
    _scanResults.clear();
  });

  try {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  } catch (e) {
    //print("ERROR starting scan: $e");
    setState(() => _isSearching = false);
  }

  // Listen to results
  _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
    setState(() {
      // Create a Set of existing device IDs to avoid duplicates
      final existingIds = _scanResults.map((r) => r.device.remoteId).toSet();
      // Add new, unique results with a non-empty name
      _scanResults.addAll(
        results.where(
          (r) => !existingIds.contains(r.device.remoteId) && r.device.platformName.isNotEmpty,
        ),
      );
    });
  });

  _scanSubscription?.onDone(() => setState(() => _isSearching = false));
}

  void _stopSearch() {
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    setState(() {
      _isSearching = false;
    });
  }

  // Placeholder for connection logic
  Future<void> _connect(BluetoothDevice device) async {
    _stopSearch(); // Stop scanning before connecting
    // In a real app, you would implement connection logic here
    print('Connecting to ${device.platformName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // This SizedBox acts as a spacer at the top
              const SizedBox(height: 16),
              // Main content card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Text('Bluetooth', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 48), // Spacer to balance the back button
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            // Connect via text field (UI only for now)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.usb, color: AppColors.white, size: 20),
                                  label: const Text('Connect', style: TextStyle(color: AppColors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Action Buttons
                            _buildActionButton(icon: Icons.print, label: 'Test Print', color: AppColors.success, onPressed: () {}),
                            const SizedBox(height: 12),
                            _isSearching
                                ? _buildActionButton(icon: Icons.stop_circle, label: 'Stop Searching', color: AppColors.danger, onPressed: _stopSearch)
                                : _buildActionButton(icon: Icons.bluetooth_searching, label: 'Search Bluetooth Devices', color: AppColors.primary, onPressed: _startSearch),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Discovered devices list
                      Expanded(
                        child: _scanResults.isEmpty && _isSearching
                            ? const Center(child: CircularProgressIndicator())
                            : _scanResults.isEmpty
                                ? const Center(child: Text('No devices found.'))
                                : ListView.builder(
                                    itemCount: _scanResults.length,
                                    itemBuilder: (context, index) {
                                      final result = _scanResults[index];
                                      return ListTile(
                                        title: Text(result.device.platformName),
                                        subtitle: Text(result.device.remoteId.toString()),
                                        onTap: () => _connect(result.device),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const AppFooter(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for styled buttons
  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}