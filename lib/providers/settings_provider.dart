import 'package:flutter/foundation.dart';

/// Demo/display toggles from the Settings screen, shared app-wide so Home
/// can actually react to them (e.g. hide the mode chip for a clean demo).
class SettingsProvider extends ChangeNotifier {
  bool _hideModeChip = false;
  bool _hapticOnModeChange = true;
  bool _useLocalOsmExtract = false;

  bool get hideModeChip => _hideModeChip;
  bool get hapticOnModeChange => _hapticOnModeChange;
  bool get useLocalOsmExtract => _useLocalOsmExtract;

  void setHideModeChip(bool value) {
    _hideModeChip = value;
    notifyListeners();
  }

  void setHapticOnModeChange(bool value) {
    _hapticOnModeChange = value;
    notifyListeners();
  }

  void setUseLocalOsmExtract(bool value) {
    _useLocalOsmExtract = value;
    notifyListeners();
  }
}
