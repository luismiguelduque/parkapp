import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/functions.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_general_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_bottom_menu.dart';

class AdminProfoleScreen extends StatefulWidget {
  @override
  _AdminProfoleScreenState createState() => _AdminProfoleScreenState();
}

class _AdminProfoleScreenState extends State<AdminProfoleScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _showAccess = false;
  bool showFilter = false;
  bool _isLoaded = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String _currentPassword;
  String _newPassword;
  String _repeatNewPassword;

  @override
  void didChangeDependencies() async {
    if (!_isLoaded) {
      _isLoading = true;
      bool internet = await check(context);
      if(internet){
        await Provider.of<AuthProvider>(context, listen: false).getUser();
      }else{
        showErrorMessage(context, "No tienes conexion a internet");
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
        child: CustomBottomMenu(current: 5)
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
                          Text("Perfil", style: AppTheme.getTheme().textTheme.headline1,),
                        ],
                      )
                    ),
                    SizedBox(height: 70,),
                    _accordionItem(context, Icons.lock_outline, (){
                      _passwordForm();
                    }, "Cambiar contraseña"),
                    Divider(),
                    _accordionItem(
                      context, 
                      Icons.call_missed_outgoing, 
                      () {
                        logOutConfirmation(context);
                      }, 
                      "Cerrar sesión"),
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

  _passwordForm() {
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
                  "Cambia tu contraseña",
                  style: title2,
                  textAlign: TextAlign.center,
                ),
              ),
              content: Form(
                key: _formKey,
                child: Container(
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
                            label: "Contraseña actual",
                            obscureText: true,
                            onChanged: (value){
                              _currentPassword = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: CustomTextfield(
                            label: "Nueva contraseña",
                            obscureText: true,
                            onChanged: (value){
                              _newPassword = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: CustomTextfield(
                            label: "Repetir nueva contraseña",
                            obscureText: true,
                            onChanged: (value){
                              _repeatNewPassword = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Este campo es requerido';
                              } else if (value != _newPassword) {
                                return 'La nueva contraseña no coincide';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomGeneralButton(
                              text: "Cambiar contraseña",
                              loading: _isSaving,
                              color: AppTheme.getTheme().colorScheme.primary,
                              textStyle: title3,
                              width: size.width*0.6,
                              onPressed: _isSaving ? null : () async {
                                bool internet = await check(context);
                                if(internet){
                                  if (!_formKey.currentState.validate()) {
                                    return;
                                  }
                                  _formKey.currentState.save();
                                  setState(() {
                                    _isLoading = true;
                                    _showAccess = false;
                                    _isSaving = true;
                                  });
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  Map<String, dynamic> response = await authProvider.changePassword(_currentPassword, _newPassword, _repeatNewPassword);
                                  setState((){
                                    _isSaving = false;
                                  });
                                  if (response['success']) {
                                    Navigator.of(context).pushNamed('admin-profile');
                                    showSuccessMessage(context, response['message']);
                                  } else {
                                    showErrorMessage(context, response['message']);
                                  }
                                }else{
                                  showErrorMessage(context, "No tienes conexion a internet");
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                      ],
                    ),
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