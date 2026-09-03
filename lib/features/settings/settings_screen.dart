import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_panel.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionLabel('Demo'),
            GlassPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    activeThumbColor: AppColors.gps,
                    title: const Text('Hide mode chip'),
                    subtitle: const Text('For a pure "look, it\'s seamless" demo moment'),
                    value: settings.hideModeChip,
                    onChanged: settings.setHideModeChip,
                  ),
                  const Divider(height: 1, color: AppColors.hairline),
                  SwitchListTile(
                    activeThumbColor: AppColors.gps,
                    title: const Text('Haptic on mode change'),
                    value: settings.hapticOnModeChange,
                    onChanged: settings.setHapticOnModeChange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Map'),
            GlassPanel(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                activeThumbColor: AppColors.gps,
                title: const Text('Use local OSM extract'),
                subtitle: const Text(
                  'For offline demo routes with no network — see open question in Project-Context §10',
                ),
                value: settings.useLocalOsmExtract,
                onChanged: settings.setUseLocalOsmExtract,
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('About'),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reckon', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Running against a stub model until model-v1 is exported from the '
                    'Reckon-AI training repo. See Project-Context/01-MOBILE-APP-CONTEXT.md.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              letterSpacing: 1.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
