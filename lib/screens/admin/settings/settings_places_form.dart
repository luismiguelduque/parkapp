
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../models/neighborhood_model.dart';
import '../../../models/place_model.dart';
import '../../../providers/places_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/functions.dart';
import '../../../widgets/custom_general_button.dart';
import '../../../widgets/custom_map_widget.dart';
import '../../../widgets/custom_textfield.dart';

class SettingsPlacesForm extends StatefulWidget {
  SettingsPlacesForm({Key key}) : super(key: key);

  @override
  _SettingsPlacesFormState createState() => _SettingsPlacesFormState();
}

class _SettingsPlacesFormState extends State<SettingsPlacesForm> {

  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isSaving=false;
  BitmapDescriptor pinLocationIcon;
  String _title;
  PlaceModel _placeTemp = new PlaceModel(
    neighborhood: new NeighborhoodModel(),
    restricted: "2",
  );
  List<Marker> _markers = [];

  @override
  void didChangeDependencies() async {
    if (!_isLoaded) {
      final int placeId = ModalRoute.of(context).settings.arguments;
      setCustomMapPin();
      _isLoading = true;
      if (placeId != null) {
        setState(() {
          _placeTemp = Provider.of<PlacesProvider>(context, listen: false).places.firstWhere((item) => item.id == placeId);
          _title = "Editar lugar de eventos";
          _markers.add(
            Marker(
              markerId: MarkerId('${_placeTemp.id}'),
              position: LatLng(double.parse(_placeTemp.lat), double.parse(_placeTemp.long)),
              icon: pinLocationIcon,
              onDragEnd: ((newPosition) {
                print(newPosition.latitude);
                print(newPosition.longitude);
              }),
              draggable: true,
              infoWindow: InfoWindow(
                title: '${_placeTemp.name}'
              )
            ),
          );
        });
      }else{
        setState(() {
          _title = "Crear un lugar de eventos";
        });
      }
      setState(() {
        _isLoading = false;
        _isLoaded = true;
      });
    }
    super.didChangeDependencies();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: 2.5,
      ), 
      'assets/images/simple-icon.png'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerScreen(),
              Expanded(
                child: _formSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerScreen() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
              ),
              Text("$_title", style: title1.copyWith(color: greyLightColor),),
            ],
          ),
        ],
      )
    );
  }

  Widget _formSection() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            CustomTextfield(
              height: 50,
              value: _placeTemp.name,
              label: 'Nombre',
              onChanged: (value){
                _placeTemp.name = value;
              },
            ),
            SizedBox(height: 11.0,),
            CustomTextfield(
              height: 50,
              value: _placeTemp.description,
              label: 'Descripción',
              maxLines: 2,
              onChanged: (value){
                _placeTemp.description = value;
              },
            ),
            SizedBox(height: 10.0,),
            _iconFieldItem(Icons.location_on, "${ _placeTemp.neighborhood.id == null ? 'Barrio' : _placeTemp.neighborhood.name}", _showDialogPlaces),
            SizedBox(height: 8.0,),
            CustomTextfield(
              height: 50,
              value: _placeTemp.address,
              label: 'Dirección',
              onChanged: (value){
                _placeTemp.address = value;
              },
            ),
            SizedBox(height: 11.0,),
            Container(
              width: double.infinity,
              height: 220,
              child: CustomMapWidget(
                useLocation: _placeTemp.id == null,
                onCLick: (val){
                  _markers.add(
                    Marker(
                      markerId: MarkerId('${_placeTemp.id}'),
                      position: val,
                      icon: pinLocationIcon,
                      onDragEnd: ((newPosition) {
                        print(newPosition.latitude);
                        print(newPosition.longitude);
                      }),
                      draggable: true,
                      infoWindow: InfoWindow(
                        title: '${_placeTemp.name}'
                      )
                    ),
                  );
                  setState(() {
                    _placeTemp.lat = val.latitude.toString();
                    _placeTemp.long = val.longitude.toString();
                  });
                }, 
                markers: _markers
              )
            ),
            SizedBox(height: 11.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("Restringido", style: text3.copyWith(color: greyLightColor),),
                    Switch(
                      activeColor: secondaryColor,
                      onChanged: (value){
                        if(!value) {
                          _placeTemp.dailyLimit = 0;
                        }
                        setState(() {
                          _placeTemp.restricted = value ?  "1" : "2";
                        });
                      },
                      value: _placeTemp.restricted == "1",
                    ),
                  ],
                ),
                CustomTextfield(
                  keyboardType: TextInputType.number,
                  height: 50,
                  width: 150,
                  value: (_placeTemp.dailyLimit != null && _placeTemp.restricted == "1") ? _placeTemp.dailyLimit.toString() : null,
                  label: 'Límite Diario',
                  readOnly: _placeTemp.restricted == "2",
                  numbersOnly: true,
                  maxLength: 4,
                  onChanged: (value){
                    _placeTemp.dailyLimit = int.parse(value) ;
                  },

                ),
              ],
            ),
            SizedBox(height: 20.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomGeneralButton(
                  onPressed: (){
                    _save();
                  },
                  loading: _isSaving,
                  color: AppTheme.getTheme().colorScheme.primary,
                  text: "Guardar",
                  width: 220,
                  height: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconFieldItem(IconData icon, String text, Function(BuildContext context) onPress){
    return GestureDetector(
      onTap: () => onPress(context),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppTheme.getTheme().colorScheme.secondary,),
            SizedBox(width: 15,),
            Text(text, style: TextStyle(fontSize: 18),),
          ],
        ),
      ),
    );
  }

  void _showDialogPlaces(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialig) {
            return  AlertDialog(
              contentPadding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
              title: Container(
                alignment: Alignment.center,
                child: Text(
                  "Seleciona el barrio",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              content: Consumer<PlacesProvider>(
                builder: (ctx, placesProvider, _){
                  return Container(
                    width: size.width*0.9,
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    child: ListView.builder(
                      itemCount: placesProvider.neighborhoods.length,
                      itemBuilder: (context, index){
                        final NeighborhoodModel item = placesProvider.neighborhoods[index];
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                setStateDialig((){
                                  _placeTemp.neighborhood = item;
                                });
                                setState(() { });
                                Navigator.of(context).pop();
                              },
                              child: ListTile(
                                leading: Icon(Icons.location_on, size: 30, color: _placeTemp.neighborhood.id != item.id ? greyLightColor : AppTheme.getTheme().colorScheme.primary,),
                                title: Text("${item.name}"),
                                trailing: IconButton(
                                  onPressed: (){},
                                  icon: Icon(Icons.arrow_forward),
                                ),
                              ),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }
        );
      },
    );
  }

  void _save() async {
    bool internet = await check(context);
    if(internet){
      setState(() {
        _isSaving = true;
      });
      Map resp;
      if(_placeTemp.id != null){
        resp = await Provider.of<PlacesProvider>(context, listen: false).updatePlace(_placeTemp);
      }else{
        resp = await Provider.of<PlacesProvider>(context, listen: false).savePlace(_placeTemp);
      }
      if (resp['success']) {
        showSuccessMessage(context, resp["message"]);
        await Future.delayed(const Duration(seconds: 3), (){});
        Navigator.of(context).pushNamed("settings-places-list");
      }else{ 
        showErrorMessage(context, resp["message"]);
      }
      setState(() {
        _isSaving = false;
      });
    }else{
      showErrorMessage(context, "No tienes conexion a internet");
    }
  }
}