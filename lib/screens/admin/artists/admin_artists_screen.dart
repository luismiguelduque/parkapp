import 'package:flutter/material.dart';
import 'package:parkapp/providers/chat_provider.dart';

import 'package:provider/provider.dart';

import './admin_artists_all_tab.dart';
import './admin_artists_requests_tab.dart';
import './admin_artists_suspensions_tab.dart';
import '../../../utils/app_theme.dart';
import '../../../providers/artists_provider.dart';
import '../../../widgets/custom_bottom_menu.dart';
import '../../../widgets/custom_textfield.dart';

class AdminArtistsScreen extends StatefulWidget {
  @override
  _AdminArtistsScreenState createState() => _AdminArtistsScreenState();
}

class _AdminArtistsScreenState extends State<AdminArtistsScreen> {
  
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
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await Future.wait([
        artistsProvider.getArtists(null, _offset, _limit),
        artistsProvider.getArtistsRequests(null, _offset, _limit),
        artistsProvider.getArtistsSuspensions(null, _offset, _limit),
        chatProvider.getAdminAllConversation(),
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
        child: DefaultTabController(
        length: 3,
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
                              artistsProvider.getArtists(value, _offset, _limit),
                              artistsProvider.getArtistsRequests(value, _offset, _limit),
                              artistsProvider.getArtistsSuspensions(value, _offset, _limit),
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
                              artistsProvider.getArtists(null, _offset, _limit),
                              artistsProvider.getArtistsRequests(null, _offset, _limit),
                              artistsProvider.getArtistsSuspensions(null, _offset, _limit),
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
              _tabsSection(),
              Expanded(
                child: _isLoadingSearch
                ? Center(
                  child: CircularProgressIndicator(),
                ) 
                : _tabsContentSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _tabsSection(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.getTheme().colorScheme.secondary,
        borderRadius: BorderRadius.circular(30)
      ),
      child: TabBar(
        indicatorColor: AppTheme.getTheme().colorScheme.primary,
        labelColor: AppTheme.getTheme().colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(
            child: Text("Todos", style: TextStyle(fontSize: 14), softWrap: false,),
          ),
          Tab(
            child: Text("Solicitudes", style: TextStyle(fontSize: 14), softWrap: false,),
          ),
          Tab(
            child: Text("Suspensiones", style: TextStyle(fontSize: 14), softWrap: false,),
          ),
        ],
      ),
    );
  }

  Widget _tabsContentSection(){
    return Container(
      child: TabBarView(children: [
          AdminArtistsAllTab(),
          AdminArtistsRequestsTab(), 
          AdminArtistsSuspensionsTab(),
        ]
      ),
    );
  }
}