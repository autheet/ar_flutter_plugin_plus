import 'package:ar_flutter_plugin_plus/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_plus/ar_flutter_plugin_plus.dart';
import 'package:ar_flutter_plugin_plus/datatypes/config_planedetection.dart';

class GeospatialExampleWidget extends StatefulWidget {
  const GeospatialExampleWidget({super.key});

  @override
  _GeospatialExampleWidgetState createState() =>
      _GeospatialExampleWidgetState();
}

class _GeospatialExampleWidgetState extends State<GeospatialExampleWidget> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  String _vpsAvailability = "Unknown";
  String _earthState = "Unknown";
  String _trackingState = "Unknown";
  String _poseInfo = "Unknown";

  @override
  void dispose() {
    super.dispose();
    arSessionManager?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Geospatial API Example'),
        ),
        body: Stack(children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            geospatialMode: true,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("VPS Availability: $_vpsAvailability",
                      style: const TextStyle(color: Colors.white)),
                  Text("Earth State: $_earthState",
                      style: const TextStyle(color: Colors.white)),
                  Text("Tracking State: $_trackingState",
                      style: const TextStyle(color: Colors.white)),
                  Text("Pose: $_poseInfo",
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: onCheckVPSAvailability,
                      child: const Text("Check VPS")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: onAddTerrainAnchor,
                      child: const Text("Add Terrain Anchor")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: onAddRooftopAnchor,
                      child: const Text("Add Rooftop Anchor")),
                ],
              ),
            ),
          )
        ]));
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          showWorldOrigin: true,
          handleTaps: false,
        );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onGeospatialStateUpdated = onGeospatialStateUpdated;
  }

  void onGeospatialStateUpdated(
      String earthState, String trackingState, Map<String, dynamic> pose) {
    setState(() {
      _earthState = earthState;
      _trackingState = trackingState;
      _poseInfo =
          "Lat: ${pose['latitude']}\nLon: ${pose['longitude']}\nAlt: ${pose['altitude']}\nHeading: ${pose['heading']}";
    });
  }

  Future<void> onCheckVPSAvailability() async {
    // Use current pose if available, otherwise use a default or ask user
    // For simplicity, we'll try to use the last known pose from the update
    // But since we don't store it in a variable accessible here easily without parsing _poseInfo,
    // let's just trigger it with 0,0 if we don't have info, or better, rely on the fact that
    // the user should probably provide this.
    // However, for the example, let's hardcode a known location or just use 0,0 to see the response.
    // A better approach for a real app is to use the device's current location.

    // NOTE: In a real app, you'd get the current location from the location plugin or the AR geospatial pose.
    // Here we will just check availability at the current camera position if valid.

    // Since we are receiving updates, let's just say we check at 0,0 for test if we don't have a valid pose yet.
    // But actually, checkVPSAvailability takes lat/lon.

    // Let's try to parse the pose info or just pass 0,0 for now to test the call.
    // In a real scenario, you would pass the coordinates you want to check.
    var lat = 0.0;
    var lon = 0.0;

    // If we have valid pose data, we could use it.
    // For this example, let's just call it with 0,0 to verify the method call works.
    final availability = await arSessionManager!.checkVPSAvailability(lat, lon);
    setState(() {
      _vpsAvailability = availability ?? "Error";
    });
  }

  Future<void> onAddTerrainAnchor() async {
    // Example: Add anchor at current location (if we had it) or a fixed location.
    // For demonstration, let's try to add one at a dummy location.
    // In a real app, you'd use the camera's geospatial pose.
    var lat = 37.7749; // San Francisco
    var lon = -122.4194;
    var alt = 10.0;

    final success = await arAnchorManager!.addTerrainAnchor(lat, lon, alt);
    if (success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terrain anchor added successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add terrain anchor")));
    }
  }

  Future<void> onAddRooftopAnchor() async {
    var lat = 37.7749; // San Francisco
    var lon = -122.4194;
    var alt = 10.0;

    final success = await arAnchorManager!.addRooftopAnchor(lat, lon, alt);
    if (success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rooftop anchor added successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add rooftop anchor")));
    }
  }
}
