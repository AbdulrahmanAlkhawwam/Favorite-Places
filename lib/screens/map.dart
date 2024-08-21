import 'package:acodemind05/models/place_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.isSelecting = true});

  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController controller;

  GeoPoint oldLocation = GeoPoint(
    latitude: 37.422,
    longitude: -122.084,
  );

  @override
  void initState() {
    controller = MapController(
      initPosition: oldLocation,
    );
    super.initState();
  }

  Future<void> _onLocationChanged(GeoPoint value) async {
    setState(() async {
      GeoPoint center = await controller.centerMap;
      await controller.changeLocationMarker(
        oldLocation: oldLocation,
        newLocation: center,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? 'Pick your Location' : 'Your Location'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                GeoPoint location = await controller.centerMap;
                Navigator.of(context).pop(PlaceLocation(
                    latitude: location.latitude,
                    longitude: location.longitude,
                    address: ''));
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          OSMFlutter(
              controller: controller,
              onLocationChanged: _onLocationChanged,
              osmOption: OSMOption(
                userTrackingOption: const UserTrackingOption(
                  enableTracking: true,
                  unFollowUser: false,
                ),
                zoomOption: const ZoomOption(
                  initZoom: 8,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                userLocationMarker: UserLocationMaker(
                  personMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.location_history_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  directionArrowMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.double_arrow,
                      size: 48,
                    ),
                  ),
                ),
                roadConfiguration: const RoadOption(
                  roadColor: Colors.yellowAccent,
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  child: IconButton(
                    onPressed: () async {
                      await controller.zoomIn();
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
                const SizedBox(height: 15),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  child: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () async {
                      await controller.zoomOut();
                    },
                  ),
                ),
              ],
            ),
          ),
          const Center(
            child: Icon(
              Icons.location_pin,
              color: Colors.redAccent,
              size: 35,
            ),
          )
        ],
      ),
    );
  }
}
