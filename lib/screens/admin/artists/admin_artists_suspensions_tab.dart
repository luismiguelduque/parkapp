import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../utils/constants.dart';
import '../../../widgets/empty_list.dart';
import '../../../utils/app_theme.dart';
import '../../../providers/artists_provider.dart';
import '../../../widgets/artist_item.dart';

class AdminArtistsSuspensionsTab extends StatefulWidget {
  @override
  _AdminArtistsSuspensionsTabState createState() => _AdminArtistsSuspensionsTabState();
}

class _AdminArtistsSuspensionsTabState extends State<AdminArtistsSuspensionsTab> {
  
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
          Text("Artistas suspendidos", style: TextStyle(color: AppTheme.getTheme().colorScheme.secondary, fontSize: 18),),
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
        if(artistsProvider.artistsSuspensions.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                artistsProvider.getArtists(null, _offset, _limit),
                artistsProvider.getArtistsRequests(null, _offset, _limit),
                artistsProvider.getArtistsSuspensions(null, _offset, _limit),
              ]);
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo){
                if (!_isLoadingPagination && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  if(artistsProvider.adminArtistTotalSuspensions > _limit){
                    paginacion(context);
                  }
                  return true;
                }
                return false;
              },
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: artistsProvider.artistsSuspensions.length,
                  itemBuilder: (context, index) => ArtistItem(artist: artistsProvider.artistsSuspensions[index],),
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
      eventsProvider.getArtistsSuspensions(null, _offset, _limit,),
    ]);
    _isLoadingPagination = false;
  }
}