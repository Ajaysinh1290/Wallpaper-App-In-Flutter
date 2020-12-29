import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/models/wallpaper.dart';
import 'package:wallpaper_app/screens/full_image.dart';
import 'package:wallpaper_app/screens/more_wallpaper.dart';
import 'package:wallpaper_app/screens/search_wallpaper.dart';

class HomePage extends StatefulWidget {

  static final Color lightColor=Colors.grey[200];

  static final Color darkColor=Colors.grey[800];
  static final routeName='/home';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



  List category;
  String url='https://api.pexels.com/v1/search?query=programming';
  Map wallpaper;
  GlobalKey<RefreshIndicatorState> refreshKey;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshKey=GlobalKey();
   initWallpaper();
  }
  Future initWallpaper() async{
    print('category init start');
   category=[
      await WallPaper.getInstanceFromCategory("Beach"),
     await WallPaper.getInstanceFromCategory("Blurred Background"),
     await WallPaper.getInstanceFromCategory("Summer"),
     await WallPaper.getInstanceFromCategory("Nature"),
     await WallPaper.getInstanceFromCategory("Travelling"),
     await  WallPaper.getInstanceFromCategory("Light Background"),
     await WallPaper.getInstanceFromCategory("Cars"),
     await WallPaper.getInstanceFromCategory("Dark Wallpaper")
   ];
   setState(() {
     print('category init end');

   });
  }
  getPhotosList(int index) {
    int rows=index%2==0?1:2;
    return category==null?Center(child: CircularProgressIndicator()):Container(
      height:(rows*220.0),
      child: GridView.count(
        mainAxisSpacing: 0,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(4),
        crossAxisSpacing: 5,
        crossAxisCount:rows,
        childAspectRatio: 1/0.7,

        children: List.generate(20, (photoIndex) {
          return Hero(
            tag: category[index].photos[photoIndex].src,
            child: GestureDetector(
              onTap: (){
                WallPaper.error='';
                Navigator.pushNamed(context, FullImage.routeName,arguments: {
                  "wallpaper":category[index],
                  "index":photoIndex
                });
              },
              child: Container(
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color:  Theme.of(context).brightness==Brightness.dark?HomePage.darkColor:HomePage.lightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    category[index].photos[photoIndex].src.medium,
                     fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                        return Center(
                            child:
                            Icon(
                                Icons.error,
                                color:  Theme.of(context).brightness!=Brightness.dark?HomePage.darkColor:HomePage.lightColor
                            )
                        );
                      },
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );

  }
  getList(int index) {
    print(category[index]);
    return category[index]==null?Center(child:CircularProgressIndicator()):Container(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  category[index].categoryName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: (){
                  WallPaper.error='';
                  Navigator.pushNamed(context, MoreWallpaper.routeName,
                      arguments: {"wallpaper": category[index]});

                },
                child: Text(
                    'More',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,

                  ),
                ),

              )
            ],
          ),
          getPhotosList(index),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        toolbarHeight:70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 10,
        centerTitle: true,
        title:  GestureDetector(
          onTap: () async{
           await showSearch(
              delegate: SearchWallpaper(),
              context: context,
            );
          },
          child: Container(
            width: double.infinity,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color:  Theme.of(context).brightness==Brightness.dark?HomePage.darkColor:HomePage.lightColor,
                borderRadius: BorderRadius.circular(8.0)
              ),
              child: Row(
                children: [
                  SizedBox(width: 5,),
                  Icon(
                    Icons.search,
                    color: Colors.grey,

                  ),
                  SizedBox(width: 10,),
                  Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18
                    ),
                  ),
                ],
              ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
              DynamicTheme.of(context).setBrightness(Theme.of(context).brightness==Brightness.dark?Brightness.light:Brightness.dark);
            },
            icon: Icon(
              Icons.brightness_6,
              color: Colors.grey[500],

            ),
          )
        ],
      ),
      body: RefreshIndicator(
            key: refreshKey,
            onRefresh:() async {
               await Future.delayed(Duration(seconds: 5));
               await initWallpaper();
               },
            child: WallPaper.error.isNotEmpty
            ?Center(
              child: RaisedButton(
              onPressed: (){
                refreshKey.currentState.show();
              },
              child: Text(WallPaper.error),
            ),)
            :SafeArea(

              child: category==null?Center(child:CircularProgressIndicator()):Container(
              padding: EdgeInsets.only(left: 0,top: 10),
              child: ListView.builder(
              itemCount: category.length,
              itemBuilder: (context,index){
                return getList(index);
              },
            ),

            ),
            ),
          ),
    );

  }
}
