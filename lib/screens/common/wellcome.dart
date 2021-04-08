import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:parkapp/utils/app_theme.dart';
import 'package:parkapp/widgets/custom_general_button.dart';

class Wellcome extends StatefulWidget {
  @override
  _WellcomeState createState() => _WellcomeState();
}

class _WellcomeState extends State<Wellcome> {

  var pageController = PageController(initialPage: 0);
  Timer sliderTimer;
  var currentShowIndex = 0;

  @override
  void initState() {
    sliderTimer = Timer.periodic(Duration(seconds: 6), (timer) {
      if (currentShowIndex == 0) {
        pageController.animateTo(
          MediaQuery.of(context).size.width,
          duration: Duration(seconds: 1), 
          curve: Curves.fastOutSlowIn
        );
      } else if (currentShowIndex == 1) {
        pageController.animateTo(
          MediaQuery.of(context).size.width * 2,
          duration: Duration(seconds: 1), 
          curve: Curves.fastOutSlowIn
        );
      } else if (currentShowIndex == 2) {
        pageController.animateTo(
          0,
          duration: Duration(seconds: 1), 
          curve: Curves.fastOutSlowIn
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    sliderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Stack(
          children: [
            PageView(
              controller: pageController,
              onPageChanged: (index) {
                currentShowIndex = index;
              },
              children: [
                _pageViewItem(context, "assets/images/wellcome1.png", "Encontrá arte, cultura y eventos cerca de tu casa", ""),
                _pageViewItem(context, "assets/images/wellcome2.png", "Si sos artista", "Sumá tus eventos y compartilo con tu público"),
                _pageViewItem(context, "assets/images/wellcome3.png", "La ciudad es el escenario.", "Plazas, parques, centros culturales y cientos de espacios para disfrutar música, baile,circo y mucho más"),
              ],
            ),
            Positioned(
              top: size.height*0.7,
              child: Container(
                width: size.width,
                child: Column(
                  children: [
                    /*
                    PageIndicator(
                      layout: PageIndicatorLayout.WARM,
                      size: 15.0,
                      controller: pageController,
                      space: 5.0,
                      count: 3,
                      color: AppTheme.getTheme().dividerColor,
                      activeColor: AppTheme.getTheme().primaryColor,
                    ),
                    */
                    SizedBox(height: 20,),
                    CustomGeneralButton(
                      onPressed: (){
                        Navigator.of(context).pushNamed('sing-in');
                      },
                      text: "Ingresar",
                      width: size.width*0.7,
                      height: 50,
                      color: AppTheme.getTheme().colorScheme.secondary,
                    ),
                    SizedBox(height: 10,),
                    CustomGeneralButton(
                      onPressed: (){
                        Navigator.of(context).pushNamed('sing-up');
                      },
                      text: "Crear cuenta",
                      width: size.width*0.7,
                      height: 50,
                      color: AppTheme.getTheme().colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageViewItem(BuildContext context, String imagePath, String message, String subTitle){
    final size = MediaQuery.of(context).size;
    return Container(
      child: Stack(
        children: [
          Container(
            width: size.width,
            child: Image(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: size.height*0.08,
            child: Container(
              width: size.width,
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 65,
                backgroundImage: AssetImage(
                  "assets/images/icon.png"
                ),
              )
            ),
          ),
          Positioned(
            top: size.height*0.4,
            child: Container(
              width: size.width,
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: size.width*0.15),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, shadows: <Shadow>[
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 5.0,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ],),
                    ),
                  ),
                  if(subTitle != "")
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: size.width*0.15),
                      child: Text(
                        subTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal, color: Colors.white, shadows: <Shadow>[
                          Shadow(
                            offset: Offset(0, 0),
                            blurRadius: 5.0,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ],),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}