import 'package:flutter/material.dart';
import 'package:parkapp/utils/functions.dart';

import 'package:provider/provider.dart';

import '../../../utils/app_theme.dart';
import '../../../providers/events_provider.dart';
import '../../../providers/places_provider.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_bottom_menu.dart';
import '../../../screens/admin/events/admin_events_all_tab.dart';
import '../../../screens/admin/events/admin_events_complaint_tab.dart';
import '../../../screens/admin/events/admin_events_pending.dart';

class AdminEventsScreen extends StatefulWidget {
  @override
  _AdminEventsScreenState createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  
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
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
      bool internet = await check(context);
      if(internet){
        await Future.wait([
          eventsProvider.getAdminEventsAll(limit: _limit, offset: _offset, search: null),
          eventsProvider.getAdminEventsPending(limit: _limit, offset: _offset, search: null),
          eventsProvider.getAdminEventsComplained(limit: _limit, offset: _offset, search: null),
          placesProvider.getPlaces(),
        ]);
      }else{
        showErrorMessage(context, "No tienes conexión a internet");
      }
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        bottomNavigationBar: Container(
          height: 58 + MediaQuery.of(context).padding.bottom,
          child: CustomBottomMenu(current: 1)
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
                      Text("Eventos", style: AppTheme.getTheme().textTheme.headline1,),
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
                              final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
                              setState(() { 
                                _isLoadingSearch = true;
                              });
                              bool internet = await check(context);
                              if(internet){
                                await Future.wait([
                                  eventsProvider.getAdminEventsAll(limit: _limit, offset: _offset, search: value),
                                  eventsProvider.getAdminEventsPending(limit: _limit, offset: _offset, search: value),
                                  eventsProvider.getAdminEventsComplained(limit: _limit, offset: _offset, search: value),
                                ]);
                              }else{
                                showErrorMessage(context, "No tienes conexión a internet");
                              }
                              setState(() { 
                                _isLoadingSearch = false;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel, color: AppTheme.getTheme().colorScheme.primary, size: 35,),
                            onPressed: () async {
                              final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
                              setState(() { 
                                _isLoadingSearch = true;
                                _searchFilter = !_searchFilter;
                              });
                              bool internet = await check(context);
                              if(internet){
                                await Future.wait([
                                  eventsProvider.getAdminEventsAll(limit: _limit, offset: _offset, search: null),
                                  eventsProvider.getAdminEventsPending(limit: _limit, offset: _offset, search: null),
                                  eventsProvider.getAdminEventsComplained(limit: _limit, offset: _offset, search: null),
                                ]);
                              }else{
                                showErrorMessage(context, "No tienes conexión a internet");
                              }
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
            child: Text("Todos", style: TextStyle(fontSize: 13), softWrap: false,),
          ),
          Tab(
            child: Text("Pendientes", style: TextStyle(fontSize: 13), softWrap: false,),
          ),
          Tab(
            child: Text("Denuncias", style: TextStyle(fontSize: 13), softWrap: false,),
          ),
        ],
      ),
    );
  }

  Widget _tabsContentSection(){
    return Container(
      child: TabBarView(children: [
          AdminEventsAllTab(),
          AdminEventsPendingTab(),
          AdminEventsComplaintTab(),
        ]
      ),
    );
  }
}