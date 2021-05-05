import 'package:flutter_blue/flutter_blue.dart';

class EnvsensorAdvertisement {
  final int companyId;
  final Map<String, dynamic> data;

  EnvsensorAdvertisement(this.companyId, this.data);
}

const int APPLE = 76; // 0x004c
const int OMROM = 725; // 0x02d5

EnvsensorAdvertisement? parse(ScanResult result) {
  final data = result.advertisementData;
  if (!RegExp(r'^(Env|IM|EP)$').hasMatch(data.localName)) {
    return null;
  }
  if (data.manufacturerData.isEmpty) {
    return null;
  }
  final companyId = data.manufacturerData.keys.first;
  switch (companyId) {
    case OMROM:
      return parseAsOmron(companyId, data);
    case APPLE:
      return parseAsApple(companyId, data);
    default:
      return null;
  }
}

EnvsensorAdvertisement parseAsOmron(int companyId, AdvertisementData data) {
  final bs = data.manufacturerData[OMROM]!;
  final sequenceNumber = bs[0];
  final temperature = (bs[2] << 8 | bs[1]) / 100; // degC
  final humidity = (bs[4] << 8 | bs[3]) / 100; // 湿度 %
  final ambientLight = bs[6] << 8 | bs[5]; // lx
  final uvIndex = (bs[8] << 8 | bs[7]) / 100;
  final pressure = (bs[10] << 8 | bs[9]) / 10; // hPa
  final soundNoise = (bs[12] << 8 | bs[11]) / 100; // dB
  final discomfortIndex = (bs[14] << 8 | bs[13]) / 100; // 不快指数
  final heatStroke = (bs[16] << 8 | bs[15]) / 100; // 熱中症危険度 degC らしい
  // bs[18], bs[17] RFU (reserved for future use)
  final batteryVoltage = (bs[19] + 100) * 10; // mV (p.35 3.Advertise format より)
  return EnvsensorAdvertisement(companyId, {
    'sequenceNumber': sequenceNumber,
    'temperature': temperature,
    'humidity': humidity,
    'ambientLight': ambientLight,
    'uvIndex': uvIndex,
    'pressure': pressure,
    'soundNoise': soundNoise,
    'discomfortIndex': discomfortIndex,
    'heatStroke': heatStroke,
    'batteryVoltage': batteryVoltage
  });
}

EnvsensorAdvertisement parseAsApple(int companyId, AdvertisementData data) {
  return EnvsensorAdvertisement(companyId, {}); // TODO
}
