import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../utils/app_theme.dart';
import '../../../widgets/custom_bottom_menu.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../utils/constants.dart';
import '../../../providers/chat_provider.dart';
import '../../../widgets/empty_list.dart';

class AdminMessagesScreen extends StatefulWidget {
  @override
  _AdminMessagesScreenState createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {

  bool _isLoaded = false;
  bool _isLoading = false;
  bool _searchFilter = false;
  bool _isLoadingSearch = false;
  bool _isLoadingPagination = false;
  int _offsetArtist = 0;
  int _limitArtist = 20;
  int _offsetUser = 0;
  int _limitUser = 20;
  
  @override
  void didChangeDependencies() async {
    if(!_isLoaded){
      _isLoading = true;
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await Future.wait([
        chatProvider.getAdminAllConversation(),
        chatProvider.getAdminConversation(null, _offsetUser, _limitUser, 1),
        chatProvider.getAdminConversation(null, _offsetArtist, _limitArtist, 2),
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
        child: CustomBottomMenu(current: 3)
      ),
      body: _isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Mensajes", style: title1.copyWith(color: greyLightColor),),
                      ],
                    ),
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
                            setState(() { 
                              _isLoadingSearch = true;
                            });
                            final chatProvier = Provider.of<ChatProvider>(context, listen: false);
                            await Future.wait([
                              chatProvier.getAdminConversation(value, _offsetUser, _limitUser, 1),
                              chatProvier.getAdminConversation(value, _offsetArtist, _limitArtist, 2),
                            ]);
                            setState(() { 
                              _isLoadingSearch = false;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel, color: AppTheme.getTheme().colorScheme.primary, size: 35,),
                          onPressed: () async {
                            setState(() { 
                              _isLoadingSearch = true;
                              _searchFilter = !_searchFilter;
                            });
                            final chatProvier = Provider.of<ChatProvider>(context, listen: false);
                            await Future.wait([
                              chatProvier.getAdminConversation(null, _offsetUser, _limitUser, 1),
                              chatProvier.getAdminConversation(null, _offsetArtist, _limitArtist, 2),
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
              SizedBox(height: 5,),
              Expanded(
                child: _tabsContentSection(),
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
        color: secondaryColor,
        borderRadius: BorderRadius.circular(30)
      ),
      child: TabBar(
        indicatorColor: primaryColor,
        labelColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(
            child: Text("Artistas", style: TextStyle(fontSize: 14),),
          ),
          Tab(
            child: Text("Usuarios", style: TextStyle(fontSize: 14),),
          ),
        ],
      ),
    );
  }

  Widget _tabsContentSection(){
    return Container(
      child: TabBarView(children: [
          _artistsList(),
          _usersList(),
        ]
      ),
    );
  }


  Widget _artistsList(){
    return Consumer<ChatProvider>(
      builder: (ctx, chatProvier, _){
        if(chatProvier.adminConversationsArtists.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                chatProvier.getAdminConversation(null, _offsetArtist, _limitArtist, 2),
              ]);
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo){
                if (!_isLoadingPagination && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  if(chatProvier.adminConversationsArtistTotal > _limitArtist){
                    paginacion(2);
                  }
                  return true;
                }
                return false;
              },
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: chatProvier.adminConversationsArtists.length,
                  itemBuilder: (context, index){
                    final item = chatProvier.adminConversationsArtists[index];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Provider.of<ChatProvider>(context, listen: false).setRead(item.id);
                            Navigator.of(context).pushNamed("admin-chat-screen", arguments: item.id);
                          },
                          child: ListTile(
                            leading: Container(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage("${item.user.artist.profileImage}"),
                                  ),
                                  if(item.unreadAdmin == "1")
                                    Positioned(
                                      child: CircleAvatar(
                                        backgroundColor: redColor,
                                        radius: 7,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            title: Text("${item.user.name}", style: title3,),
                            subtitle: Text("${item.lastMessage}", style: text4,),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  },
                )
              ),
            ),
          );
        return EmptyList(color: greyLightColor,);
      },
    );
  }

  Widget _usersList(){
    return Consumer<ChatProvider>(
      builder: (ctx, chatProvier, _){
        if(chatProvier.adminConversationsUsers.length > 0)
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                chatProvier.getAdminConversation(null, _offsetUser, _limitUser, 1),
              ]);
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo){
                if (!_isLoadingPagination && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  if(chatProvier.adminConversationsUserTotal > _limitUser){
                    paginacion(1);
                  }
                  return true;
                }
                return false;
              },
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: chatProvier.adminConversationsUsers.length,
                  itemBuilder: (context, index){
                    final item = chatProvier.adminConversationsUsers[index];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Provider.of<ChatProvider>(context, listen: false).setRead(item.id);
                            Navigator.of(context).pushNamed("admin-chat-screen", arguments: item.id);
                          },
                          child: ListTile(
                            leading: Container(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: AssetImage("assets/images/simple-icon.png"),
                                  ),
                                  if(item.unreadAdmin == "1")
                                    Positioned(
                                      child: CircleAvatar(
                                        backgroundColor: redColor,
                                        radius: 7,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            title: Text("${item.user.name}", style: title3,),
                            subtitle: Text("${item.lastMessage}", style: text4,),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  },
                )
              ),
            ),
          );
        return EmptyList(color: greyLightColor,);
      },
    );
  }

  void paginacion(int userType) async {
    _isLoadingPagination = true;
    int _offset;
    int _limit;
    if(userType == 1) {
      _limitUser += 20;
      _offsetUser += 20;
      _offset = _limitUser;
      _limit = _offsetUser;
    } else if(userType == 2){
      _limitArtist += 20;
      _offsetArtist += 20;
      _offset = _limitArtist;
      _limit = _offsetArtist;
    }
    
    final chatProvier = Provider.of<ChatProvider>(context, listen: false);
    await Future.wait([
      chatProvier.getAdminConversation(null, _offset, _limit, userType),
    ]);
    _isLoadingPagination = false;
  }
}