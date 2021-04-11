import 'package:flutter/material.dart';
import 'package:parkapp/providers/artists_provider.dart';
import 'package:parkapp/utils/constants.dart';
import 'package:parkapp/utils/functions.dart';

import 'package:provider/provider.dart';

import '../../../providers/events_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/custom_rating_widget.dart';

class ArtistEventsResumeTab extends StatefulWidget {
  @override
  _ArtistEventsResumeTabState createState() => _ArtistEventsResumeTabState();
}

class _ArtistEventsResumeTabState extends State<ArtistEventsResumeTab> {

  bool showFilter = false;
  bool _isLoaded = false;
  bool _isLoading = true;
  
  @override
  void didChangeDependencies() async {
    if (!_isLoaded) {
      _isLoading = true;
      bool internet = await check(context);
      if(internet){
        await Provider.of<ArtistsProvider>(context, listen: false).getArtistIndicators();
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
    final artistProvider = Provider.of<ArtistsProvider>(context, listen: false);
    return Consumer<EventsProvider>(
      builder: (ctx, eventsProvider, _){
        return _isLoading ? Center(
          child: CircularProgressIndicator(),
          ) :Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15,),
                Text("Tu resumen", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18),),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _containerResume(
                      Container(child: Icon(Icons.important_devices, size: 50, color: artistProvider.artistIndicators.countEvents > 0 ? primaryColor : greyColor,)), 
                      "${artistProvider.artistIndicators.countEvents}", 
                      "Eventos en total",
                      false
                    ),
                    _containerResumeRating(
                      Container(child: CustomRatingWidget(ranking: artistProvider.artistIndicators.rating,)), 
                      "${artistProvider.artistIndicators.countRatings}",
                      "Calificaron tus eventos",
                      false
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _containerResume(
                      Container(child: Icon(Icons.favorite_border, size: 50, color: artistProvider.artistIndicators.countScheduled > 0 ? primaryColor : greyColor,)), 
                      "${artistProvider.artistIndicators.countScheduled}",
                      "Agendaron tus eventos",
                      false
                    ),
                    _containerResume(
                      Container(child: Icon(Icons.new_releases, size: 50, color: artistProvider.artistIndicators.countComplaints > 0 ? redColor : greyColor,)), 
                      "${artistProvider.artistIndicators.countComplaints}", 
                      "Denunciaron tus eventos",
                      false
                    ),
                  ],
                ),
              ],
            ),
          )
        );
      },
    );
  }

  Widget _containerResume(Widget element, String amaunt, String text, bool isRed){
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width*0.4,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 2.5,
            blurRadius: 3.5,
            offset: Offset(0, 2)
          )
        ]
      ),
      child: Column(
        children: [
          element,
          SizedBox(height: 10,),
          Text("$amaunt", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isRed ? Colors.red : AppTheme.getTheme().colorScheme.secondary),),
          SizedBox(height: 10,),
          Text("$text", style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: isRed ? Colors.red : AppTheme.getTheme().colorScheme.secondary), textAlign: TextAlign.center,),
        ],
      ),
    );
  }

  Widget _containerResumeRating(Widget element, String amaunt, String text, bool isRed){
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width*0.4,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 2.5,
            blurRadius: 3.5,
            offset: Offset(0, 2)
          )
        ]
      ),
      child: Column(
        children: [
          element,
          SizedBox(height: 10,),
          Text("$amaunt", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isRed ? Colors.red : AppTheme.getTheme().colorScheme.secondary),),
          SizedBox(height: 10,),
          Text("$text", style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: isRed ? Colors.red : AppTheme.getTheme().colorScheme.secondary), textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}