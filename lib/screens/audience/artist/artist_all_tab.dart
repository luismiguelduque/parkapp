import 'package:flutter/material.dart';
import 'package:parkapp/models/artist_model.dart';
import 'package:parkapp/utils/preferences.dart';

import 'package:provider/provider.dart';

import '../../../widgets/empty_list.dart';
import '../../../utils/constants.dart';
import '../../../utils/app_theme.dart';
import '../../../providers/artists_provider.dart';
import '../../../widgets/artist_item.dart';

class ArtistsAllTab extends StatefulWidget {
  @override
  _ArtistsAllTabState createState() => _ArtistsAllTabState();
}

class _ArtistsAllTabState extends State<ArtistsAllTab> {
  final _preferences = new Preferences();
  bool _isLoadingPagination = false;
  int _offset = 0;
  int _limit = 20;
  bool _complainedsOnly = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Todos los artistas", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18),),
              SizedBox(width: 20,),
              if(_preferences.userId == 3)
                Row(
                  children: [
                    Switch(
                      activeColor: secondaryColor,
                      onChanged: (value){
                        setState(() {
                          _complainedsOnly = value;
                        });
                      },
                      value: _complainedsOnly,
                    ),
                    Text("Denunciados", style: text4.copyWith(color:secondaryColor),),
                  ],
                ),
            ],
          ),
          SizedBox(height: 15,),
          _headerSection(),
          Expanded(
            child: _artistssList(),
          ),
        ],
      )
    );
  }

  Widget _headerSection(){
    return Container();
  }

  Widget _artistssList(){
    return Consumer<ArtistsProvider>(
      builder: (ctx, artistsProvider, _){
        final List<ArtistModel> list = _complainedsOnly ? artistsProvider.artistsComplaints : artistsProvider.artists;
        if(list.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                artistsProvider.getArtistsAudience(null, _offset, _limit),
              ]);
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo){
                if (!_isLoadingPagination && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  if(artistsProvider.adminArtistTotal > _limit){
                    paginacion(context);
                  }
                  return true;
                }
                return false;
              },
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) => ArtistItem(artist: list[index],),
                )
              ),
            ),
          );
        return EmptyList(color: greyLightColor,);
      },
    );
  }
  
  void paginacion(BuildContext context) async {
    _isLoadingPagination = true;
    _offset+=20;
    _limit+=20;
    final eventsProvider = Provider.of<ArtistsProvider>(context, listen: false);
    await Future.wait([
      eventsProvider.getArtistsAudience(null, _offset, _limit,),
    ]);
    _isLoadingPagination = false;
  }
}