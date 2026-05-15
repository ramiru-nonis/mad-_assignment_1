import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  // ─── Geolocation ─────────────────────────────────────────────────────────────
  String _locationStatus = 'Tap to get location';
  double? _lat;
  double? _lng;
  bool _loadingLocation = false;

  // ─── Accelerometer ───────────────────────────────────────────────────────────
  double _accX = 0, _accY = 0, _accZ = 0;
  StreamSubscription<AccelerometerEvent>? _accSub;
  bool _shakeDetected = false;
  static const double _shakeThreshold = 20.0;

  // ─── Connectivity ─────────────────────────────────────────────────────────────
  List<ConnectivityResult> _connectivity = [];
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  // ─── Contacts ─────────────────────────────────────────────────────────────────
  List<Contact>? _contacts;
  bool _contactsPermissionDenied = false;
  bool _loadingContacts = false;

  @override
  void initState() {
    super.initState();
    _startAccelerometer();
    _startConnectivity();
  }

  @override
  void dispose() {
    _accSub?.cancel();
    _connSub?.cancel();
    super.dispose();
  }

  // ─── Accelerometer ───────────────────────────────────────────────────────────

  void _startAccelerometer() {
    _accSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      setState(() {
        _accX = event.x;
        _accY = event.y;
        _accZ = event.z;
      });
      // Shake detection
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > _shakeThreshold && !_shakeDetected) {
        if (!mounted) return;
        _shakeDetected = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.refresh, color: Colors.white),
              SizedBox(width: 8),
              Text('Shake detected! Refreshing data...'),
            ]),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.deepPurple,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _shakeDetected = false);
        });
      }
    });
  }

  // ─── Connectivity ─────────────────────────────────────────────────────────────

  void _startConnectivity() {
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      setState(() => _connectivity = results);
    });
    Connectivity().checkConnectivity().then((r) {
      setState(() => _connectivity = r);
    });
  }

  String _connectivityLabel() {
    if (_connectivity.isEmpty) return 'Checking...';
    if (_connectivity.contains(ConnectivityResult.wifi)) return 'Wi-Fi';
    if (_connectivity.contains(ConnectivityResult.mobile)) return 'Mobile Data';
    if (_connectivity.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    return 'No Connection';
  }

  Color _connectivityColor() {
    if (_connectivity.isEmpty) return Colors.grey;
    if (_connectivity.contains(ConnectivityResult.none)) return Colors.red;
    return Colors.green;
  }

  // ─── Contacts ─────────────────────────────────────────────────────────────────

  Future<void> _fetchContacts() async {
    setState(() {
      _loadingContacts = true;
      _contactsPermissionDenied = false;
    });

    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _loadingContacts = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _contactsPermissionDenied = true;
          _loadingContacts = false;
        });
      }
    }
  }

  // ─── Geolocation ─────────────────────────────────────────────────────────────

  Future<void> _getLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationStatus = 'Requesting permission...';
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationStatus = 'Location services are disabled.';
        _loadingLocation = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationStatus = 'Location permission denied.';
          _loadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationStatus = 'Location permission permanently denied.';
        _loadingLocation = false;
      });
      return;
    }

    setState(() => _locationStatus = 'Getting position...');
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _locationStatus = 'Location retrieved';
        _loadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Error: ${e.toString()}';
        _loadingLocation = false;
      });
    }
  }

  // ─── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Info'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Connectivity Card ──
          _SectionCard(
            icon: Icons.wifi,
            title: 'Network Connectivity',
            color: Colors.blue,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _connectivityColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _connectivityLabel(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _connectivityColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Raw: ${_connectivity.map((r) => r.name).join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Contacts Card ──
          _SectionCard(
            icon: Icons.contacts,
            title: 'Contacts Info',
            color: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_contactsPermissionDenied)
                  Text(
                    'Permission denied. Cannot access contacts.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  )
                else if (_contacts != null) ...[
                  Text(
                    'Total Contacts: ${_contacts!.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_contacts!.isNotEmpty) ...[
                    Text(
                      'Sample Contacts:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._contacts!.take(3).map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(c.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              if (c.phones.isNotEmpty)
                                Text(c.phones.first.number,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        )),
                  ]
                ] else
                  Text(
                    'Tap below to fetch contacts from your device.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loadingContacts ? null : _fetchContacts,
                    icon: _loadingContacts
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.import_contacts),
                    label: Text(_contacts == null ? 'Get Contacts' : 'Refresh Contacts'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Geolocation Card ──
          _SectionCard(
            icon: Icons.location_on,
            title: 'Geolocation (GPS)',
            color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_lat != null && _lng != null) ...[
                  _CoordRow(label: 'Latitude', value: _lat!.toStringAsFixed(6)),
                  const SizedBox(height: 6),
                  _CoordRow(label: 'Longitude', value: _lng!.toStringAsFixed(6)),
                  const SizedBox(height: 12),
                ] else ...[
                  Text(
                    _locationStatus,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loadingLocation ? null : _getLocation,
                    icon: _loadingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(_lat == null ? 'Get My Location' : 'Refresh Location'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Accelerometer Card ──
          _SectionCard(
            icon: Icons.screen_rotation,
            title: 'Accelerometer',
            color: Colors.deepPurple,
            child: Column(
              children: [
                _AccBar(label: 'X', value: _accX, color: Colors.red),
                const SizedBox(height: 10),
                _AccBar(label: 'Y', value: _accY, color: Colors.green),
                const SizedBox(height: 10),
                _AccBar(label: 'Z', value: _accZ, color: Colors.blue),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.vibration, size: 18, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text(
                        'Shake your device to refresh products!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _CoordRow extends StatelessWidget {
  final String label;
  final String value;
  const _CoordRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }
}

class _AccBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _AccBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final clamped = (value.abs() / 20.0).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          child: Text(
            value.toStringAsFixed(2),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
