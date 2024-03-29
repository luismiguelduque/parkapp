import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:simple_auth/simple_auth.dart' as simpleAuth;
import 'package:parkapp/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../utils/app_theme.dart';
import '../../utils/functions.dart';
import '../../utils/preferences.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_general_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../screens/admin/events/admin_events_screen.dart';
import '../../screens/artist/events/artist_events_screen.dart';
import '../../screens/audience/events/audience_events_screen.dart';
import '../../screens/common/ask_location.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  void initState() {
    super.initState();
    //SimpleAuthFlutter.init(context);
  }

  final GlobalKey<FormState> _formKey = GlobalKey();
  UserModel _tempUser = new UserModel();
  bool _isSaving = false;
  final _auth = FirebaseAuth.instance;
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
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: appBar(),
              ),
              Form(
                  key: _formKey,
                  child: Expanded(
                    child: SingleChildScrollView(
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
                          Text(
                            "O completa el formulario para crear tu cuenta",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTheme().disabledColor,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          CustomTextfield(
                            height: 56,
                            verticalMargin: 5,
                            label: "Nombre y Apellido",
                            maxLength: 100,
                            inputFormatters: 'textOnly',
                            onChanged: (value) {
                              _tempUser.name = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              return null;
                            },
                          ),
                          CustomTextfield(
                            height: 56,
                            verticalMargin: 5,
                            label: "E-mail",
                            inputFormatters: 'email',
                            onChanged: (value) {
                              _tempUser.email = value;
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
                              _tempUser.password = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              return null;
                            },
                          ),
                          CustomTextfield(
                            obscureText: true,
                            height: 56,
                            verticalMargin: 5,
                            label: "Repite la contraseña",
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              if (value != _tempUser.password) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          CustomGeneralButton(
                            onPressed: () => _save(context),
                            loading: _isSaving,
                            color: AppTheme.getTheme().colorScheme.secondary,
                            text: "Crear cuenta",
                            width: size.width * 0.8,
                            height: 50,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: 'Al registrarte aceptas ',
                                    style: text4.copyWith(
                                        color:
                                            AppTheme.getTheme().disabledColor),
                                  ),
                                  TextSpan(
                                    text:
                                        'los términos del servicio y políticas de privacidad',
                                    style: title4.copyWith(color: primaryColor),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        const url =
                                            'http://ec2-54-184-105-143.us-west-2.compute.amazonaws.com/terms';
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                  ),
                                ]),
                              )),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "¿Ya tienes una cuenta?.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.getTheme().disabledColor,
                                ),
                              ),
                              InkWell(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                onTap: () {
                                  Navigator.of(context).pushNamed("sing-in");
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Ingresa",
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
                            height: MediaQuery.of(context).padding.bottom + 24,
                          )
                        ],
                      ),
                    ),
                  ))
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
          final resp = await Provider.of<AuthProvider>(context, listen: false)
              .logInInstagram(user.token);
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
        final resp = await Provider.of<AuthProvider>(context, listen: false)
            .logInFacebook(result.accessToken.token);
        if (resp['success']) {
          _goLogin(resp);
        }
      } else {
        setState(() {
          _isSaving = false;
        });
      }
    } catch (error) {
      print(error);
    }
  }

  void _goLogin(resp) async {
    await FirebaseAuth.instance.signInAnonymously();
    showSuccessMessage(context, resp["message"]);
    await Future.delayed(const Duration(seconds: 3), () {});
    final prefs = new Preferences();
    if (prefs.token != "0" && prefs.token != null) {
      if (prefs.cityId < 1 || prefs.neighborhoodId < 1) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => AskLocation()));
      } else {
        if (prefs.userTypeId == 1) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AudienceEventsScreen()));
        } else if (prefs.userTypeId == 2) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ArtistEventsScreen()));
        } else if (prefs.userTypeId == 3) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AdminEventsScreen()));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AudienceEventsScreen()));
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
                if (!_isSaving)
                  Icon(
                      isFacebook
                          ? FontAwesomeIcons.facebookF
                          : FontAwesomeIcons.instagram,
                      size: 20,
                      color: Colors.white),
                SizedBox(
                  width: 4,
                ),
                if (!_isSaving)
                  Text(
                    isFacebook ? "Iniciar sesión con Facebook" : "Instagram",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                if (_isSaving) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
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
            "Crear cuenta",
            style: new TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _save(BuildContext context) async {
    bool internet = await check(context);
    if (internet) {
      if (!_formKey.currentState.validate()) {
        return;
      }
      _formKey.currentState.save();
      setState(() {
        _isSaving = true;
      });
      final resp = await Provider.of<AuthProvider>(context, listen: false)
          .signUp(_tempUser);
      if (resp['success']) {
        showSuccessMessage(context, resp["message"]);
        await Future.delayed(const Duration(seconds: 3), () {});
        final prefs = new Preferences();
        if (prefs.token != "0" && prefs.token != null) {
          if (prefs.cityId < 1 || prefs.neighborhoodId < 1) {
            Navigator.of(context).pushReplacementNamed("ask-location");
          } else {
            if (prefs.userTypeId == 1) {
              Navigator.of(context).pushReplacementNamed("audience-events");
            } else if (prefs.userTypeId == 2) {
              Navigator.of(context).pushReplacementNamed("artist-events");
            } else if (prefs.userTypeId == 3) {
              Navigator.of(context).pushReplacementNamed("admin-events");
            } else {
              Navigator.of(context).pushReplacementNamed("audience-events");
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
