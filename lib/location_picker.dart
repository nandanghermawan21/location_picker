import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker/location_picker_controller.dart';
import 'package:location_picker/location_picker_value.dart';
import 'package:location_picker/prediction_model.dart';

class LocationPicker extends StatelessWidget {
  final LocationPickerController controller;
  final String apiKey;
  final LatLng? initialLocation;
  final double? initialZoom;
  final bool? autoToMyLocation;
  final Widget Function(void Function() onTapUseLocation)?
      userLocationButtonBuilder;
  final ValueChanged<PredictionModel>? onTapUseLocation;
  final Widget? centerWidget;
  final double? centterWidgetheight;

  const LocationPicker({
    super.key,
    required this.controller,
    this.initialZoom,
    this.initialLocation,
    this.autoToMyLocation = true,
    this.userLocationButtonBuilder,
    this.onTapUseLocation,
    this.centerWidget,
    this.centterWidgetheight = 100,
    required this.apiKey,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LocationPickerValue>(
      valueListenable: controller,
      builder: (c, d, w) {
        return Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: Stack(
            children: [
              FlutterMap(
                mapController: controller.value.mapController,
                options: MapOptions(
                    initialCenter:
                        initialLocation ?? const LatLng(-6.1754, 106.8272),
                    initialZoom: initialZoom ?? 15,
                    onTap: (tapPosition, point) {},
                    onMapReady: () {
                      if (autoToMyLocation!) {
                        controller.directToMyLocation();
                      }
                    }),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.zoomIn();
                            },
                            child: Container(
                              color: Colors.white,
                              child: const Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.zoomOut();
                            },
                            child: Container(
                              color: Colors.white,
                              child: const Icon(
                                Icons.remove,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.directToMyLocation();
                            },
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: Colors.transparent,
                  child: userLocationButtonBuilder != null
                      ? userLocationButtonBuilder?.call(
                          () {
                            controller
                                .readLocation(apiKey: apiKey)
                                .then((onValue) {
                              onTapUseLocation?.call(onValue);
                            }).catchError(
                              (onError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to get location',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : ElevatedButton(
                          onPressed: () {
                            controller
                                .readLocation(apiKey: apiKey)
                                .then((onValue) {
                              onTapUseLocation?.call(onValue);
                            }).catchError(
                              (onError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to get location',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: Text(
                            'Use Location',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                        ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: IntrinsicWidth(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(bottom: centterWidgetheight!),
                    height: centterWidgetheight,
                    color: Colors.transparent,
                    child: centerWidget ??
                        Icon(
                          Icons.location_on_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 60,
                        ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          color: Colors.transparent,
                          child: TextField(
                            controller: controller.value.searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Location',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (val) {
                              if (val.length > 3) {
                                controller.loadPredictions(apiKey);
                              }
                              if (val.isEmpty || val.length < 3) {
                                controller.closePrediction();
                              }
                            },
                          ),
                        ),
                        LinearProgressIndicator(
                          value: controller.value.isOnLoadPrediction ? 1 : 0,
                        ),
                        controller.value.openPrediction
                            ? Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                child: ListView.builder(
                                  itemCount:
                                      controller.value.predictions.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        controller.value.mapController!.move(
                                          LatLng(
                                            controller
                                                .value.predictions[index].lat!,
                                            controller
                                                .value.predictions[index].lng!,
                                          ),
                                          15.0,
                                        );
                                        controller.closePrediction();
                                      },
                                      child: Container(
                                        height: 50,
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          controller.value.predictions[index]
                                              .formattedAddress!,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
