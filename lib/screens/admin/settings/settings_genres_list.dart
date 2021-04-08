import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../providers/genres_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/functions.dart';
import '../../../widgets/custom_general_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../models/artistic_genres_model.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_list.dart';

class SettingsGenresList extends StatefulWidget {
  @override
  _SettingsGenresListState createState() => _SettingsGenresListState();
}

class _SettingsGenresListState extends State<SettingsGenresList> {

  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String _description;
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      final genresProvider = Provider.of<GenresProvider>(context, listen: false);
      await Future.wait([
        genresProvider.getArtisticGenres(),
      ]);
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
          _genresForm(null, null);
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
                    Text("Géneros artísticos", style: title2.copyWith(color: greyLightColor),),
                  ],
                )
              ),
              SizedBox(height: 10,),
              Expanded(
                child: _genresList(),
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget _genresList(){
    return Consumer<GenresProvider>(
      builder: (ctx, genresProvider, _){
        if(genresProvider.artisticGenres.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                //genresProvider.getAudienceEventsAll(),
              ]);
            },
            child: Scrollbar(
              child: ListView.builder(
                itemCount: genresProvider.artisticGenres.length,
                itemBuilder: (context, index) {
                  final ArtisticGenreModel item = genresProvider.artisticGenres[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text("${item.name}", style: text3,),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              onPressed: (){
                                _genresForm(item.name, item.id);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: (){
                                _deleteGenres(item.name, item.id);
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

    _genresForm(String description, int id) {
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
                  id != null ? "Editar el género artístico" : "Crear nuevo género artísitco",
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
                              setState((){
                                _isSaving = true;
                              });
                              final genresProvider = Provider.of<GenresProvider>(context, listen: false);
                              Map<String, dynamic> response;
                              if( id != null) {
                                response = await genresProvider.updateCategoryGenre(id, _description);
                              } else {
                                response = await genresProvider.storeEventCatGenre(_description);
                              }
                              setState((){
                                _isSaving = false;
                              });
                              Navigator.pop(context);
                              if (response['success']) {
                                if (id != null) {
                                  showSuccessMessage(context, "El género artístico editado exitosamente");
                                } else if (id == null) {
                                  showSuccessMessage(context, "El género artístico creado exitosamente");
                                }
                                genresProvider.getArtisticGenres();
                              } else {
                                showErrorMessage(context, "Ha habido un problema al procesar su peticion. Por favor, intente nuevamente.");
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

  _deleteGenres(String description, int id) {
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
                              setState((){
                                _isSaving = true;
                              });
                              final genresProvider = Provider.of<GenresProvider>(context, listen: false);
                              Map<String, dynamic> response = await genresProvider.deleteCategoryGenre(id);
                              setState((){
                                _isSaving = false;
                              });
                              Navigator.pop(context);
                              if (response['success']) {
                                showSuccessMessage(context, "La categoría del evento eliminada exitosamente");
                                genresProvider.getArtisticGenres();
                              } else {
                                showErrorMessage(context, "Ha habido un problema al procesar su peticion. Por favor, intente nuevamente.");
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