import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/navigation_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(
    this.scaffold,
    this.navigationDrawer, {
    super.key,
  });

  final GlobalKey<ScaffoldState> scaffold;
  final GlobalKey<MainAppDrawerState> navigationDrawer;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late List<String>? profileDetails = null;
  late bool isLoad = false;

  void _loadProfile() {
    SharedPreferences.getInstance().then((value) {
      profileDetails = value.getStringList("loggedProfile");
      isLoad = true;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          onPressed: () {
            widget.scaffold.currentState!.openDrawer();
          },
          icon: const Icon(Symbols.menu),
        ),
      ),
      // CONTENT HERE:
      body: isLoad
          ? profileDetails != null
              ? Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // SizedBox(
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const ShapeDecoration(
                              color: Colors.cyan,
                              shape: CircleBorder(),
                            ),
                          ),
                          // ),
                          SizedBox(height: 8),
                          Column(
                            children: [
                              Text(
                                profileDetails!.elementAt(0),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(profileDetails!.elementAt(1)),
                              Text(
                                profileDetails!.elementAt(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Alamat",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(profileDetails!.elementAt(3)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Nomor Telepon",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(profileDetails!.elementAt(4)),
                        ],
                      ),
                    ),
                  ],
                )
              : const Center(child: Text("Something went wrong."))
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
