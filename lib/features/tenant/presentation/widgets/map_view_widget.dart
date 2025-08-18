import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../shared/models/property_model.dart';
import '../../../property/presentation/pages/property_details_page.dart';

class MapViewWidget extends StatefulWidget {
  final List<PropertyModel> properties;
  final Position? currentPosition;
  final Function(PropertyModel)? onPropertyTap;

  const MapViewWidget({
    super.key,
    required this.properties,
    this.currentPosition,
    this.onPropertyTap,
  });

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  PropertyModel? _selectedProperty;
  bool _showPropertyCard = false;

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(MapViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.properties != widget.properties) {
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    Set<Marker> markers = {};
    
    for (int i = 0; i < widget.properties.length; i++) {
      final property = widget.properties[i];
      if (property.latitude != null && property.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(property.id),
            position: LatLng(property.latitude!, property.longitude!),
            onTap: () {
              setState(() {
                _selectedProperty = property;
                _showPropertyCard = true;
              });
            },
            icon: BitmapDescriptor.defaultMarkerWithHue(
              property.isAvailable 
                  ? BitmapDescriptor.hueGreen 
                  : BitmapDescriptor.hueRed,
            ),
          ),
        );
      }
    }
    
    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = widget.currentPosition != null
        ? LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude)
        : const LatLng(37.7749, -122.4194); // Default to San Francisco

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 12,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          myLocationEnabled: widget.currentPosition != null,
          myLocationButtonEnabled: true,
          onTap: (_) {
            setState(() {
              _showPropertyCard = false;
              _selectedProperty = null;
            });
          },
          mapType: MapType.normal,
          zoomControlsEnabled: false,
        ),
        
        // Map controls
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton(
                mini: true,
                heroTag: "zoom_in",
                onPressed: () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                heroTag: "zoom_out",
                onPressed: () {
                  _mapController?.animateCamera(CameraUpdate.zoomOut());
                },
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                heroTag: "my_location",
                onPressed: _goToCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
        
        // Property count overlay
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.properties.length} properties',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Property card overlay
        if (_showPropertyCard && _selectedProperty != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildPropertyCard(_selectedProperty!),
          ),
      ],
    );
  }

  Widget _buildPropertyCard(PropertyModel property) {
    return Card(
      elevation: 8,
      child: InkWell(
        onTap: () {
          if (widget.onPropertyTap != null) {
            widget.onPropertyTap!(property);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PropertyDetailsPage(property: property),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Property image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: property.imageUrls.isNotEmpty
                      ? Image.network(
                          property.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.home, size: 40);
                          },
                        )
                      : const Icon(Icons.home, size: 40),
                ),
              ),
              const SizedBox(width: 16),
              
              // Property details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.address,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          property.priceDisplay,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (property.rating != null) ...[
                          Icon(
                            Icons.star,
                            color: Colors.amber[600],
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            property.rating!.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${property.bedrooms}', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 12),
                        Icon(Icons.bathtub, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${property.bathrooms}', style: Theme.of(context).textTheme.bodySmall),
                        if (property.area != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.square_foot, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${property.area!.toInt()} sqft', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Close button
              IconButton(
                onPressed: () {
                  setState(() {
                    _showPropertyCard = false;
                    _selectedProperty = null;
                  });
                },
                icon: const Icon(Icons.close),
                iconSize: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToCurrentLocation() {
    if (widget.currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude),
        ),
      );
    }
  }
}

