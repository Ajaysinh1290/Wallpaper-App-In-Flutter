import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

class WallPaper {

  static final apiKey="";
  static String url='https://api.pexels.com/v1/search?query=';
  var totalResults;
  var page;
  var perPage;
  List<Photos> photos;
  var nextPage;
  var categoryName;
 static var error='';

  static  Future<WallPaper> getInstanceFromCategory(String category)async {


    try {
      error='';
      Response response=await get(url+category+"&per_page=20",
          headers: {"Authorization":WallPaper.apiKey});
      var data=jsonDecode(response.body);
      return WallPaper.fromJson(data,category);

    } on SocketException {
      error='No Internet Connection';
    }
    on TimeoutException {
      error='Connection Timeout';
    }
    on Error catch(e)
    {
      print(e);
    }
    return null;

  }

  WallPaper({
      this.totalResults, this.page, this.perPage, this.photos, this.nextPage});

  WallPaper.fromJson(Map<String,dynamic> data,String category) {
    this.categoryName=category;
    photos=List();
    totalResults=data['total-results'];
    page=data['page'];
    perPage=data['per_page'];
    data['photos'].forEach((photo) {

      photos.add(Photos.fromJson(photo));

    });
    nextPage=data['next_page'];
    print(nextPage);

  }


  loadNextPage()async {
    try {
      error='';
      Response response=await get(nextPage, headers: {"Authorization":apiKey});
      var data=jsonDecode(response.body);
      data['photos'].forEach((photo) {

        photos.add(Photos.fromJson(photo));
      });
      nextPage=data['next_page'];
    }
    on SocketException {
      error='No Internet Connection';
    }
    on TimeoutException {
      error='Connection Timeout';
    }
    on Error catch(e)
    {
      print(e);
    }
  }


}
class Photos {

  var id;
  var url;
  var photographer;
  var photographerUrl;
  var photographerId;
  var liked;
  Src src;

  Photos({this.id,this.url,this.photographer,this.photographerUrl,this.photographerId,this.src});

  Photos.fromJson(Map<String,dynamic> photos) {
    id=photos['id'];
    url=photos['url'];
    photographer=photos['photographer'];
    photographerUrl=photos['photographer_url'];
    photographerId=photos['photographer_id'];
    src=Src.fromJson(photos['src']);
    liked=photos['liked'];

  }

}
class Src {
  
  var original;
  var large2x;
  var large;
  var medium;
  var small;
  var portrait;
  var landscape;
  var tiny;

  Src({this.original, this.large2x, this.large, this.medium, this.small,
      this.portrait, this.landscape, this.tiny});

  Src.fromJson(Map<String,dynamic> src) {
    original=src['original'];
    large2x=src['large2x'];
    large=src['large'];
    medium=src['medium'];
    small=src['small'];
    portrait=src['portrait'];
    landscape=src['landscape'];
    tiny=src['tiny'];

  }
  
}
