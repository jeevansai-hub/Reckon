import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_panel.dart';
import '../../providers/navigation_provider.dart';
import '../settings/settings_screen.dart';
import '../trip_summary/trip_summary_screen.dart';
import 'widgets/mode_chip.dart';
import 'widgets/outage_control_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mapController = MapController();
  bool _followVehicle = true;

  void _openOutageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: OutageControlSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final accent = AppColors.modeColor(nav.mode.key);

    if (_followVehicle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(nav.position, _mapController.camera.zoom);
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: nav.position,
              initialZoom: 16,
              onPositionChanged: (_, gesture) {
                if (gesture) setState(() => _followVehicle = false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.reckon.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(points: nav.path, strokeWidth: 4, color: accent.withValues(alpha: 0.85)),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: nav.position,
                    width: 44,
                    height: 44,
                    child: _VehicleMarker(color: accent, heading: nav.heading),
                  ),
                ],
              ),
            ],
          ),

          // Top bar: mode chip + settings.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ModeChip(mode: nav.mode),
                  _CircleIconButton(
                    icon: Icons.tune_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom overlay: trip distance + outage control + trip summary shortcut.
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.route_rounded, color: accent, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            '${(nav.tripDistanceMetres / 1000).toStringAsFixed(2)} km this trip',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TripSummaryScreen()),
                            ),
                            child: const Text('Trip summary'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _CircleIconButton(
                          icon: Icons.my_location_rounded,
                          onTap: () => setState(() => _followVehicle = true),
                        ),
                        const SizedBox(width: 12),
                        FloatingActionButton.extended(
                          onPressed: _openOutageSheet,
                          backgroundColor: AppColors.sensorOnly,
                          foregroundColor: AppColors.background,
                          icon: const Icon(Icons.wifi_off_rounded),
                          label: const Text('Simulate outage'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleMarker extends StatelessWidget {
  const _VehicleMarker({required this.color, required this.heading});
  final Color color;
  final double heading;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: heading, end: heading),
      builder: (context, value, child) => Transform.rotate(angle: value, child: child),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.18),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 14, spreadRadius: 2)],
        ),
        child: Icon(Icons.navigation_rounded, color: color, size: 22),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 999,
      padding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Icon(icon, size: 20),
      ),
    );
  }
}
