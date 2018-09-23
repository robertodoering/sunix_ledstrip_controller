# Sunix ledstrip controller

A dart library for controlling the Sunix® RGB / RGBWWCW WiFi LED strip controller.


## Features
- Power the controller off and on
- Change the color of the led controller
	- For RGB or RGBWWCW (warm white and cold white) controller
- Receive the current status of the controller, including the power state and color values
- Send multiple requests in quick succession
	- Can be used to create a smooth transition from one color to another


## Installation
You can install the package by adding the following to your `pubspec.yaml`:
```yaml
dependencies:
  sunix_ledstrip_controller: ^1.0.0
```


## Usage

A simple usage example:

```dart
import 'package:sunix_ledstrip_controller/sunix_ledstrip_controller.dart';

main() async {
  // create a new controller object with a static ip
  LedController controller = LedController("192.168.178.50");

  // power the controller on
  if (await controller.powerOn()) {
    // methods return true when the request was successfully sent
    print("successfully powered on");
  }

  // change the controller color
  controller.updateColorRgb(192, 255, 238);

  // get the status of the controller
  StatusResponse status;
  await controller
      .requestStatus()
      .then((response) => status = response ?? status);

  print("powered on: ${status?.poweredOn}");
  print("red:   ${status?.red}");
  print("blue:  ${status?.green}");
  print("green: ${status?.blue}");
}
```

## Example

See the `example` directory for a basic example.

## Attributions
A big thanks goes to [@markusressel](https://github.com/markusressel) for his python library [sunix-ledstrip-controller-client](https://github.com/markusressel/sunix-ledstrip-controller-client).