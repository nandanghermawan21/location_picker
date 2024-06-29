import 'dart:convert';

import 'package:http/http.dart' as http;

class PredictionModel {
  String? name;
  String? placeId;
  String? formattedAddress;
  double? lat;
  double? lng;

  PredictionModel({
    this.name,
    this.placeId,
    this.formattedAddress,
    this.lat,
    this.lng,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      name: json['name'],
      placeId: json['place_id'],
      formattedAddress: json['formatted_address'],
      lat: json['geometry']['location']['lat'],
      lng: json['geometry']['location']['lng'],
    );
  }

  //to json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'place_id': placeId,
      'formatted_address': formattedAddress,
      'geometry': {
        'location': {
          'lat': lat,
          'lng': lng,
        },
      },
    };
  }

  static Future<List<PredictionModel>> getPredictions({
    required String apiKey,
    required String input,
  }) {
    return http.get(
        Uri.parse(
            'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$input&key=$apiKey'),
        headers: {}).then((onValue) {
      if (onValue.statusCode == 200) {
        final data = json.decode(onValue.body);
        final predictions = data['results'] as List;
        return predictions.map((e) => PredictionModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load predictions');
      }
    }).catchError((onError) {
      throw Exception('Failed to load predictions');
    });
  }

  static Future<String> getAddress({
    required String apiKey,
    required double lat,
    required double lng,
  }) {
    return http.get(
        Uri.parse(
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey'),
        headers: {}).then((onValue) {
      if (onValue.statusCode == 200) {
        final data = json.decode(onValue.body);
        final address = data['results'][0]['formatted_address'];
        return address as String;
      } else {
        throw Exception('Failed to load address');
      }
    }).catchError((onError) {
      throw Exception('Failed to load address');
    });
  }
}
