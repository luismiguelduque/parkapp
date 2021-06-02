import 'package:flutter/material.dart';
import 'package:parkapp/utils/functions.dart';

import 'package:provider/provider.dart';

import '../../providers/places_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_general_button.dart';

class AskLocation extends StatefulWidget {
  @override
  _AskLocationState createState() => _AskLocationState();
}

class _AskLocationState extends State<AskLocation> {

  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isSaving = false;
  int _provinceId;
  int _cityId; 
  int _neighborhoodId;

  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
      bool internet = await check(context);
      if(internet){
        await Future.wait([
          placesProvider.getProvinces(),
          placesProvider.getCities(),
          placesProvider.getNeighborhoods(),
        ]);
      }else{
        showErrorMessage(context, "No tienes conexión a internet");
      }
      setState(() {
        _isLoading = false;
        _isLoaded = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SafeArea(
        child: Consumer<PlacesProvider>(
          builder: (ctx, placesProvider, _){
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: size.height*0.05,),
                  Image(
                    height: 100,
                    image: AssetImage("assets/images/map-icon.png"),
                  ),
                  Container(
                    width: size.width,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: size.width*0.25),
                    child: Text("Contanos dónde estas", textAlign: TextAlign.center, style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 32, fontWeight: FontWeight.bold),)
                  ),
                  Container(
                    child: CustomDropdown(
                      label: "Provincia",
                      height: 55,
                      items: placesProvider.provinces.map((item) => {'value': item.id.toString(), 'label': item.name}).toList(),
                      onChanged: (value){
                        _provinceId = int.parse(value);
                      },
                    ),
                  ),
                  Container(
                    child: CustomDropdown(
                      label: "Ciudad",
                      height: 55,
                      items: placesProvider.cities.map((item) => {'value': item.id.toString(), 'label': item.name}).toList(),
                      onChanged: (value){
                        _cityId = int.parse(value);
                      },
                    ),
                  ),
                  Container(
                    child: CustomDropdown(
                      label: "Barrio",
                      height: 55,
                      items: placesProvider.neighborhoods.map((item) => {'value': item.id.toString(), 'label': item.name}).toList(),
                      onChanged: (value){
                        _neighborhoodId = int.parse(value);
                      },
                    ),
                  ),
                  SizedBox(height: 10,),
                  CustomGeneralButton(
                    height: 50,
                    loading: _isSaving,
                    width: size.width*0.8,
                    color: AppTheme.getTheme().colorScheme.primary,
                    text: "Seleccionar",
                    onPressed: () async {
                      bool internet = await check(context);
                      if(internet){
                        setState(() {
                          _isSaving = true;
                        });
                        await Provider.of<PlacesProvider>(context, listen: false).updateUserLocation(_provinceId, _cityId, _neighborhoodId);
                        setState(() {
                          _isSaving = false;
                        });
                        Navigator.of(context).pushNamed('alert-gps');
                      }else{
                        showErrorMessage(context, "No tienes conexión a internet");
                      }
                    },
                  ),
                  SizedBox(height: size.height*0.1,),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}