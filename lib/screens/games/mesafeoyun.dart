import 'package:GeoGame/util.dart';

class MesafeOyun extends StatefulWidget {
  @override
  _MesafeOyunState createState() => _MesafeOyunState();
}

class _MesafeOyunState extends State<MesafeOyun> {
  String message='',_currentInput = '';
  late TextEditingController _controller;
  int puan=100;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }
  Future<void> _initializeGame() async {
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {
        _currentInput = _controller.text.trim();
      });
    });
    await readFromFile((update) => setState(update));
    yeniulkesec();
    await mesafeoyunkurallari();
  }
  Future<void> mesafeoyunkurallari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // kullanıcı mutlaka düğmeye basmalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('kurallar')),
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
              child: Text(Yazi.get('tamam')),
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
      message += Yazi.get('tahminmetin') + gecici.isim + "    ";
      message += Yazi.get('mesafe') + mesafeHesapla(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam).toString() + " Km   ";
      message += Yazi.get('yon') + pusula(gecici.enlem, gecici.boylam, kalici.enlem, kalici.boylam) + "\n";
      if (kalici.ks(kelimeDuzelt(_controller.text.trim()))) {
        String ulke = kelimeDuzelt(_controller.text.trim());
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
        postUlkeLog(
            '{\n"name": "$name",\n'
                '"oyunmodu": "mesafe",\n'
                '"mesaj": "Cevap Doğru",\n'
                '"dogrucevap": "${kalici.isim}",\n'
                '"verilencevap": "$ulke",\n'
                '"yesil": "${butonAnahtarlar[0]}",\n'
                '"sari": "${butonAnahtarlar[1]}",\n'
                '"mavi": "${butonAnahtarlar[2]}",\n'
                '"kirmizi": "${butonAnahtarlar[3]}"\n}');
        setState(() {
          mesafepuan+=puan;
          writeToFile();
        });
        puan=200;
      } else {
        String ulke = kelimeDuzelt(_controller.text.trim());
        puan-=10;
        if(puan<50)
          puan=50;
        Yanlis();
        _controller.clear();
        _currentInput='';
        mesafeyanlis++;
        writeToFile();
        postUlkeLog(
            '{\n"name": "$name",\n'
                '"oyunmodu": "mesafe",\n'
                '"Mesaj": "Cevap Yanlış",\n'
                '"dogrucevap": "${kalici.isim}",\n'
                '"verilencevap": "$ulke",\n'
                '"yesil": "${butonAnahtarlar[0]}",\n'
                '"sari": "${butonAnahtarlar[1]}",\n'
                '"mavi": "${butonAnahtarlar[2]}",\n'
                '"kirmizi": "${butonAnahtarlar[3]}"\n}');
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
    String ulke = kelimeDuzelt(_controller.text.trim());
    postUlkeLog(
        '{\n"name": "$name",\n'
            '"oyunmodu": "mesafe",\n'
            '"Mesaj": "Pas Geçildi",\n'
            '"dogrucevap": "${kalici.isim}",\n'
            '"verilencevap": "$ulke",\n'
            '"yesil": "${butonAnahtarlar[0]}",\n'
            '"sari": "${butonAnahtarlar[1]}",\n'
            '"mavi": "${butonAnahtarlar[2]}",\n'
            '"kirmizi": "${butonAnahtarlar[3]}"\n}');
    setState(() {
      _currentInput='';
      message='';
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
        title: Text(Yazi.get('mesafebaslik')),
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
      drawer: DrawerWidget(),
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: _pasButtonPressed,
                        child: Text(
                          Yazi.get('pas'),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            message = '';
                          });
                        },
                        child: Text(
                          Yazi.get('tahmintemizle'),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
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
