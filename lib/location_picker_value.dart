import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location_picker/prediction_model.dart';

class LocationPickerValue {
  MapController? mapController;
  TextEditingController? searchController = TextEditingController();
  List<PredictionModel> predictions = [];
  PredictionModel selectedPrediction = PredictionModel();
  bool isOnLoadPrediction = false;
  bool openPrediction = false;
  bool isOnGetAddress = false;

  LocationPickerValue() {
    mapController = MapController();
  }
}
