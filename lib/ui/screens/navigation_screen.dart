import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/navigation/navigation_state.dart';
import '../../providers/navigation_provider.dart';
import '../widgets/hud_overlay.dart';
import '../widgets/outage_button.dart';
import '../widgets/status_pill.dart';

/// The primary navigation screen rendering the live map and telemetry HUD.
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // 1. OpenStreetMap Vector / Raster Layer (Free-only, no API key)
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: provider.currentPosition,
                  initialZoom: 16.5,
                  minZoom: 12.0,
                  maxZoom: 19.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.reckon.ai',
                    tileBuilder: (context, tileWidget, tile) {
                      // Apply dark theme color filter to standard OSM raster tiles
                      return ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          -0.8, 0, 0, 0, 240,
                          0, -0.8, 0, 0, 240,
                          0, 0, -0.8, 0, 240,
                          0, 0, 0, 1.0, 0,
                        ]),
                        child: tileWidget,
                      );
                    },
                  ),

                  // 2. Trajectory Polylines
                  PolylineLayer(
                    polylines: [
                      // Historical GPS True Trail (Emerald Green)
                      if (provider.gpsTrail.length > 1)
                        Polyline(
                          points: provider.gpsTrail,
                          strokeWidth: 4.0,
                          color: AppColors.pathGpsTrue,
                        ),

                      // Dead-Reckoned Path (Cyan)
                      if (provider.drTrail.length > 1)
                        Polyline(
                          points: provider.drTrail,
                          strokeWidth: 4.5,
                          color: AppColors.pathReckonAi,
                        ),

                      // Naive Physics Drift Path (Red / Divergent)
                      if (provider.naiveDriftTrail.length > 1)
                        Polyline(
                          points: provider.naiveDriftTrail,
                          strokeWidth: 2.5,
                          color: AppColors.pathNaiveDrift.withOpacity(0.8),
                          isDotted: true,
                        ),
                    ],
                  ),

                  // 3. Vehicle Marker Puck (Pulsing Circle + Heading Arrow)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: provider.currentPosition,
                        width: 44,
                        height: 44,
                        child: Transform.rotate(
                          angle: provider.currentHeadingDeg * (pi / 180.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: provider.mode.color.withOpacity(0.2),
                                  border: Border.all(
                                    color: provider.mode.color,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.navigation,
                                size: 22,
                                color: provider.mode.color,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 4. Top App Bar & Status Pill
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusPill(
                        mode: provider.mode,
                        onTap: () {
                          // Center map on vehicle
                          _mapController.move(provider.currentPosition, 16.5);
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGlass,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border.withOpacity(0.5)),
                        ),
                        child: Text(
                          provider.inferenceEngine.name.contains('Stub') ? 'STUB MOCK' : 'TFLite v1',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Floating Outage Action Button
              Positioned(
                bottom: 110,
                right: 16,
                child: OutageSimulatorButton(
                  isOutageActive: provider.mode == NavigationMode.deadReckoning,
                  onTrigger: () => provider.simulateOutage(durationSeconds: 15),
                  onCancel: () => provider.endOutage(),
                ),
              ),

              // 6. Cockpit HUD Overlay
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: HudOverlay(
                  speedKmh: provider.speedKmh,
                  headingDeg: provider.currentHeadingDeg,
                  mode: provider.mode,
                  outageRemainingSeconds: provider.outageRemainingSeconds,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
