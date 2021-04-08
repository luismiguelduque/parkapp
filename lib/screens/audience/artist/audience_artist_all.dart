import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../utils/app_theme.dart';
import '../../../providers/artists_provider.dart';
import '../../../screens/audience/artist/artist_all_tab.dart';
import '../../../widgets/custom_bottom_menu.dart';
import '../../../widgets/custom_textfield.dart';

class AudienceArtistAll extends StatefulWidget {
  @override
  _AudienceArtistAllState createState() => _AudienceArtistAllState();
}

class _AudienceArtistAllState extends State<AudienceArtistAll> {
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isLoadingSearch = false;
  bool _searchFilter = false;
  int _offset = 0;
  int _limit = 20;
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      final artistsProvider = Provider.of<ArtistsProvider>(context, listen: false);
      await Future.wait([
        artistsProvider.getArtistsAudience(null, _offset, _limit),
      ]);
      setState(() {
        _isLoading = false;
        _isLoaded = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: Container(
        height: 58 + MediaQuery.of(context).padding.bottom,
        child: CustomBottomMenu(current: 2)
      ),
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Artistas", style: AppTheme.getTheme().textTheme.headline1,),
                  !_searchFilter
                  ? IconButton(
                    icon: Icon(Icons.search, color: AppTheme.getTheme().colorScheme.primary, size: 35,),
                    onPressed: () {
                      setState(() {
                        _searchFilter = !_searchFilter;
                      });
                    },
                  )
                  : Row(
                    children: [
                      CustomTextfield(
                        label: "Buscar...",
                        width: size.width*0.4,
                        height: 45.0,
                        onChanged: (value) async {
                          final artistsProvider = Provider.of<ArtistsProvider>(context, listen: false);
                          setState(() { 
                            _isLoadingSearch = true;
                          });
                          await Future.wait([
                            artistsProvider.getArtistsAudience(value, _offset, _limit),
                          ]);
                          setState(() { 
                            _isLoadingSearch = false;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: AppTheme.getTheme().colorScheme.primary, size: 35,),
                        onPressed: () async {
                          final artistsProvider = Provider.of<ArtistsProvider>(context, listen: false);
                          setState(() { 
                            _isLoadingSearch = true;
                            _searchFilter = !_searchFilter;
                          });
                          await Future.wait([
                            artistsProvider.getArtistsAudience(null, _offset, _limit),
                          ]);
                          if(this.mounted) {
                            setState(() { _isLoadingSearch = false; });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              )
            ),
            SizedBox(height: 5,),
            Expanded(
              child: _isLoadingSearch
              ? Center(
                child: CircularProgressIndicator(),
              ) 
              : ArtistsAllTab(),
            ),
          ],
        ),
      ),
    );
  }
}