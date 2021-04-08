import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
//import 'package:simple_auth_flutter/simple_auth_flutter.dart';

import './utils/app_theme.dart';
import './utils/preferences.dart';
import './providers/users_provider.dart';
import './providers/auth_provider.dart';
import './providers/events_provider.dart';
import './providers/artists_provider.dart';
import './providers/categories_provider.dart';
import './providers/places_provider.dart';
import './providers/genres_provider.dart';
import './providers/chat_provider.dart';
import './screens/common/forget_password.dart';
import './screens/common/messages/chat_screen.dart';
import './screens/common/profile/admin_profile_screen.dart';
import './screens/common/ask_location.dart';
import './screens/common/request_location_permission.dart';
import './screens/common/wellcome.dart';
import './screens/common/home.dart';
import './screens/common/sing_up.dart';
import './screens/common/sing_in.dart';
import './screens/audience/artist/audience_artist_all.dart';
import './screens/audience/artist_detail/artist_detail_screen.dart';
import './screens/audience/event_detail/event_detail_screen.dart';
import './screens/audience/events/audience_events_filter_screen.dart';
import './screens/audience/events/audience_events_screen.dart';
import './screens/audience/profile/audience_artist_request.dart';
import './screens/audience/profile/audience_profile_options_screen.dart';
import './screens/audience/schedule/schedule_screen.dart';
import './screens/admin/settings/settings_screen.dart';
import './screens/admin/artists/admin_artists_screen.dart';
import './screens/admin/events/admin_events_screen.dart';
import './screens/artist/profile/artist_profile_form.dart';
import './screens/artist/events/artist_event_form_screen.dart';
import './screens/artist/events/artist_events_screen.dart';
import './screens/artist/profile/artist_profile_options_screen.dart';
import './screens/admin/settings/settings_categories_list.dart';
import './screens/admin/settings/settings_genres_list.dart';
import './screens/admin/settings/settings_places_form.dart';
import './screens/admin/settings/settings_places_list.dart';
import './screens/audience/search/search_events_screen.dart';
import './screens/admin/chat/admin_messages_screen.dart';
import './screens/admin/chat/admin_chat_screen.dart';
import 'screens/common/alert_gps.dart';
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new Preferences();
  await prefs.initPrefs();
  runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //SimpleAuthFlutter.init(context);
    final String initialRoute = _getInitialRoute();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => EventsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CategoriesProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GenresProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PlacesProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ArtistsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => UsersProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ChatProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getTheme(),
        title: 'Park App',
        initialRoute: initialRoute,
        routes: {
          //Pantallas comunes entre perfiles
          'wellcome': (context) => Wellcome(),
          'home': (context) => Home(),
          'sing-up': (context) => SignUp(),
          'sing-in': (context) => SignIn(),
          'forget-password': (context) => ForgetPassword(),
          'artist-detail': (context) => ArtistDetailScreen(),
          'event-detail': (context) => EventDetailScreen(),
          'ask-location': (context) => AskLocation(),
          'alert-gps': (context) => AlertGps(),
          'search-screen': (context) => SearchEventScreen(),
          'request-location-permission': (context) => RequestLocationPermission(),
          'messages': (context) => ChatScreen(),
          //Pantallas para el perfil audiencia
          'audience-events': (context) => AudienceEventsScreen(),
          'audience-artists': (context) => AudienceArtistAll(),
          'audience-profile': (context) => AudienceProfileOptionsScreen(),
          'audience-artist-request': (context) => AudienceArtistRequest(),
          'audience-schedule': (context) => ScheduleScreen(),
          'audience-filter': (context) => AudienceEventsFilterScreen(),
          //Pantallas para el perfil artista
          'artist-events': (context) => ArtistEventsScreen(),
          'artist-events-form': (context) => ArtistEventFormScreen(),
          'artist-profile-form': (context) => ArtistProfileForm(),
          'artist-profile-options': (context)=> ArtistProfileoptionsScreen(),
          'artist-profile': (context) => ArtistProfileForm(),
          //Pantallas para el perfil administrador
          'admin-events': (context) => AdminEventsScreen(),
          'admin-artists': (context) => AdminArtistsScreen(),
          'admin-profile': (context) => AdminProfoleScreen(),  
          'settings': (context) => SettingsScreen(),
          'settings-places-list': (context) => SettingsPlacesList(),
          'settings-places-form': (context) => SettingsPlacesForm(),
          'settings-categories-list': (context) => SettingsCategoriesList(),
          'settings-genres-list': (context) => SettingsGenresList(),
          'admin-messages': (context) => AdminMessagesScreen(),
          'admin-chat-screen': (context) => AdminChatScreen(),
        },
      ),
    );
  }

  String _getInitialRoute(){
    final prefs = new Preferences();
    if(prefs.token!="0" && prefs.token!=null){
      if(prefs.cityId < 1 || prefs.neighborhoodId < 1){
        return "ask-location";
      }else{
        if(prefs.userTypeId==1){
          return "audience-events";
        }else if(prefs.userTypeId==2){
          return "artist-events";
        }else if(prefs.userTypeId==3){
          return "admin-events";
        }else{
          return "audience-events";
        }
      }
    }
    return "wellcome";
  }
}