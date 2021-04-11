import 'package:flutter/material.dart';

import 'package:parkapp/utils/app_theme.dart';
import 'package:provider/provider.dart';

import '../../../models/event_category_model.dart';
import '../../../providers/categories_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/functions.dart';
import '../../../widgets/custom_general_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/empty_list.dart';

class SettingsCategoriesList extends StatefulWidget {
  @override
  _SettingsCategoriesListState createState() => _SettingsCategoriesListState();
}

class _SettingsCategoriesListState extends State<SettingsCategoriesList> {

  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String _description;
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
      bool internet = await check(context);
      if(internet){
        await Future.wait([
          categoriesProvider.getEventCategory(),
        ]);
      }else{
        showErrorMessage(context, "No tienes conexion a internet");
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        onPressed: (){
          _categoryForm(null, null);
        },
        child: Icon(Icons.add, size: 35, color: Colors.white,),
      ),
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SafeArea(
        child: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    Text("Categorías de eventos", style: title2.copyWith(color: greyLightColor),),
                  ],
                )
              ),
              SizedBox(height: 10,),
              Expanded(
                child: _categoriesList(),
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget _categoriesList(){
    return Consumer<CategoriesProvider>(
      builder: (ctx, categoriesProvider, _){
        if(categoriesProvider.categories.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              bool internet = await check(context);
              if(internet){
                await Future.wait([
                  categoriesProvider.getEventCategory(),
                ]);
              }else{
                showErrorMessage(context, "No tienes conexion a internet");
              }
            },
            child: Scrollbar(
              child: ListView.builder(
                itemCount: categoriesProvider.categories.length,
                itemBuilder: (context, index) {
                  final EventCategoryModel item = categoriesProvider.categories[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text("${item.name}", style: text3,),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              onPressed: (){
                                _categoryForm(item.name, item.id);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: (){
                                _deleteCatedories(item.name, item.id);
                              },
                              icon: Icon(Icons.delete, color: redColor,),
                            ),
                          ],
                        ),

                      ),
                      Divider(),
                    ],
                  );
                }
              )
            ),
          );
        return EmptyList(color: greyLightColor,);
      },
    );
  }

  _categoryForm(String description, int id) {
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
                  id != null ? "Editar la categoría del evento" : "Crear nueva categoría para los eventos",
                  style: title2,
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: CustomTextfield(
                          value: description,
                          onChanged: (value){
                            _description = value;
                          },
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomGeneralButton(
                            text: id != null ? "Editar" : "Crear",
                            loading: _isSaving,
                            color: id != null ? AppTheme.getTheme().colorScheme.surface : AppTheme.getTheme().colorScheme.primary,
                            textStyle: title3,
                            width: size.width*0.3,
                            onPressed: _isSaving ? null : () async {
                              bool internet = await check(context);
                              if(internet){
                                setState((){
                                  _isSaving = true;
                                });
                                final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
                                Map<String, dynamic> response;
                                if( id != null) {
                                  response = await categoriesProvider.updateCategoryEvent(id, _description);
                                } else {
                                  response = await categoriesProvider.storeEventCategory(_description);
                                }
                                setState((){
                                  _isSaving = false;
                                });
                                Navigator.pop(context);
                                if (response['success']) {
                                  if (id != null) {
                                    showSuccessMessage(context, "La categoría del evento editada exitosamente");
                                  } else if (id == null) {
                                    showSuccessMessage(context, "La categoría del evento creada exitosamente");
                                  }
                                  categoriesProvider.getEventCategory();
                                } else {
                                  showErrorMessage(context, "Ha habido un problema al procesar su peticion. Por favor, intente nuevamente.");
                                }
                              }else{
                                showErrorMessage(context, "No tienes conexion a internet");
                              }
                            },
                          ),
                          if(id != null)
                            CustomGeneralButton(
                              text: "Cancelar",
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

  _deleteCatedories(String description, int id) {
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
                  "¿Esta seguro en eliminar la categoría $description permanentemente?",
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
                            onPressed: _isSaving ? null : () async {
                              bool internet = await check(context);
                              if(internet){
                                setState((){
                                  _isSaving = true;
                                });
                                final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
                                Map<String, dynamic> response = await categoriesProvider.deleteCategoryEvent(id);
                                setState((){
                                  _isSaving = false;
                                });
                                Navigator.pop(context);
                                if (response['success']) {
                                  showSuccessMessage(context, "La categoría del evento eliminada exitosamente");
                                  categoriesProvider.getEventCategory();
                                } else {
                                  showErrorMessage(context, "Ha habido un problema al procesar su peticion. Por favor, intente nuevamente.");
                                }
                              }else{
                                showErrorMessage(context, "No tienes conexion a internet");
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