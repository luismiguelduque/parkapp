import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../providers/places_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/functions.dart';
import '../../../widgets/custom_general_button.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_list.dart';

class SettingsPlacesList extends StatefulWidget {
  @override
  _SettingsPlacesListState createState() => _SettingsPlacesListState();
}

class _SettingsPlacesListState extends State<SettingsPlacesList> {

  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isSaving = false;
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
      bool internet = await check(context);
      if(internet){
        await Future.wait([
          placesProvider.getPlaces(),
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
    return Scaffold(
      //bottomNavigationBar: CustomBottomMenu(current: 4,),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        onPressed: (){
          Navigator.of(context).pushNamed('settings-places-form');
        },
        child: Icon(Icons.add, size: 35, color: Colors.white,),
      ),
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: (){
                            Navigator.of(context).pushNamed("settings");
                          },
                          icon: Icon(Icons.arrow_back),
                        ),
                        Text("Lugares de eventos", style: title3.copyWith(color: greyLightColor),),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.search, size: 35, color: primaryColor,),
                      onPressed: (){},
                    ),
                  ],
                )
              ),
              SizedBox(height: 5,),
              _tabsSection(),
              SizedBox(height: 5,),
              Expanded(
                child: _tabsContentSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabsSection(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(30)
      ),
      child: TabBar(
        indicatorColor: primaryColor,
        labelColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(
            child: Text("Todos", style: TextStyle(fontSize: 14),),
          ),
          Tab(
            child: Text("Restringidos", style: TextStyle(fontSize: 14),),
          ),
        ],
      ),
    );
  }

  Widget _tabsContentSection(){
    return Container(
      padding: EdgeInsets.only(bottom: 40),
      child: TabBarView(children: [
          _placesList(),
          _placesRestrictedList(),
        ]
      ),
    );
  }


  Widget _placesList(){
    return Consumer<PlacesProvider>(
      builder: (ctx, placesProvider, _){
        if(placesProvider.places.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              bool internet = await check(context);
              if(internet){
                await Future.wait([
                  placesProvider.getPlaces(),
                ]);
              }else{
                showErrorMessage(context, "No tienes conexión a internet");
              }
            },
            child: Scrollbar(
              child: ListView.builder(
                itemCount: placesProvider.places.length,
                itemBuilder: (context, index){
                  final item = placesProvider.places[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: (){
                          
                        },
                        child: ListTile(
                          leading: item.restricted == "1" ? Icon(Icons.lock, size: 25, color: redColor,) : Icon(Icons.lock_open, size: 25,),
                          title: Text("${item.name}", style: title3,),
                          subtitle: Text("${item.address}", style: text4,),
                          trailing: Wrap(
                          children: [
                            IconButton(
                              onPressed: (){
                                Navigator.pushNamed(context, 'settings-places-form', arguments: item.id);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: (){
                                _deleteItem(item.name, item.id);
                              },
                              icon: Icon(Icons.delete, color: redColor,),
                            ),
                          ],
                        ),
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
              )
            ),
          );
        return EmptyList(color: greyLightColor,);
      },
    );
  }

  Widget _placesRestrictedList(){
    return Consumer<PlacesProvider>(
      builder: (ctx, placesProvider, _){
        if(placesProvider.places.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              bool internet = await check(context);
              if(internet){
                await Future.wait([
                  placesProvider.getPlaces(),
                ]);
              }else{
                showErrorMessage(context, "No tienes conexión a internet");
              }
            },
            child: Scrollbar(
              child: ListView.builder(
                itemCount: placesProvider.placesRestricted.length,
                itemBuilder: (context, index){
                  final item = placesProvider.placesRestricted[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: (){
                          
                        },
                        child: ListTile(
                          leading: item.restricted == "1" ? Icon(Icons.lock, size: 25, color: redColor,) : Icon(Icons.lock_open, size: 25,),
                          title: Text("${item.name}", style: title3,),
                          subtitle: Text("${item.address}", style: text4,),
                          trailing: Wrap(
                          children: [
                            IconButton(
                              onPressed: (){
                                Navigator.pushNamed(context, 'settings-places-form', arguments: item.id);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: (){
                                _deleteItem(item.name, item.id);
                              },
                              icon: Icon(Icons.delete, color: redColor,),
                            ),
                          ],
                        ),
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
              )
            ),
          );
        return EmptyList(color: greyLightColor,);
      },
    );
  }

  _deleteItem(String description, int id) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return  AlertDialog(
              contentPadding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
              title: Container(
                alignment: Alignment.center,
                child: Text(
                  "¿Esta seguro en eliminar el lugar $description permanentemente?",
                  style: title2.copyWith(color:redColor),
                  textAlign: TextAlign.center,
                ),
              ),
              content: Container(
                width: size.width*0.9,
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomGeneralButton(
                            text: "Si",
                            loading: _isSaving,
                            color: AppTheme.getTheme().colorScheme.surface,
                            textStyle: title3,
                            width: size.width*0.3,
                            onPressed: () async {
                              bool internet = await check(context);
                              if(internet){
                                setState(() {
                                  _isSaving = true;
                                });
                                final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
                                final resp = await placesProvider.deletePlace(id);
                                if (resp['success']) {
                                  Navigator.pop(context);
                                  showSuccessMessage(context, resp["message"]);
                                  await placesProvider.getPlaces();
                                }else{ 
                                  showErrorMessage(context, resp["message"]);
                                }
                                _isSaving = false;
                              }else{
                                showErrorMessage(context, "No tienes conexión a internet");
                              }
                            },
                          ),
                          CustomGeneralButton(
                            text: "No",
                            loading: _isSaving,
                            color: AppTheme.getTheme().colorScheme.primary,
                            textStyle: title3,
                            width: size.width*0.3,
                            onPressed: () { Navigator.pop(context); },
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );

  }
}