import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:parkapp/utils/constants.dart';
import 'package:parkapp/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/app_theme.dart';
import '../../utils/functions.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_general_button.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isSaving = false;
  String _email;
  bool _showMessage = false;
  //final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Scaffold(
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: appBar(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: _showMessage 
                  ? Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 30,),
                          Icon(Icons.check_circle_outline, size: 80.0, color: Colors.green,),
                          SizedBox(height: 15,),
                          Text("Correo para reestablecer contraseña enviado con exito",
                            style:title3.copyWith(color: greyLightColor),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20,),
                          Text(
                            "Revisa en tu bandeja de entrada y sigue las instrucciones para reestablecer la contraseña, en caso de no estar revisa tu bandeja de spam",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTheme().disabledColor,
                            ),
                          ),
                          SizedBox(height: 20,),                        
                        ],
                      )
                    ) 
                  : Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 30,),
                        Text(
                          "Por favor, ingresa tu email para restablecer tu contraseña. Revisá tu bandeja de entrada.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getTheme().disabledColor,
                          ),
                        ),
                        SizedBox(height: 20,),
                        CustomTextfield(
                          height: 56,
                          verticalMargin: 5,
                          label: "E-mail",
                          onChanged: (value){
                            _email = value;
                          },
                          validator: (value){
                            if (value.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10,),
                        CustomGeneralButton(
                          onPressed: ()=> _forgetPassword(context),
                          loading: _isSaving,
                          color: AppTheme.getTheme().colorScheme.secondary,
                          text: "Enviar email",
                          width: size.width*0.8,
                          height: 50,
                        ),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getFTButton({bool isFacebook: true}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: HexColor(isFacebook ? "#3C5799" : "#7D32AA"),
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.getTheme().dividerColor,
            blurRadius: 8,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          highlightColor: Colors.transparent,
          onTap: () {},
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon( 
                  isFacebook ? FontAwesomeIcons.facebookF : FontAwesomeIcons.instagram,
                  size: 20,
                  color: Colors.white
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  isFacebook ? "Facebook" : "Instagram",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: AppBar().preferredSize.height,
          child: Padding(
            padding: EdgeInsets.only(top: 8, left: 8),
            child: Container(
              width: AppBar().preferredSize.height - 8,
              height: AppBar().preferredSize.height - 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 24),
          child: Text(
            "Restablecer contraseña",
            style: new TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _forgetPassword(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isSaving = true;
    });
    final resp = await Provider.of<AuthProvider>(context, listen: false).forgetPassword(_email);
    if (resp['success']) {
      showSuccessMessage(context, resp["message"]);
      _showMessage = true;
    }else{ 
      showErrorMessage(context, resp["message"]);
    }
    setState(() {
      _isSaving = false;
    });
  }
}
