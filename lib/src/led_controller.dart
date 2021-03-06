import 'dart:async';
import 'dart:io';

import 'package:sunix_ledstrip_controller/src/requests.dart';
import 'package:sunix_ledstrip_controller/src/response.dart';

const defaultPort = 5577;

// todo: discover controller

class LedController {
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
  Future<List<int>> sendRequest(
    LedRequest request, [
    Duration timeout = const Duration(seconds: 10),
  ]) async {
    final socket = await Socket.connect(host, port);
    socket.add(request.data);

    // add listener when waiting for response
    if (request.waitForResponse) {
      List<int> responseData;

      await for (var data in socket.timeout(timeout)) {
        if (data is List<int>) {
          socket.destroy();
          responseData = data;
        } else if (data is TimeoutException) {
          socket.destroy();
          throw data;
        }
        socket.destroy();
      }

      return responseData;
    } else {
      socket.destroy();
      return null;
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
    final interval = Duration(
      microseconds: duration.inMicroseconds ~/ requests.length,
    );

    final socket = await Socket.connect(host, port);

    for (final request in requests) {
      socket.add(request.data);
      sleep(interval);
    }

    socket.destroy();
  }

  /// Changes the rgb color for the led controller.
  ///
  /// Returns `true` if the request was successfully sent to the controller,
  /// `false` otherwise.
  Future<bool> updateColorRgb(int r, int g, int b) async {
    try {
      await sendRequest(UpdateColorRequest.rgb(red: r, green: g, blue: b));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Changes the rgbww color for the led controller.
  ///
  /// Returns `true` if the request was successfully sent to the controller,
  /// `false` otherwise.
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
      return false;
    }
  }

  /// Changes the ww color for the led controller.
  ///
  /// Returns `true` if the request was successfully sent to the controller,
  /// `false` otherwise.
  Future<bool> updateColorWw(int ww, int cw) async {
    try {
      await sendRequest(UpdateColorRequest.ww(warmWhite: ww, coldWhite: cw));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Powers the led controller on.
  ///
  /// Returns `true` if the request was successfully sent to the controller,
  /// `false` otherwise.
  Future<bool> powerOn() async {
    try {
      await sendRequest(SetPowerRequest.on());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Powers the led controller off.
  ///
  /// Returns `true` if the request was successfully sent to the controller,
  /// `false` otherwise.
  Future<bool> powerOff() async {
    try {
      await sendRequest(SetPowerRequest.off());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Requests the status of the led controller.
  ///
  /// Returns a [StatusResponse] after receiving it or `null` if there was a
  /// problem sending the request or if the response is not received in time.
  Future<StatusResponse> requestStatus() async {
    try {
      final data = await sendRequest(StatusRequest());
      return StatusResponse(data);
    } catch (e) {
      return null;
    }
  }
}
