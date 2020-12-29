import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/models/wallpaper.dart';

import 'package:wallpaper_app/screens/home_page.dart';
import 'full_image.dart';

class MoreWallpaper extends StatefulWidget {
  static final String routeName='moreWallpaper';
  @override
  _MoreWallpaperState createState() => _MoreWallpaperState();
}

class _MoreWallpaperState extends State<MoreWallpaper> {
  WallPaper wallPaper;
  int totalPhotos=0;
  bool isLoading=false;
  GlobalKey<RefreshIndicatorState> refreshKey;

  @override
  void initState() {
      super.initState();
      refreshKey=GlobalKey();
  }

  nextButton() {
    return wallPaper.nextPage==null?Container():GestureDetector(
      onTap: () async {
        if(!isLoading) {
            setState(() {
              isLoading = true;
            });

            await wallPaper.loadNextPage();
            setState(() {
              isLoading = false;
              totalPhotos = wallPaper.photos.length;
            });
        }
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness==Brightness.dark?HomePage.darkColor:HomePage.lightColor,
          borderRadius: BorderRadius.circular(20)
        ),

        child: isLoading?Center(child:CircularProgressIndicator()): Icon(
          WallPaper.error.isNotEmpty?Icons.error:Icons.add,
          color:  Theme.of(context).brightness!=Brightness.dark?HomePage.darkColor:HomePage.lightColor,
          size: 30,
          ),

      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    Map data=ModalRoute.of(context).settings.arguments;
    wallPaper=data['wallpaper'];
    bool found=true;
    if(wallPaper==null||wallPaper.photos.length==0)  {
      found=false;
    }else {
      totalPhotos=wallPaper.photos.length;
    }

    return Scaffold(
      appBar: AppBar(
        title:Text(
           found?wallPaper.categoryName:'',
            style: TextStyle(
              color: Theme.of(context).brightness!=Brightness.dark?Colors.black:Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20
            ),
        ),
        iconTheme: IconThemeData(
            color: Theme.of(context).brightness!=Brightness.dark?Colors.black:Colors.white
        ),
        backgroundColor:Colors.transparent,
        elevation: 0,

      ),
      body: RefreshIndicator(
        key: refreshKey,
             onRefresh:()async{
               await Future.delayed(Duration(seconds: 2));
               wallPaper=await WallPaper.getInstanceFromCategory(wallPaper.categoryName);
               setState(() {

               });
             },
             child: !found?WallPaper.error.isNotEmpty
            ?Center(child: Text(WallPaper.error),)
            :Center(child: Text('We Couldn\'t Find Anything For " ${wallPaper.categoryName} "  ',style: TextStyle(fontSize: 16),),)
            :Container(
          child: WallPaper.error.isNotEmpty?
          Center(child:RaisedButton(
            onPressed: (){
              refreshKey.currentState.show();
            },
            child: Text(WallPaper.error),
          )):
          GridView.count(
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            crossAxisCount: 3,
            childAspectRatio: 0.7,
            children: List.generate(totalPhotos+1, (index){
              return index<totalPhotos?
             GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, FullImage.routeName,arguments: {
                    "wallpaper":wallPaper,
                    "index":index
                  });
                },
                child: Hero(
                  tag: wallPaper.photos[index].src,
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      color:  Theme.of(context).brightness==Brightness.dark?HomePage.darkColor:HomePage.lightColor,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        wallPaper.photos[index].src.medium,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                          return Center(child:Icon(Icons.error,));
                        },
                      ),
                    ),
                  ),
                ),
              ):nextButton();
            })
          ),
        ),
      ),
    );
  }
}
