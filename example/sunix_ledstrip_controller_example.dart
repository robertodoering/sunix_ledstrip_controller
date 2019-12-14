import 'dart:convert';
import 'dart:io';

void main() async {
  const discoveryPort = 48899;
  const discoveryMessage = 'HF-A11ASSISTHREAD';

  final udpSocket = await RawDatagramSocket.bind(
    InternetAddress.anyIPv4,
    discoveryPort,
  );

  udpSocket.broadcastEnabled = true;

  udpSocket.listen((data) {
    final dg = udpSocket.receive();
    if (dg != null) {
      print('data received: ${dg.data}');
      print(dg.address);
      print(dg.port);
      print(utf8.decode(dg.data));
    } else {
      print('data is null');
    }
  });

  udpSocket.send(
    utf8.encode(discoveryMessage),
    InternetAddress('255.255.255.255'),
    discoveryPort,
  );
}

// void main() async {
//   print('start example');

//   // create a new controller object with a static ip
//   final controller = LedController('192.168.178.50');

//   // power the controller on
//   if (await controller.powerOn()) {
//     // methods return true when the request was successfully sent
//     print('successfully powered on');
//   }

//   // change the controller color
//   await controller.updateColorRgb(192, 255, 238);

//   // also change the warm and cold white (if the controller supports it)
//   await controller.updateColorRgbww(192, 255, 238, 128, 128);

//   // get the status of the controller
//   StatusResponse status;

//   await controller
//       .requestStatus()
//       .then((response) => status = response ?? status);

//   print('powered on: ${status?.poweredOn}');
//   print('red:   ${status?.red}');
//   print('blue:  ${status?.green}');
//   print('green: ${status?.blue}');

//   // send a list of requests
//   // can be used to update the color in quick succession
//   final requests = <LedRequest>[
//     UpdateColorRequest.rgb(red: 0, green: 0, blue: 0),
//     UpdateColorRequest.rgb(red: 60, green: 0, blue: 0),
//     UpdateColorRequest.rgb(red: 120, green: 0, blue: 0),
//     UpdateColorRequest.rgb(red: 180, green: 0, blue: 0),
//     UpdateColorRequest.rgb(red: 240, green: 0, blue: 0),
//   ];

//   // when using sendRequest or sendRequests an exception can be thrown and
//   // should be caught
//   try {
//     await controller.sendRequests(requests, const Duration(seconds: 10));
//   } on SocketException {
//     print('exception while changing color');
//   }
// }
