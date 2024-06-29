import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_picker/prediction_model.dart';
import 'location_picker_value.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerController extends ValueNotifier<LocationPickerValue> {
  LocationPickerController({LocationPickerValue? value})
      : super(value ?? LocationPickerValue());

  void directToMyLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      //arahkan peta ke lokasi saya
      value.mapController!
          .move(LatLng(position.latitude, position.longitude), 15.0);
    });
  }

  void zoomIn() {
    value.mapController!.move(
      value.mapController!.camera.center,
      value.mapController!.camera.zoom + 1,
    );
  }

  void zoomOut() {
    value.mapController!.move(
      value.mapController!.camera.center,
      value.mapController!.camera.zoom - 1,
    );
  }

  void loadPredictions(String apiKey) {
    value.isOnLoadPrediction = true;
    value.openPrediction = false;
    notifyListeners();
    PredictionModel.getPredictions(
            apiKey: apiKey, input: value.searchController!.text)
        .then(
      (predictions) {
        value.predictions = predictions;
        value.isOnLoadPrediction = false;
        value.openPrediction = true;
        notifyListeners();
      },
    ).catchError((onError) {
      value.isOnLoadPrediction = false;
      value.openPrediction = false;
      notifyListeners();
    });
  }

  void closePrediction() {
    value.openPrediction = false;
    notifyListeners();
  }

  Future<PredictionModel> readLocation({
    required String apiKey,
  }) {
    value.isOnGetAddress = true;
    notifyListeners();
    return PredictionModel.getAddress(
      apiKey: apiKey,
      lat: value.mapController!.camera.center.latitude,
      lng: value.mapController!.camera.center.longitude,
    ).then((onValue) {
      value.selectedPrediction = PredictionModel(
        name: 'Selected Location',
        lat: value.mapController!.camera.center.latitude,
        lng: value.mapController!.camera.center.longitude,
        formattedAddress: onValue,
      );
      value.isOnGetAddress = false;
      notifyListeners();
      return value.selectedPrediction;
    }).catchError((onError) {
      value.isOnGetAddress = false;
      notifyListeners();
      throw Exception('Failed to get address');
    });
  }
}
