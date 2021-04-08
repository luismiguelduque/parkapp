import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _instance = new Preferences._internal();

  factory Preferences(){
    return _instance;
  }

  Preferences._internal();

  SharedPreferences _prefs;

  initPrefs() async {
    this._prefs = await SharedPreferences.getInstance();
  }

  get token{
    return _prefs.getString('token') ?? "0";
  }
  set token(String value){
    _prefs.setString('token', value);
  }

  get expireToken{
    return _prefs.getInt('expire_token') ?? 0;
  }
  set expireToken(int value){
    _prefs.setInt('expire_token', value);
  }

  get name{
    return _prefs.getString('name') ?? "";
  }
  set name(String value){
    _prefs.setString('name', value);
  }

  get email{
    return _prefs.getString('email') ?? "";
  }
  set email(String value){
    _prefs.setString('email', value);
  }

  get phone{
    return _prefs.getString('phone') ?? 0;
  }
  set phone(String value){
    _prefs.setString('phone', value);
  }

  get userId{
    return _prefs.getInt('user_id') ?? 0;
  }
  set userId(int value){
    _prefs.setInt('user_id', value);
  }

  get userType{
    return _prefs.getString('user_type') ?? 0;
  }
  set userType(String value){
    _prefs.setString('user_type', value);
  }

  get userTypeId{
    return _prefs.getInt('user_type_id') ?? 0;
  }
  set userTypeId(int value){
    _prefs.setInt('user_type_id', value);
  }

  get provinceId{
    return _prefs.getInt('province_id') ?? 0;
  }
  set provinceId(int value){
    _prefs.setInt('province_id', value);
  }

  get cityId{
    return _prefs.getInt('city_id') ?? 0;
  }
  set cityId(int value){
    _prefs.setInt('city_id', value);
  }

  get neighborhoodId{
    return _prefs.getInt('neighborhood_id') ?? 0;
  }
  set neighborhoodId(int value){
    _prefs.setInt('neighborhood_id', value);
  }

  get artistId{
    return _prefs.getInt('artist_id') ?? 0;
  }
  set artistId(int value){
    _prefs.setInt('artist_id', value);
  }

  get artistName{
    return _prefs.getString('artist_name') ?? 0;
  }
  set artistName(String value){
    _prefs.setString('artist_name', value);
  }

  get artistPhoto{
    return _prefs.getString('artist_photo') ?? 0;
  }
  set artistPhoto(String value){
    _prefs.setString('artist_photo', value);
  }
}