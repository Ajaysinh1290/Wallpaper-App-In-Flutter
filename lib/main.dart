
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallpaper_app/screens/full_image.dart';
import 'package:wallpaper_app/screens/more_wallpaper.dart';
import 'screens/home_page.dart';
void main() {
  runApp(WallpaperApp());
}

class WallpaperApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: Brightness.light,

        data: (brightness) => ThemeData(
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: theme,
            initialRoute: HomePage.routeName,
            routes: {
              HomePage.routeName:(context)=>HomePage(),
              MoreWallpaper.routeName:(context)=>MoreWallpaper(),
              FullImage.routeName:(context)=>FullImage(),
            },

          );
        });
  }
}

