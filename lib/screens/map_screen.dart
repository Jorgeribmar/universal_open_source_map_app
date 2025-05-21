import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:universal_open_source_map_app/providers/map_provider.dart';
import 'package:universal_open_source_map_app/models/location.dart';
import 'package:universal_open_source_map_app/widgets/map_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Initialize by getting current location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      mapProvider.getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Explorer'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: Consumer<MapProvider>(
        builder: (context, mapProvider, child) {
          return Stack(
            children: [
              _buildMap(mapProvider),
              _buildMapControls(mapProvider),
              if (mapProvider.isSearching)
                const Center(child: CircularProgressIndicator()),
              if (mapProvider.searchResults.isNotEmpty && !mapProvider.isSearching)
                _buildSearchResults(mapProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, _) {
        return TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for a location',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        mapProvider.clearSearchResults();
                      },
                    )
                    : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (query) {
            // Trigger live search with a maximum of 5 results.
            mapProvider.searchLocations(query, limit: 5);
          },
        );
      },
    );
  }

  Widget _buildMap(MapProvider mapProvider) {
    // Default center on a world view if no current location
    final LatLng center =
        mapProvider.currentLocation != null
            ? LatLng(
              mapProvider.currentLocation!.latitude,
              mapProvider.currentLocation!.longitude,
            )
            : const LatLng(0, 0);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: center,
        zoom: 13.0,
        maxZoom: 18.0,
        minZoom: 3.0,
        interactiveFlags: InteractiveFlag.all,
        onTap: (_, point) {
          // Clear search results when tapping on the map
          if (mapProvider.searchResults.isNotEmpty) {
            mapProvider.clearSearchResults();
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.osmap.universal_open_source_map_app',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: _buildMarkers(mapProvider)),
      ],
    );
  }

  List<Marker> _buildMarkers(MapProvider mapProvider) {
    final List<Marker> markers = [];

    // Add current location marker
    if (mapProvider.currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(
            mapProvider.currentLocation!.latitude,
            mapProvider.currentLocation!.longitude,
          ),
          width: 40,
          height: 40,
          child: const MapMarker(
            color: Colors.blue,
            icon: Icons.my_location,
            size: 30,
            isCurrentLocation: true,
          ),
        ),
      );
    }

    // Add selected location marker
    if (mapProvider.selectedLocation != null) {
      markers.add(
        Marker(
          point: LatLng(
            mapProvider.selectedLocation!.latitude,
            mapProvider.selectedLocation!.longitude,
          ),
          width: 40,
          height: 40,
          child: const MapMarker(
            color: Colors.red,
            icon: Icons.location_on,
            size: 40,
            showPulse: true,
          ),
        ),
      );
    }

    // Add search result markers
    for (int i = 0; i < mapProvider.searchResults.length; i++) {
      final location = mapProvider.searchResults[i];
      markers.add(
        Marker(
          point: LatLng(location.latitude, location.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              mapProvider.selectLocation(location);
              mapProvider.getLocationDetails(
                location,
              ); // Get detailed information when selected
              _mapController.move(
                LatLng(location.latitude, location.longitude),
                15.0,
              );
            },
            child: MapMarker(
              color: Colors.blue,
              icon: Icons.place,
              label: '${i + 1}',
              size: 36,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildMapControls(MapProvider mapProvider) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            mini: true,
            onPressed: () {
              final currentZoom = _mapController.zoom;
              _mapController.move(_mapController.center, currentZoom + 1);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomOut',
            mini: true,
            onPressed: () {
              final currentZoom = _mapController.zoom;
              _mapController.move(_mapController.center, currentZoom - 1);
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'currentLocation',
            onPressed: () async {
              await mapProvider.getCurrentLocation();
              if (mapProvider.currentLocation != null) {
                _mapController.move(
                  LatLng(
                    mapProvider.currentLocation!.latitude,
                    mapProvider.currentLocation!.longitude,
                  ),
                  15.0,
                );
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(MapProvider mapProvider) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        // You can adjust the height based on the number of results.
        height: 200,
        color: Colors.white.withOpacity(0.9),
        child: ListView.builder(
          itemCount: mapProvider.searchResults.length,
          itemBuilder: (context, index) {
            final Location location = mapProvider.searchResults[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text('${index + 1}'),
              ),
              title: Text(location.name),
              subtitle: Text(location.address),
              onTap: () {
                mapProvider.selectLocation(location);
                _mapController.move(
                  LatLng(location.latitude, location.longitude),
                  15.0,
                );
                mapProvider.clearSearchResults();
              },
            );
          },
        ),
      ),
    );
  }
}
