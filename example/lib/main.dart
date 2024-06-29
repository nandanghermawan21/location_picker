import 'package:flutter/material.dart';
import 'package:location_picker/main.dart';
import 'package:location_picker/prediction_model.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Location Picker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocationPickerController controller = LocationPickerController();

  @override
  void initState() {
    super.initState();
    Permission.location.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: LocationPicker(
        controller: controller,
        apiKey: "", // Your Google Maps API Key,
        autoToMyLocation: false,
        onTapUseLocation: (PredictionModel location) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location: ${location.lat}, ${location.lng} \n ${location.formattedAddress}',
              ),
            ),
          );
        },
      ),
    );
  }
}
