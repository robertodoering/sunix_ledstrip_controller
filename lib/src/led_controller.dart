import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:sunix_ledstrip_controller/src/requests.dart';
import 'package:sunix_ledstrip_controller/src/response.dart';

const defaultPort = 5577;

// todo: discover controller

class LedController {
  Logger log = Logger("LedController");

  /// The host ip address of the led controller.
  String host;

  /// The port of the led controller (5577 by default).
  int port;

  LedController(this.host, [this.port = defaultPort])
      : assert(host != null),
        assert(port != null);

  /// Sends a [LedRequest] to a socket with the given [host] and [port].
  ///
  /// Can throw a [SocketException].
  ///
  /// If the request does not require to wait for a response, it will return
  /// null after the request has been sent to the socket.
  /// Otherwise it will return the response as a List<int>.
  /// If no data has been received in the duration of
  /// [timeout], a [TimeoutException] will be thrown.
  Future<List<int>> sendRequest(LedRequest request,
      [Duration timeout = const Duration(seconds: 10)]) async {
    log.info("sending request: $request");

    try {
      var s = await Socket.connect(host, port);
      s.add(request.data);

      // add listener when waiting for response
      if (request.waitForResponse) {
        log.info("waiting for response");

        List<int> responseData;

        await for (var data in s.timeout(timeout)) {
          if (data is List<int>) {
            s.destroy();
            responseData = data;
          } else if (data is TimeoutException) {
            s.destroy();
            throw data;
          }
          s.destroy();
        }

        return responseData;
      } else {
        s.destroy();
        return null;
      }
    } on SocketException {
      log.warning("exception while sending request");
      rethrow;
    }
  }

  /// Sends a list of [LedRequest]s in an [duration] to a socket with the given
  /// [host] and [port].
  ///
  /// All requests will be send in sequence with a delay, so that all requests
  /// will be send in the given [duration].
  ///
  /// Can throw a [SocketException].
  Future<void> sendRequests(
    List<LedRequest> requests,
    Duration duration,
  ) async {
    Duration interval = Duration(
      microseconds: duration.inMicroseconds ~/ requests.length,
    );

    log.info("sending ${requests.length} requests in an interval of "
        "${interval.inMilliseconds}ms");

    try {
      var s = await Socket.connect(host, port);

      for (LedRequest request in requests) {
        s.add(request.data);
        sleep(interval);
      }

      s.destroy();
    } on SocketException {
      log.warning("exception while sending requests");
      rethrow;
    }
  }

  /// Changes the rgb color for the led controller.
  ///
  /// Returns true if the request was successfully sent to the controller, else
  /// otherwise.
  Future<bool> updateColorRgb(int r, int g, int b) async {
    try {
      await sendRequest(UpdateColorRequest.rgb(red: r, green: g, blue: b));
      return true;
    } catch (e) {
      log.warning("error while changing color rgb", e);
      return false;
    }
  }

  /// Changes the rgbww color for the led controller.
  ///
  /// Returns true if the request was successfully sent to the controller, else
  /// otherwise.
  Future<bool> updateColorRgbww(int r, int g, int b, int ww, int cw) async {
    try {
      await sendRequest(UpdateColorRequest.rgbww(
        red: r,
        green: g,
        blue: b,
        warmWhite: ww,
        coldWhite: cw,
      ));
      return true;
    } catch (e) {
      log.warning("error while changing color rgbww", e);
      return false;
    }
  }

  /// Changes the ww color for the led controller.
  ///
  /// Returns true if the request was successfully sent to the controller, else
  /// otherwise.
  Future<bool> updateColorWw(int ww, int cw) async {
    try {
      await sendRequest(UpdateColorRequest.ww(warmWhite: ww, coldWhite: cw));
      return true;
    } catch (e) {
      log.warning("error while changing color ww", e);
      return false;
    }
  }

  /// Powers the led controller on.
  ///
  /// Returns true if the request was successfully sent to the controller, else
  /// otherwise.
  Future<bool> powerOn() async {
    try {
      await sendRequest(SetPowerRequest.on());
      return true;
    } catch (e) {
      log.warning("error while powering on", e);
      return false;
    }
  }

  /// Powers the led controller off.
  ///
  /// Returns true if the request was successfully sent to the controller, else
  /// otherwise.
  Future<bool> powerOff() async {
    try {
      await sendRequest(SetPowerRequest.off());
      return true;
    } catch (e) {
      log.warning("error while powering off", e);
      return false;
    }
  }

  /// Requests the status of the led controller.
  ///
  /// Returns a [StatusResponse] after receiving it or null if there was a
  /// problem sending the request or if the response is not received in time.
  Future<StatusResponse> requestStatus() async {
    try {
      List<int> data = await sendRequest(StatusRequest());
      return StatusResponse(data);
    } catch (e) {
      log.warning("error while requesting or receiving status", e);
      return null;
    }
  }
}
