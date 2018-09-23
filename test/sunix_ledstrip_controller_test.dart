import 'package:sunix_ledstrip_controller/sunix_ledstrip_controller.dart';
import 'package:test/test.dart';

void main() {
  group('requests', () {
    test("update color rgb", () {
      var request = UpdateColorRequest.rgb(red: 128, blue: 128, green: 128);

      expect(request.red, equals(128));
      expect(request.green, equals(128));
      expect(request.blue, equals(128));

      expect(request.rgbwwSelection, UpdateColorRequest.selectionRgb);

      expect(request.data, equals([49, 128, 128, 128, 0, 0, 240, 15, 176]));
    });

    test("update color ww", () {
      var request = UpdateColorRequest.ww(warmWhite: 13, coldWhite: 37);

      expect(request.warmWhite, equals(13));
      expect(request.coldWhite, equals(37));

      expect(request.rgbwwSelection, UpdateColorRequest.selectionWw);

      expect(request.data, equals([49, 0, 0, 0, 13, 37, 15, 15, 129]));
    });

    test("update color rgbww", () {
      var request = UpdateColorRequest.rgbww(
        red: 0,
        green: 125,
        blue: 250,
        warmWhite: 13,
        coldWhite: 37,
      );

      expect(request.red, equals(0));
      expect(request.green, equals(125));
      expect(request.blue, equals(250));
      expect(request.warmWhite, equals(13));
      expect(request.coldWhite, equals(37));

      expect(request.rgbwwSelection, UpdateColorRequest.selectionRgbww);

      expect(request.data, equals([49, 0, 125, 250, 13, 37, 255, 15, 232]));
    });

    test("set power on", () {
      expect(SetPowerRequest.on().data, equals([113, 35, 15, 163]));
    });

    test("set power off", () {
      expect(SetPowerRequest.off().data, equals([113, 36, 15, 164]));
    });

    test("status", () {
      expect(StatusRequest().data, equals([129, 138, 139, 150]));
    });
  });

  test("calculate checksum", () {
    var request = UpdateColorRequest.rgb(red: 255, green: 0, blue: 255);

    expect(request.data.last, equals(46));
  });
}
