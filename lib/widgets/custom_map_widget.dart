import 'package:flutter/material.dart';
import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/functions.dart';

class CustomMapWidget extends StatefulWidget {

  CustomMapWidget({
    @required this.markers,
    @required this.onCLick,
    this.useLocation = true,
    this.allowMarker = true,
  });

  final List<Marker> markers;
  final Function(LatLng value) onCLick;
  final bool useLocation;
  final bool allowMarker;

  @override
  _CustomMapWidgetState createState() => _CustomMapWidgetState();
}

class _CustomMapWidgetState extends State<CustomMapWidget> {
  
  Completer<GoogleMapController> _controller = Completer();
  Position _currentPosition;
  
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  bool _isLoaded = false;

  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _currentPosition = await getCurrentUserLocation();
      if(this.mounted) {
        _isLoaded = true;
      }
      await Future.delayed(const Duration(milliseconds: 10), (){});
      _animateMapCamera();
    }
    super.didChangeDependencies();
  }
  
  void _animateMapCamera() async {
    if(this.mounted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: widget.useLocation ? LatLng(_currentPosition.latitude, _currentPosition.longitude) : LatLng(widget.markers.first.position.latitude, widget.markers.first.position.longitude),
          zoom: 14.0,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
        initialCameraPosition: _initialLocation,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        mapType: MapType.normal,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false,
        markers: widget.markers.length != null ? Set<Marker>.of(widget.markers) : Set<Marker>.of([]),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onTap: widget.allowMarker == true ? (value){
          widget.onCLick(value);
          if(widget.markers.length == 0){
            setState(() {
              widget.markers.add(Marker(
                markerId: MarkerId(value.toString()),
                position: value,
                infoWindow: InfoWindow(
                  title: 'I am a marker',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
              ));
            });
          }
        }
        : null,
      ),
    );
  }
}