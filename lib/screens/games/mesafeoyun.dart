import 'package:GeoGame/screens/geogamelobi.dart';
import 'package:flutter/material.dart';
import 'package:GeoGame/ulke.dart';
import 'package:searchfield/searchfield.dart';
import 'dart:math';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MesafeOyun extends StatefulWidget {
  @override
  _MesafeOyunState createState() => _MesafeOyunState();
}

class _MesafeOyunState extends State<MesafeOyun> {
  final List<Color> buttonColors = [Colors.green, Colors.yellow, Colors.blue, Colors.red];
  String message='';
  late TextEditingController _controller;
  String _currentInput = '';
  int puan=100;
  @override
  void initState() {
    super.initState();
    _initializeGame();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {
        _currentInput = _controller.text.trim();
      });
    });
  }
  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
    await yeniulkesec();
    await mesafeoyunkurallari();
  }
  Future<void> mesafeoyunkurallari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // kullanıcı mutlaka düğmeye basmalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('mesafekural')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Yazi.get('mesafekural1')),
                Text(Yazi.get('mesafekural2')),
                Text(Yazi.get('mesafekural3')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Yazi.get('bayrakkural4')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _checkAnswer() {
    setState(() {
      for (int a=0;a<250;a++){
        if(ulke[a].ks(kelimeDuzelt(_controller.text.trim()))){
          gecici= ulke[a];
          break;
        }
      }
      message += Yazi.get('mesafetahmin') + gecici.isim + "    ";
      message += Yazi.get('mesafetahmin1') + mesafeHesapla(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam).toString() + " Km   ";
      message += Yazi.get('mesafetahmin2') + pusula(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam) + "\n";
      if (kalici.ks(kelimeDuzelt(_controller.text.trim()))) {
        _controller.clear();
        _currentInput='';
        message='';
        yeniulkesec();
        Dogru();
        mesafedogru++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Yazi.get('dogrucevap')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          mesafepuan+=puan;
          writeToFile();
        });
        puan=50;
      } else {
        puan-=10;
        if(puan<20)
          puan=20;
        Yanlis();
        mesafeyanlis++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Yazi.get('yanliscevap')+puan.toString()),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
  void _pasButtonPressed() {
    puan=100;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Yazi.get('gecilenulke')+kalici.isim),
        backgroundColor: Colors.yellow,
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {
      yeniulkesec();
      Yenitur();
      _controller.clear();
    });
  }
  double mesafeHesapla(double latitude1, double longitude1, double latitude2, double longitude2) {
    const double PI = 3.14159265358979323846264338327950288;
    double theta = longitude1 - longitude2;
    double distance = acos(sin(latitude1 * PI / 180.0) * sin(latitude2 * PI / 180.0) +
        cos(latitude1 * PI / 180.0) * cos(latitude2 * PI / 180.0) * cos(theta * PI / 180.0)) * 180.0 / PI;
    distance *= 60 * 1.1515 * 1.609344; // Miles to kilometers conversion
    return distance.roundToDouble();
  }
  String pusula(double lat1, double lon1, double lat2, double lon2) {
    const double PI = 3.14159265358979323846264338327950288;
    lat1 *= PI / 180.0;
    lon1 *= PI / 180.0;
    lat2 *= PI / 180.0;
    lon2 *= PI / 180.0;
    double brng = atan2(sin(lon2 - lon1) * cos(lat2), cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1)) * 180 / PI;
    brng = (brng + 360) % 360;

    const List<String> yonlerTR = ["Kuzey", "Kuzeydoğu", "Doğu", "Güneydoğu", "Güney", "Güneybatı", "Batı", "Kuzeybatı"];
    const List<String> yonlerEN = ["North", "Northeast", "East", "Southeast", "South", "Southwest", "West", "Northwest"];
    List<String> yonler = isEnglish ? yonlerEN : yonlerTR;
    return yonler[((brng + 22.5) / 45.0).floor() % 8];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('baskent')),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GeoGameLobi()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(),
              child: Text(
                'GeoGame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text(
                Yazi.get('sikayet'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              dense: true,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.share, color: Color(0xFF5865F2)),
              title: Text(Yazi.get('uygpaylas')),
              onTap: () async {
                await Share.share(Yazi.get('davetpromt'));
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.instagram),
              title: Text(Yazi.get('instagram')),
              onTap: () async {
                await EasyLauncher.url(
                    url: Yazi.get('instagramurl'), mode: Mode.platformDefault);
              },
            ),
            ListTile(
              leading: Icon(Icons.public, color: Colors.red),
              title: Text(Yazi.get('website')),
              onTap: () async {
                await EasyLauncher.url(url: Yazi.get('websiteurl'));
              },
            ),
            ListTile(
              leading: FaIcon(Icons.report),
              title: Text(Yazi.get('hatabildir')),
              onTap: () async {
                await EasyLauncher.url(url: Yazi.get('hatabildirurl'));
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.github),
              title: Text(Yazi.get('github')),
              onTap: () async {
                await EasyLauncher.url(url: Yazi.get('githuburl'));
              },
            ),
            ListTile(
              leading: Icon(Icons.discord, color: Color(0xFF5865F2)),
              title: Text(Yazi.get('discord')),
              onTap: () async {
                await EasyLauncher.url(url: Yazi.get('discordurl'));
              },
            ),
            ListTile(
              leading: Icon(Icons.music_note, color: Colors.red),
              title: Text(Yazi.get('sarki')),
              onTap: () async {
                await EasyLauncher.url(url: Yazi.get('sarkiurl'));
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                Yazi.get('yapimci'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              dense: true,
            ),
            SizedBox(height: 20), // Boşluk bırakır
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                message,
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Butonlar arasında eşit boşluk bırakır
                children: [
                  ElevatedButton(
                    onPressed: _checkAnswer,
                    child: Text(Yazi.get('tahmin1')),
                  ),
                  ElevatedButton(
                    onPressed: _pasButtonPressed,
                    child: Text(Yazi.get('pas')),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        message = '';
                      });
                    },
                    child: Text(Yazi.get('tahmin2')),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                        SearchField<Ulkeler>(
                          suggestions: ulke
                              .where((e) => (isEnglish ? e.enisim : e.isim).toLowerCase().contains(_currentInput.toLowerCase()))
                              .map(
                                (e) => SearchFieldListItem<Ulkeler>(
                                  (isEnglish ? e.enisim : e.isim),
                              item: e,

                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(e.url),
                                      radius: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        (isEnglish ? e.enisim : e.isim),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              .toList(),
                          controller: _controller,
                          onSuggestionTap: (value) {
                            setState(() {
                              _controller.text = value.searchKey;
                              _currentInput = value.searchKey;
                              _checkAnswer();
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}