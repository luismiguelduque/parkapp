import 'package:flutter/material.dart';

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
  
  GoogleMapController mapController;
  Position _currentPosition;
  
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  bool _isLoaded = false;

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _currentPosition = await getCurrentUserLocation();
      _animateMapCamera();
      if(this.mounted) {
        _isLoaded = true;
      }
    }
    super.didChangeDependencies();
  }
  
  void _animateMapCamera(){
    if(this.mounted) {
      try{
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: widget.useLocation ? LatLng(_currentPosition.latitude, _currentPosition.longitude) : LatLng(widget.markers.first.position.latitude, widget.markers.first.position.longitude),
              zoom: 14.0,
            ),
          ),
        );    
      }catch(error){
        print(error);
      }       
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
        markers: Set<Marker>.of(widget.markers),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
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