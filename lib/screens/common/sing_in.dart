import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:simple_auth/simple_auth.dart' as simpleAuth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/functions.dart';
import '../../utils/preferences.dart';
import '../../widgets/custom_general_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../screens/admin/events/admin_events_screen.dart';
import '../../screens/artist/events/artist_events_screen.dart';
import '../../screens/audience/events/audience_events_screen.dart';
import '../../screens/common/ask_location.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  void initState() {
    super.initState();
    //SimpleAuthFlutter.init(context);
  }

  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isSaving = false;
  String _email;
  String _password;
  String _errorMsg;
  Map _userData;

  final simpleAuth.InstagramApi _igApi = simpleAuth.InstagramApi(
    "instagram",
    igClientId,
    igClientSecret,
    igRedirectURL,
    scopes: [
      'user_profile', // For getting username, account type, etc.
    ],
  );

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
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: appBar(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 25, bottom: 10),
                          child: Text(
                            !Platform.isAndroid ? "Ingresa con tu cuenta de:" : "Ingresa con tu cuenta de facebook",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTheme().disabledColor,
                            ),
                          ),
                        ),
                        Container(
                          child: getFTButton(),
                          width: 300.0,
                        ),
                        if( !Platform.isAndroid )
                          SizedBox(
                            height: 16,
                          ),
                        if( !Platform.isAndroid )
                          Container(
                            child: getAppleButton(),
                            width: 300.0,
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "O ingresa con tu email y contraseña",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTheme().disabledColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        CustomTextfield(
                          height: 56,
                          verticalMargin: 5,
                          label: "E-mail",
                          inputFormatters: 'email',
                          onChanged: (value) {
                            _email = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Este campo es requerido';
                            } else if (!validateEmail(value)) {
                              return 'El email es inválido';
                            }
                            return null;
                          },
                        ),
                        CustomTextfield(
                          obscureText: true,
                          height: 56,
                          verticalMargin: 5,
                          label: "Contraseña",
                          onChanged: (value) {
                            _password = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "¿Olvidaste tu contraseña?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.getTheme().disabledColor,
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              onTap: () {
                                Navigator.of(context).pushNamed("forget-password");
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Cambiala",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.getTheme().primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CustomGeneralButton(
                          onPressed: () => _login(context),
                          loading: _isSaving,
                          color: AppTheme.getTheme().colorScheme.secondary,
                          text: "Iniciar sesión",
                          width: size.width * 0.8,
                          height: 50,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "¿No tienes una cuenta?.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.getTheme().disabledColor,
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              onTap: () {
                                Navigator.of(context).pushNamed("sing-up");
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Crea una",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.getTheme().primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 24,
                        )
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

  Future<void> _loginAndGetDataIG() async {
    try {
      _igApi.authenticate().then(
        (simpleAuth.Account _user) async {
          simpleAuth.OAuthAccount user = _user;
          setState(() {
            _errorMsg = null;
          });
          final resp = await Provider.of<AuthProvider>(context, listen: false).logInInstagram(user.token);
          if (resp['success']) {
            _goLogin(resp);
          } else {
            showErrorMessage(context, resp["message"]);
          }
        },
      ).catchError(
        (Object e) {
          if (this.mounted) {
            setState(() {
              _isSaving = false;
              _errorMsg = e.toString();
            });
          }
        },
      );
    } catch (error) {
      print(error);
    }
  }

  Future<void> _loginAndGetDataApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        /*webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.parkappar.app',
          redirectUri: Uri.parse(
            'https://parkapp-8940b.firebaseapp.com/__/auth/handler',
          ),
        ),*/
        // TODO: Remove these if you have no need for them
        //nonce: 'example-nonce',
        //state: 'example-state',
      );
      print("****** TESTTEST ******");
      print(credential);
      
      setState(() {
        _errorMsg = null;
      });
      final resp = await Provider.of<AuthProvider>(context, listen: false).logInApple(credential.authorizationCode);
      if (resp['success']) {
        _goLogin(resp);
      } else {
        showErrorMessage(context, resp["message"]);
      }
      
    } catch (error) {
      print("****** TEST ERROR ******");
      print(error);
      if (this.mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _loginAndGetDataFB() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final resp = await Provider.of<AuthProvider>(context, listen: false).logInFacebook(result.accessToken.token);
        if (resp['success']) {
          _goLogin(resp);
        } else {
          showErrorMessage(context, resp["message"]);
        }
      } else {
        setState(() {
          _isSaving = false;
        });
      }
    } catch (error) {
      print(error);
      if (this.mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _goLogin(resp) async {
    await FirebaseAuth.instance.signInAnonymously();
    showSuccessMessage(context, resp["message"]);
    await Future.delayed(const Duration(seconds: 3), () {});
    final prefs = new Preferences();
    if (prefs.token != "0" && prefs.token != null) {
      if (prefs.cityId < 1 || prefs.neighborhoodId < 1) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AskLocation()));
      } else {
        if (prefs.userTypeId == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AudienceEventsScreen()));
        } else if (prefs.userTypeId == 2) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ArtistEventsScreen()));
        } else if (prefs.userTypeId == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AdminEventsScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AudienceEventsScreen()));
        }
      }
    }
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
          onTap: () async {
            if (!_isSaving) {
              setState(() {
                _isSaving = true;
              });
              if (isFacebook) {
                await _loginAndGetDataFB();
              } else {
                await _loginAndGetDataIG();
              }
            }
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (!_isSaving) Icon(isFacebook ? FontAwesomeIcons.facebookF : FontAwesomeIcons.instagram, size: 20, color: Colors.white),
                SizedBox(
                  width: 4,
                ),
                if (!_isSaving)
                  Text(
                    isFacebook ? "Iniciar sesión con Facebook" : "Instagram",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                  ),
                if (_isSaving) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getAppleButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: HexColor("#000000"),
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
          onTap: () async {
            if (!_isSaving) {
              setState(() {
                _isSaving = true;
              });
              await _loginAndGetDataApple();
            }
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (!_isSaving) Icon(FontAwesomeIcons.apple, size: 20, color: Colors.white),
                SizedBox(
                  width: 4,
                ),
                if (!_isSaving)
                  Text(
                    "Iniciar sesión con Apple",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                  ),
                if (_isSaving) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //com.parkappar.app
  //7BF74LV274

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
            "Iniciar Sesión",
            style: new TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _login(BuildContext context) async {
    bool internet = await check(context);
    if (internet) {
      if (!_formKey.currentState.validate()) {
        return;
      }
      _formKey.currentState.save();
      setState(() {
        _isSaving = true;
      });
      final resp = await Provider.of<AuthProvider>(context, listen: false).logIn(_email, _password);
      print(resp['success']);
      if (resp['success']) {
        await _auth.signInAnonymously();
        showSuccessMessage(context, resp["message"]);
        await Future.delayed(const Duration(seconds: 3), () {});
        final prefs = new Preferences();
        if (prefs.token != "0" && prefs.token != null) {
          if (prefs.cityId < 1 || prefs.neighborhoodId < 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AskLocation()));
          } else {
            if (prefs.userTypeId == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AudienceEventsScreen()));
            } else if (prefs.userTypeId == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ArtistEventsScreen()));
            } else if (prefs.userTypeId == 3) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AdminEventsScreen()));
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AudienceEventsScreen()));
            }
          }
        }
      } else {
        showErrorMessage(context, resp["message"]);
      }
      setState(() {
        _isSaving = false;
      });
    } else {
      showErrorMessage(context, "No tienes conexión a internet");
    }
  }
}
