import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Tactile feedback that actually fires on Android.
///
/// Flutter's [HapticFeedback] rides the system "touch feedback" channel,
/// which many Android phones ship disabled or barely perceptible. On
/// Android we drive the vibrator directly with short amplitude-controlled
/// pulses; iOS keeps the Taptic engine via [HapticFeedback]; web and
/// desktop are no-ops.
class Haptics {
  Haptics._();

  static bool _android = false;
  static bool _amplitude = false;
  static bool _ready = false;

  static Future<void> init() async {
    if (kIsWeb) return;
    _android = defaultTargetPlatform == TargetPlatform.android;
    if (_android) {
      try {
        _android = await Vibration.hasVibrator();
        _amplitude = await Vibration.hasAmplitudeControl();
      } catch (_) {
        _android = false;
      }
    }
    _ready = true;
  }

  static Future<void> _pulse(int ms, int amp) async {
    if (!_ready || kIsWeb) return;
    if (_android) {
      await Vibration.vibrate(duration: ms, amplitude: _amplitude ? amp : -1);
    }
  }

  static Future<void> _pattern(List<int> pattern, List<int> amps) async {
    if (!_ready || kIsWeb) return;
    if (_android) {
      await Vibration.vibrate(
        pattern: pattern,
        intensities: _amplitude ? amps : const [],
      );
    }
  }

  /// Placing or lifting a tube.
  static Future<void> tap() async {
    if (_android) return _pulse(18, 110);
    return HapticFeedback.selectionClick();
  }

  /// A button press.
  static Future<void> press() async {
    if (_android) return _pulse(25, 150);
    return HapticFeedback.lightImpact();
  }

  /// Motor engages.
  static Future<void> spinUp() async {
    if (_android) return _pulse(45, 200);
    return HapticFeedback.mediumImpact();
  }

  /// Rotor coasts to a stop.
  static Future<void> stop() async {
    if (_android) return _pulse(70, 255);
    return HapticFeedback.heavyImpact();
  }

  /// Three knocks: the rotor hitting its housing.
  static Future<void> knock() async {
    if (_android) {
      return _pattern(
        const [0, 70, 90, 70, 90, 110],
        const [0, 255, 0, 255, 0, 255],
      );
    }
    for (final ms in const [0, 130, 280]) {
      await Future<void>.delayed(Duration(milliseconds: ms));
      await HapticFeedback.heavyImpact();
    }
  }
}
