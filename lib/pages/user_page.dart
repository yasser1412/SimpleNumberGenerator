import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:permission/permission.dart';
import 'dart:async';

import '/pages/main_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:gptask/models/users.dart';

class UserPage extends StatefulWidget {
  final User logedUser;
  const UserPage({Key? key, required this.logedUser}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState(logedUser);
}

class _UserPageState extends State<UserPage> {
  User logedUser;
  _UserPageState(this.logedUser);

  /// Images
  String mainProfilePic = "assets\images\account.jpg";
  String otherProfilePic = "assets\images\alt.jpg";
  String backgroundImage = "assets\images\background.jpg";

  final myController = TextEditingController();
  static const int listSize = 10000;
  static const int maxInt = 99999;
  var isDialOpen = ValueNotifier<bool>(false);

  List rndList = [listSize];

  void generateRndNum() {
    var rng = new Random();
    rndList = new List.generate(listSize, (_) => rng.nextInt(maxInt));
    print("new list generated");
    print("${rndList[0]} , ${rndList[1]}");
  }

  void searchNumber() {
    final int num = int.parse(myController.text);
    if (rndList.contains(num))
      showSearchResult("Found it!", myController.text);
    else
      showSearchResult("Not found!", myController.text);
  }

  void showSearchResult(String text, String title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              new TextButton(
                child: new Text("ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void switchUser() {
    // Switches user's icon.
    String backupString = mainProfilePic;
    this.setState(() {
      mainProfilePic = otherProfilePic;
      otherProfilePic = backupString;
    });
  }

  Future<void> getPermissions() async {
    final permissions =
        await Permission.getPermissionsStatus([PermissionName.Storage]);
    var request = true;
    switch (permissions[0].permissionStatus) {
      case PermissionStatus.allow:
        request = false;
        print("Permission granted once!");
        break;
      case PermissionStatus.always:
        print("Permission granted always!");
        request = false;
        break;
      default:
    }
    if (request) {
      await Permission.requestPermissions([PermissionName.Storage]);
    }
  }

  Future<File> get _externalFilePath async {
    final directory = await getExternalStorageDirectory();
    final dirPath = (directory)!.path;
    print("dir path: $dirPath");

    return File('$dirPath/ListOfRandomNumbers.txt');
  }

  Future<File> saveTxtFile() async {
    try {
      final file = await _externalFilePath;
      showSearchResult("Text file saved in ${file.path}", "File Saved");
      return file.writeAsString('$rndList');
    } catch (e) {
      // If encountering an error, return 0
      print("Error, couldn't create the txt file!");
      return File("error.txt");
    }
  }

  Future<void> init() async {
    await getPermissions();
    generateRndNum();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: new Center(
            child: Column(
          children: <Widget>[
            SizedBox(
              height: 200,
            ),
            Container(
              height: 200,
              width: 200,
              child: Image.asset("assets/userbest.jpg"),
              alignment: Alignment.center,
            ),
            Text(
              "Welcome, ${logedUser.username}!",
              style: TextStyle(fontSize: 50),
              textAlign: TextAlign.center,
            ),
            Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 20.0,
                ),
                // Logout Button
                child: FloatingActionButton.extended(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xff0095FF),
                  icon: Icon(Icons.logout_outlined),
                  label: Text('Logout'),
                  heroTag: "LogoutBtn",
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MainPage()));
                  },
                )),
          ],
        )),
        appBar: new AppBar(
          title: new Text("HomePage"),
          centerTitle: true,
          backgroundColor: Color(0xff0095FF),
        ),
        drawer: new Drawer(
          child: new ListView(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                // Add account info:
                accountName: new Text(logedUser.username),
                accountEmail: new Text(logedUser.email),
                currentAccountPicture: new GestureDetector(
                  onTap: () => print("This is the current user"),
                  child: new CircleAvatar(
                    backgroundImage: new AssetImage('assets/userbest.jpg'),
                  ),
                ),

                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new AssetImage('assets/background.jpg'),
                  ),
                ),
              ),
              new ListTile(
                  title: new Text("Numbers Page"),
                  trailing: new Icon(Icons.arrow_right),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        new MaterialPageRoute(builder: (BuildContext context) {
                      ValueNotifier<bool> isDialOpen = ValueNotifier(false);
                      return Scaffold(
                        appBar: AppBar(
                          backgroundColor: Color(0xff0095FF),
                          title: Text("Generated Numbers"),
                          centerTitle: true,
                        ),
                        body: Center(
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(12),
                                width: 700,
                                child: TextField(
                                  style: TextStyle(fontSize: 25),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Search Number",
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.search),
                                      onPressed: (searchNumber),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: myController,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                              Expanded(
                                child: GridView.count(
                                  crossAxisCount: 4,
                                  children:
                                      List.generate(rndList.length, (index) {
                                    return Center(
                                      child: Text(
                                        '${rndList[index]}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              SpeedDial(
                                spacing: 3,
                                openCloseDial: isDialOpen,
                                animatedIcon: AnimatedIcons.menu_close,
                                animatedIconTheme: IconThemeData(size: 22),
                                backgroundColor: Color(0xff0095FF),
                                visible: true,
                                curve: Curves.bounceIn,
                                children: [
                                  // Export List Button
                                  SpeedDialChild(
                                      child: Icon(Icons.drive_file_move_sharp),
                                      backgroundColor: Color(0xff0095FF),
                                      onTap: () {
                                        saveTxtFile();
                                      },
                                      label: 'Export List',
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 16.0),
                                      labelBackgroundColor: Color(0xFF801E48)),
                                  // New List Button
                                  SpeedDialChild(
                                      child: Icon(Icons.assignment_turned_in),
                                      backgroundColor: Color(0xff0095FF),
                                      onTap: () {
                                        generateRndNum();
                                        showSearchResult(
                                            "New list generated! Please, refresh the page to update the list.",
                                            "List Updated");
                                        print(
                                            "New list generated successfully!");
                                      },
                                      label: 'New List',
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 16.0),
                                      labelBackgroundColor: Color(0xFF801E48))
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }));
                  }),
              new Divider(),
              new ListTile(
                title: new Text("Close"),
                trailing: new Icon(Icons.cancel),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
