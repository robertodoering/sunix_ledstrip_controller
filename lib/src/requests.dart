import 'package:sunix_ledstrip_controller/src/checksum.dart';

const localGateway = 0x0F;
const remoteGateway = 0xF0;

const powerStateOn = 0x23;
const powerStateOff = 0x24;

/// A request for the led controller.
abstract class LedRequest {
  /// Contains the data of a request package.
  List<int> data = [];

  /// Flag to signify the [LedController] to wait for a response after sending
  /// the request.
  bool waitForResponse = false;

  @override
  String toString() => data.map((value) => value.toRadixString(16)).toString();
}

/// Request for changing the color for the controller.
///
/// Throws an [ArgumentError] if any color is invalid.
class UpdateColorRequest extends LedRequest {
  static const selectionRgb = 0xF0;
  static const selectionWw = 0x0F;
  static const selectionRgbww = 0xFF;

  /// The identifier for the request.
  static const packetId = 0x31;

  /// The color values.
  int red = 0x00;
  int green = 0x00;
  int blue = 0x00;
  int warmWhite = 0x00;
  int coldWhite = 0x00;

  /// Specifies which colors to use.
  ///
  /// 0xF0: Only update [red], [green], [blue].
  /// 0x0F: Only update [warmWhite], [coldWhite].
  /// 0xFF: Update all.
  /// 0x00: Update none.
  int rgbwwSelection = selectionRgb;

  /// Specifies if the gateway is accessible locally or remotely.
  ///
  /// The remote value is only used by the official app.
  /// 0x0F: Local.
  /// 0xF0: Remote.
  int remoteOrLocal = localGateway;

  UpdateColorRequest.rgb({
    this.red,
    this.green,
    this.blue,
  }) : rgbwwSelection = selectionRgb {
    _addData();
  }

  UpdateColorRequest.ww({
    this.warmWhite,
    this.coldWhite,
  }) : rgbwwSelection = selectionWw {
    _addData();
  }

  UpdateColorRequest.rgbww({
    this.red,
    this.green,
    this.blue,
    this.warmWhite,
    this.coldWhite,
  }) : rgbwwSelection = selectionRgbww {
    _addData();
  }

  void _addData() {
    _validateColors();

    data
      ..add(packetId)
      ..add(red)
      ..add(green)
      ..add(blue)
      ..add(warmWhite)
      ..add(coldWhite)
      ..add(rgbwwSelection)
      ..add(remoteOrLocal)
      ..add(calculateChecksum(data));
  }

  /// Throws an [ArgumentError] if any color is invalid.
  void _validateColors() {
    final colors = <int>[
      red,
      green,
      blue,
      warmWhite,
      coldWhite,
    ];

    final invalidColors = colors
        .where((value) => value != null ? value < 0 || value > 255 : false);

    if (invalidColors.isNotEmpty) {
      throw ArgumentError('Invalid color range for $invalidColors.');
    }
  }

  @override
  String toString() => 'Update color request: ${super.toString()}';
}

/// Request for changing the power state of the controller.
class SetPowerRequest extends LedRequest {
  static const packetId = 0x71;

  int powerStatus = powerStateOff;
  int remoteOrLocal = localGateway;

  SetPowerRequest.on() {
    powerStatus = powerStateOn;
    _addData();
  }

  SetPowerRequest.off() {
    powerStatus = powerStateOff;
    _addData();
  }

  void _addData() {
    data
      ..add(packetId)
      ..add(powerStatus)
      ..add(remoteOrLocal)
      ..add(calculateChecksum(data));
  }

  @override
  String toString() => 'Set power request: ${super.toString()}';
}

/// Request for the current status of the controller.
class StatusRequest extends LedRequest {
  static const packetId = 0x81;

  int payload1 = 0x8A;
  int payload2 = 0x8B;

  StatusRequest() {
    waitForResponse = true;

    data
      ..add(packetId)
      ..add(payload1)
      ..add(payload2)
      ..add(calculateChecksum(data));
  }

  @override
  String toString() => 'Status request: ${super.toString()}';
}
