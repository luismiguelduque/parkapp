import 'package:flutter/material.dart';
import 'package:parkapp/utils/functions.dart';

import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/custom_bottom_menu.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool showFilter = false;
  bool _isLoaded = false;
  bool _isLoading = true;

  @override
  void didChangeDependencies() async {
    if (!_isLoaded) {
      _isLoading = true;
      bool internet = await check(context);
      if(internet){
        await Provider.of<AuthProvider>(context, listen: false).getUser();
      }else{
        showErrorMessage(context, "No tienes conexión a internet");
      }
      setState(() {
        _isLoading = false;
      });
      _isLoaded = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      bottomNavigationBar: Container(
        height: 58 + MediaQuery.of(context).padding.bottom,
        child: CustomBottomMenu(current: 4)
      ),
      body:SafeArea(
        child: Consumer<AuthProvider>(
          builder: (ctx, authProvider, _) {
            if (_isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Ajustes", style: AppTheme.getTheme().textTheme.headline1,),
                        ],
                      )
                    ),
                    SizedBox(height: 70,),
                    _accordionItem(context, Icons.arrow_forward_ios, (){
                      Navigator.of(context).pushNamed("settings-places-list");
                    }, "Lugares de eventos"),
                    Divider(),
                    _accordionItem(context, Icons.arrow_forward_ios, (){
                      Navigator.of(context).pushNamed("settings-categories-list");
                    }, "Categorías de eventos"),
                    Divider(),
                    _accordionItem(context, Icons.arrow_forward_ios, (){
                      Navigator.of(context).pushNamed("settings-genres-list");
                    }, "Géneros artísticos"),
                    Divider(),
                  ],
                ),
              );
            }
          }
        ),
      )
    );
  }

  Widget _accordionItem(BuildContext context, IconData icon, Function function, String title){
    return GestureDetector(
      onTap: function,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 18),),
            Icon(icon, color: Colors.grey, size: 30,),
          ],
        ),
      ),
    );
  }
}