import 'package:sunix_ledstrip_controller/src/checksum.dart';
import 'package:sunix_ledstrip_controller/src/requests.dart';

/// A response from the led controller.
///
/// Uses the overridden [_dataMap] to parse the [data] in the [parse] function.
/// If the checksum is valid [valid] will be true, false otherwise.
abstract class LedResponse {
  Map<String, int> _dataMap = {};

  bool get valid => evaluateChecksum(_dataMap.values);

  /// Parses the data and maps it in the [_dataMap].
  ///
  /// Throws a [ResponseParserException] if the response length does not match
  /// the expected length from the [_dataMap] or if the checksum is invalid.
  void parse(List<int> data) {
    if (_dataMap.length != data.length) {
      throw ResponseParserException("Response length mismatch.\n"
          "Expected length: ${_dataMap.length}.\n"
          "Received length: ${data.length}");
    }

    if (!evaluateChecksum(data)) {
      throw ResponseParserException("Invalid response checksum");
    }

    for (int i = 0; i < data.length; i++) {
      _dataMap[_dataMap.keys.elementAt(i)] = data[i];
    }
  }

  @override
  String toString() => _dataMap.toString();
}

/// The response that contains the status of the led controller.
///
/// Used together with [StatusRequest].
class StatusResponse extends LedResponse {
  int get red => _dataMap["red"];
  int get green => _dataMap["green"];
  int get blue => _dataMap["blue"];
  int get warmWhite => _dataMap["warmWhite"];
  int get coldWhite => _dataMap["coldWhite"];

  bool get poweredOn => _dataMap["powerStatus"] == powerStateOn;
  bool get poweredOff => _dataMap["powerStatus"] == powerStateOff;

  StatusResponse(List<int> data) {
    _dataMap = {
      "packetId": null,
      "deviceName": null,
      "powerStatus": null,
      "mode": null,
      "runStatus": null,
      "speed": null,
      "red": null,
      "green": null,
      "blue": null,
      "warmWhite": null,
      "_unknown1": null,
      "coldWhite": null,
      "_unknown2": null,
      "checkSum": null,
    };

    parse(data);
  }
}

class ResponseParserException implements Exception {
  final String message;

  ResponseParserException(this.message);

  @override
  String toString() => "Exception: Unable to parse response\n$message";
}
