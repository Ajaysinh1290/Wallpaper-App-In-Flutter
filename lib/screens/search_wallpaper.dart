import 'package:flutter/material.dart';
import 'package:wallpaper_app/database_helper.dart';
import 'package:wallpaper_app/models/wallpaper.dart';
import 'package:wallpaper_app/screens/more_wallpaper.dart';

class SearchWallpaper extends SearchDelegate {
  WallPaper wallPaper;
  List<Map<String, dynamic>> historyList;

  static toMap(id, history) {
    return {DatabaseHelper.columnId: id, DatabaseHelper.columnName: history};
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
      IconButton(
        onPressed: () async {
          searchQuery(context, query);
        },
        icon: Icon(
          Icons.search,
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {

    searchQuery(context, query);
    return Container();
  }

  searchQuery(BuildContext context, String searchQuery) async {
    if (searchQuery.isEmpty) {
      return;
    }
    wallPaper = await WallPaper.getInstanceFromCategory(searchQuery);

    query = '';
    Navigator.pushNamed(context, MoreWallpaper.routeName,
        arguments: {"wallpaper": wallPaper});

    historyList.forEach((element) async {
      if (element[DatabaseHelper.columnName] == searchQuery) {
        int deleted = await DatabaseHelper.instance
            .delete(element[DatabaseHelper.columnId]);
      }
    });
    await DatabaseHelper.instance
        .insert({DatabaseHelper.columnName: searchQuery});
    initiateHistoryList();
  }

  initiateHistoryList() async {
    historyList = await DatabaseHelper.instance.getAllHistory();
  }

  deleteHistoryAt(var history) async {
    await DatabaseHelper.instance.delete(history[DatabaseHelper.columnId]);
    historyList = null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions

    if (historyList == null) {
      initiateHistoryList();
      return Container();
    }
    List<dynamic> filteredList = query.isEmpty
        ? historyList.reversed.toList()
        : historyList
            .where((element) =>
                element[DatabaseHelper.columnName].startsWith(query))
            .toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return Dismissible(
          onDismissed: (direction) {
            deleteHistoryAt(filteredList[index]);
          },
          key: Key(index.toString()),
          child: ListTile(
            onTap: () {
              print('in list tile');
              searchQuery(
                  context, filteredList[index][DatabaseHelper.columnName]);
            },
            leading: Icon(Icons.history),
            title: Text(
              filteredList[index][DatabaseHelper.columnName],
            ),
          ),
        );
      },
    );
  }
}
