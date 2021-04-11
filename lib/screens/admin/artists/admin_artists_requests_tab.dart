import 'package:flutter/material.dart';
import 'package:parkapp/utils/functions.dart';

import 'package:provider/provider.dart';

import '../../../utils/constants.dart';
import '../../../widgets/empty_list.dart';
import '../../../utils/app_theme.dart';
import '../../../providers/artists_provider.dart';
import '../../../widgets/artist_item.dart';

class AdminArtistsRequestsTab extends StatefulWidget {
  @override
  _AdminArtistsRequestsTabState createState() => _AdminArtistsRequestsTabState();
}

class _AdminArtistsRequestsTabState extends State<AdminArtistsRequestsTab> {

  bool _isLoadingPagination = false;
  int _offset = 0;
  int _limit = 20;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15,),
          Consumer<ArtistsProvider>(
            builder: (ctx, artistsProvider, _){
              return Row(
                children: [
                  Text("${artistsProvider.artistsRequests.length}", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18, fontWeight: FontWeight.bold),),
                  SizedBox(width: 5.0,),
                  Text("Solicitudes de artistas", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18),),
                ],
              );
            }
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
        if(artistsProvider.artistsRequests.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              bool internet = await check(context);
              if(internet){
                await Future.wait([
                  artistsProvider.getArtists(limit: _limit, offset: _offset, search: null),
                  artistsProvider.getArtistsRequests(limit: _limit, offset: _offset, search: null),
                  artistsProvider.getArtistsSuspensions(limit: _limit, offset: _offset, search: null),
                ]);
              }else{
                showErrorMessage(context, "No tienes conexión a internet");
              }
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo){
                if (!_isLoadingPagination && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  if(artistsProvider.adminArtistTotalRequests > _limit){
                    paginacion(context);
                  }
                  return true;
                }
                return false;
              },
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: artistsProvider.artistsRequests.length,
                  itemBuilder: (context, index) => ArtistItem(artist: artistsProvider.artistsRequests[index],),
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
      eventsProvider.getArtistsRequests(limit: _limit, offset: _offset, search: null),
    ]);
    _isLoadingPagination = false;
  }
}