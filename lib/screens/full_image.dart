import 'dart:io';
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:wallpaper_app/models/wallpaper.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';


class FullImage extends StatefulWidget {
  static final routeName='/fullImage';
  @override
  _FullImageState createState() => _FullImageState();
}

class _FullImageState extends State<FullImage> {

  PageController pageController;
  GlobalKey<ScaffoldState> scaffoldKey=GlobalKey();
  WallPaper wallPaper;
  int photoIndex=0;
  GlobalKey<RefreshIndicatorState> refreshKey;

  Future<void> setWallpaperLockScreen() async {
    String url = wallPaper.photos[photoIndex].src.portrait;
    int location = WallpaperManager.LOCK_SCREEN;
    var file = await DefaultCacheManager().getSingleFile(url);
    final String result = await WallpaperManager.setWallpaperFromFile(file.path, location);
    print(result);
    Navigator.of(context).pop();
    _showSnackBar('Wallpaper set Successfully');
  }

  Future<void> setWallpaperHomeScreen() async {
      String url = wallPaper.photos[photoIndex].src.portrait;
      int location = WallpaperManager.HOME_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(url);
      final String result = await WallpaperManager.setWallpaperFromFile(file.path, location);
      print(result);
      Navigator.of(context).pop();
      _showSnackBar('Wallpaper set Successfully');
  }

  Future<void> setWallpaperBothScreen() async {
    String url = wallPaper.photos[photoIndex].src.portrait;
    int location = WallpaperManager.BOTH_SCREENS;
    var file = await DefaultCacheManager().getSingleFile(url);
    final String result = await WallpaperManager.setWallpaperFromFile(file.path, location);
    print(result);
    Navigator.of(context).pop();
    _showSnackBar('Wallpaper set Successfully');
  }
  getBottomSheetBarWidget(String text,function()) {
    return  Container(
      width:double.infinity,

        child: TextButton(
            onPressed: function,
            child: Text(
                text,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness!=Brightness.dark?Colors.black.withOpacity(0.90):Colors.white.withOpacity(0.90),
              ),
            ),
         ),
    );
  }
  void showApplyWallpaperBottomSheet(BuildContext context) {

    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
          return Padding(

            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: new BoxDecoration(
                        color: Theme.of(context).brightness==Brightness.dark?Colors.grey[900].withOpacity(0.80):Colors.white.withOpacity(0.80),
                        borderRadius: new BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getBottomSheetBarWidget('Set Lockscreen',setWallpaperLockScreen),
                      Divider(),
                      getBottomSheetBarWidget('Set Homescreen',setWallpaperHomeScreen),
                      Divider(),
                      getBottomSheetBarWidget('Set Both',setWallpaperBothScreen),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  decoration: new BoxDecoration(
                      color: Theme.of(context).brightness==Brightness.dark?Colors.grey[900].withOpacity(0.99):Colors.white.withOpacity(0.90),

                      borderRadius: new BorderRadius.circular(10.0)
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getBottomSheetBarWidget('Cancel',() {
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
              ],
            ),
          );
      }
    );

  }
  void shareImage() async {
    try {
      var request = await HttpClient()
          .getUrl(Uri.parse(wallPaper.photos[photoIndex].src.large2x));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      
      await Share.file('ESYS AMLOG', 'amlog.jpg', bytes, 'image/jpg');
    } on Exception catch (e) {
      // 
      _showSnackBar("No Internet Connection");
    }
  }

  downloadImage() async {
    try {

      // Saved with this method.
      var imageId = await ImageDownloader.downloadImage(wallPaper.photos[photoIndex].src.portrait);
      if (imageId == null) {
        _showSnackBar("Error");
        return;
      }
      _showSnackBar("Image Successfully Downloaded");
    }
    on PlatformException catch (error) {
    }
  }

  Future<void> _showSnackBar(String text) async {
    scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor:  Theme.of(context).brightness==Brightness.dark?Colors.black54:Colors.white.withOpacity(0.8),
          margin: EdgeInsets.all(30.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
          elevation: 0.5,
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          content: Center(
            heightFactor: 0.9,
            child: Text(
             text,
             style: TextStyle(
               color: Theme.of(context).brightness!=Brightness.dark?Colors.black:Colors.white,
                 fontSize: 16
             ),
      ),
          ),
    )
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshKey=GlobalKey();
  }
  @override
  Widget build(BuildContext context) {

    if(pageController==null) {
      Map data = ModalRoute
          .of(context)
          .settings
          .arguments;
      wallPaper = data['wallpaper'];
      photoIndex = data['index'];
      pageController = PageController(
        initialPage: photoIndex,
      );
    }
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        elevation: 0,
      ),
      floatingActionButton: Row(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Container(
            margin: EdgeInsets.only(left: 30),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              color: Colors.white54,
            ),
            child: IconButton(
              onPressed: ()=>downloadImage(),
              icon: Icon(
                Icons.download_sharp,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(

                colors: [
                  Colors.redAccent,
                  Colors.indigoAccent
                ]
              ),
            ),
            child: FlatButton(

              padding: EdgeInsets.only(left: 30,top: 10,right: 30,bottom: 10),
              onPressed: () async {
                showApplyWallpaperBottomSheet(context);
              },

              child: Text(
                  'Apply Wallpaper',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
                ),
              ),
            ),
          ),
          Container(
           decoration: BoxDecoration(
             color: Colors.white54,
             borderRadius: BorderRadius.circular(20.0)
           ),
            child: IconButton(
              onPressed: ()=>shareImage(),
             icon: Icon(
               Icons.share,
               color: Colors.black,

             ),
            ),
          )
        ],
      ),
      body: wallPaper==null
          ?Center(child: CircularProgressIndicator(),)
          :Container(
          child: PageView.builder(
            controller: pageController,

          itemCount: wallPaper.photos.length,
            itemBuilder: (context,index){
              photoIndex=index;
              return InteractiveViewer(
                boundaryMargin: EdgeInsets.all(0.0),
                minScale: 0.1,
                maxScale: 20,
                child:Hero(
                  tag: wallPaper.photos[index].src,
                    child: Image.network(
                      wallPaper.photos[photoIndex].src.portrait,fit: BoxFit.cover,
                       errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                        print('in func');
                        return Center(child: Icon(Icons.wifi_off,size: 50,));
                      },
                    )
                ),
              );
            },
        ),
      ),
    );
  }
}
