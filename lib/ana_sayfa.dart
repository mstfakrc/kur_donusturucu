import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnaSayfa extends StatefulWidget {
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final String _apiKey = "31700c5fad45c6653e87460deb461111"; // API anahtarı
  final String _baseUrl =
      "http://api.exchangeratesapi.io/v1/latest?access_key="; // API URL'si

  TextEditingController _controller =
      TextEditingController(); // Kullanıcı girişini almak için
  TextEditingController _aramaController =
      TextEditingController(); // Arama işlemi için
  Map<String, double> _oranlar =
      {}; // Para birimlerinin oranlarını saklamak için
  Map<String, String> _ulkeAdlari = {
    // Para birimlerine ait ülke isimleri
    "AUD": "Avustralya Doları",
    "CAD": "Kanada Doları",
    "CHF": "İsviçre Frangı",
    "CNY": "Çin Yuanı",
    "GBP": "İngiliz Sterlini",
    "JPY": "Japon Yeni",
    "USD": "Amerikan Doları",
    "TRY": "Türk Lirası",
    "EUR": "Euro",
    "BRL": "Brezilya Reali",
    "INR": "Hindistan Rupisi",
    "MXN": "Meksika Pesosu",
    "NZD": "Yeni Zelanda Doları",
    "NOK": "Norveç Kronu",
    "SEK": "İsveç Kronu",
    "DKK": "Danimarka Kronu",
    "ZAR": "Güney Afrika Randı",
    "SGD": "Singapur Doları",
    "KRW": "Güney Kore Wonu",
    "HKD": "Hong Kong Doları",
    "PLN": "Polonya Zlotisi",
    "RUB": "Rus Rublesi",
    "AED": "Birleşik Arap Emirlikleri Dirhemi",
    "ARS": "Arjantin Pesosu",
    "EGP": "Mısır Lirası",
    "IDR": "Endonezya Rupiahı",
    "ILS": "İsrail Şekeli",
    "MYR": "Malezya Ringgiti",
    "PHP": "Filipin Pesosu",
    "SAR": "Suudi Arabistan Riyali",
    "THB": "Tayland Bahtı",
    "UAH": "Ukrayna Grivnası",
    "CLP": "Şili Pesosu",
    "COP": "Kolombiya Pesosu",
    "CZK": "Çek Korunası",
    "HUF": "Macar Forinti",
    "ISK": "İzlanda Kronu",
    "KWD": "Kuveyt Dinarı",
    "MAD": "Fas Dirhemi",
    "OMR": "Umman Riyali",
    "QAR": "Katar Riyali",
    "RON": "Romanya Leyi",
    "BGN": "Bulgar Levası",
    "HRK": "Hırvat Kunası",
    "BHD": "Bahreyn Dinarı",
    "JOD": "Ürdün Dinarı",
    "LKR": "Sri Lanka Rupisi",
    "PKR": "Pakistan Rupisi",
    "TWD": "Tayvan Doları",
    "VND": "Vietnam Dongu",
    "BDT": "Bangladeş Takası",
    "NGN": "Nijerya Nairası",
    "KES": "Kenya Şilini",
    "TZS": "Tanzanya Şilini",
    "GHS": "Gana Cedi",
    "UGX": "Uganda Şilini",
    "ZMW": "Zambiya Kvaçası",
    "MUR": "Mauritius Rupisi",
    "MGA": "Madagaskar Ariarisi",
    "XOF": "Batı Afrika CFA Frangı",
    "XAF": "Orta Afrika CFA Frangı",
    "XCD": "Doğu Karayip Doları",
    "JMD": "Jamaika Doları",
    "SLL": "Sierra Leone Leonesi",
    "SCR": "Seyşeller Rupisi",
    "MVR": "Maldiv Rufiyası",
    "KZT": "Kazak Tengesi",
    "MNT": "Moğol Tugriki",
    "LAK": "Laos Kipi",
    "MMK": "Myanmar Kyatı",
    "KHR": "Kamboçya Rieli",
    "BND": "Brunei Doları",
    "FJD": "Fiji Doları",
    "PGK": "Papua Yeni Gine Kinası",
    "WST": "Samoa Talası",
    "TOP": "Tonga Paʻangası",
    "TMT": "Türkmenistan Manatı",
    "GEL": "Gürcistan Larisi",
    "MDL": "Moldova Leyi",
    "AZN": "Azerbaycan Manatı",
    "BAM": "Bosna-Hersek Markı",
    "MKD": "Makedonya Dinarı",
    "RSD": "Sırp Dinarı",
    "ALL": "Arnavutluk Leki",
    "BYN": "Beyaz Rusya Rublesi",
    "KGS": "Kırgızistan Somu",
    "UZS": "Özbekistan Somu",
    "TJS": "Tacikistan Somonisi",
    "AFN": "Afganistan Afganisi",
    "LRD": "Liberya Doları",
    "GNF": "Gine Frangı",
    "MWK": "Malavi Kvaçası",
    "NAD": "Namibya Doları",
    "ETB": "Etiyopya Birri",
    "DJF": "Cibuti Frangı",
    "BIF": "Burundi Frangı",
    "CDF": "Kongo Frangı",
    "SDG": "Sudan Lirası"
    // Diğer para birimleri eklenebilir
  };

  String _secilenKur = "USD"; // Varsayılan seçilen para birimi
  double _sonuc = 0; // Hesaplanan sonucu saklamak için
  List<String> _filtrelenenKurlar = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verileriInternettenCek(); // Verileri API'den çek
    });

    // Başlangıçta tüm para birimlerini listeye ekle
    _aramaController.addListener(() {
      _aramaYap(_aramaController.text);
    });
  }

  void _aramaYap(String aramaTerimi) {
    setState(() {
      if (aramaTerimi.isEmpty) {
        _filtrelenenKurlar = _oranlar.keys.toList();
      } else {
        _filtrelenenKurlar = _oranlar.keys
            .where((kur) =>
                kur.toLowerCase().contains(aramaTerimi.toLowerCase()) ||
                (_ulkeAdlari[kur]?.toLowerCase() ?? '')
                    .contains(aramaTerimi.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: _buildAppBar(), // AppBar oluştur
  body: _oranlar.isNotEmpty
      ? _buildBody() // Eğer oranlar varsa gövdeyi oluştur
      : Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent), // İlerleme çubuğu rengi
          ),
        ), // Veriler yükleniyorsa göster
  backgroundColor: Colors.lightBlue[50], // Arka plan rengi
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      // Burada yapılacak işlemleri tanımlayın
    },
    child: Icon(Icons.refresh), // Yenileme ikonu
    backgroundColor: Colors.blueAccent, // Buton rengi
  ),
  drawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
          ),
          child: Text(
            'Kur Dönüştürücü',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text('Hakkında'),
          onTap: () {
            // Hakkında bilgileri göster
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Ayarlar'),
          onTap: () {
            // Ayarlar sayfasına git
          },
        ),
      ],
    ),
  ),
);

  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Kur Dönüştürücü",
        style: TextStyle(
          color: Colors.white,
          fontSize: 24, // Başlık boyutu
          fontWeight: FontWeight.bold, // Başlık kalınlığı
        ),
      ),
      backgroundColor: Colors.blueAccent,
      centerTitle: true, // Başlığı ortalar
      elevation: 5, // Gölge efekti
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20), // Alt köşeleri yuvarla
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white), // Ayarlar ikonu
          onPressed: () {
            // Ayarlar butonuna tıklandığında yapılacaklar
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildKurDonusturuRow(), // Para birimi dönüştürme satırı
          SizedBox(height: 16),
          _buildSonucText(), // Sonucu gösteren metin
          SizedBox(height: 16),
          _buildAyiriciCizgi(), // Ayırıcı çizgi
          SizedBox(height: 16),
          _buildAramaCubugu(), // Arama çubuğu
          SizedBox(height: 16),
          _buildKurList(), // Para birimleri listesini göster
        ],
      ),
    );
  }

  Widget _buildAramaCubugu() {
    return TextField(
  controller: _aramaController,
  decoration: InputDecoration(
    labelText: "Para Birimi veya Ülke Ara",
    labelStyle: TextStyle(
      color: Colors.blueAccent, // Etiket rengi
    ),
    prefixIcon: Icon(
      Icons.search,
      color: Colors.blueAccent, // İkon rengi
    ),
    filled: true, // Arka plan rengini doldur
    fillColor: Colors.white, // Arka plan rengi
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.blueAccent, // Kenar rengi
        width: 1.5, // Kenar kalınlığı
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.blueAccent, // Fokusa girdiğinde kenar rengi
        width: 2, // Fokusta kenar kalınlığı
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.grey, // Varsayılan kenar rengi
        width: 1, // Varsayılan kenar kalınlığı
      ),
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10), // İç boşluk
  ),
);

  }

  Widget _buildKurDonusturuRow() {
    return Row(
      children: [
        _buildKurTextField(), // Miktar giriş alanı
        SizedBox(width: 16),
        _buildKurDropdown(), // Para birimi seçimi
      ],
    );
  }

  Widget _buildKurTextField() {
    return Expanded(
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          filled: true,
          fillColor: Colors.white,
          labelText: "Miktar",
          labelStyle: TextStyle(color: Colors.blueAccent),
        ),
        onChanged: (String yeniDeger) {
          _hesapla(); // Kullanıcı yeni bir değer girdiğinde hesapla
        },
      ),
    );
  }

  Widget _buildKurDropdown() {
    return DropdownButton<String>(
      value: _secilenKur,
      icon: Icon(Icons.arrow_downward, color: Colors.blueAccent),
      underline: SizedBox(),
      items: _oranlar.keys.map((String kur) {
        return DropdownMenuItem<String>(
          value: kur,
          child: Text(
              "$kur - ${_ulkeAdlari[kur] ?? 'Bilinmeyen Ülke'}"), // Para birimi ve ülke adı
        );
      }).toList(),
      onChanged: (String? yeniDeger) {
        if (yeniDeger != null) {
          _secilenKur = yeniDeger; // Seçilen para birimini güncelle
          _hesapla(); // Hesaplama yap
        }
      },
    );
  }

  Widget _buildSonucText() {
    return Text(
      "${_sonuc.toStringAsFixed(4)} ₺", // Hesaplanan sonucu göster
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent, // Sonuç rengi
      ),
    );
  }

  Widget _buildAyiriciCizgi() {
    return Container(
      height: 2,
      color: Colors.grey,
      margin: EdgeInsets.symmetric(vertical: 8),
    );
  }

  Widget _buildKurList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _filtrelenenKurlar.length,
        itemBuilder: _buildListItem, // Liste öğelerini oluştur
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    String kur = _filtrelenenKurlar[index]; // Seçilen para birimi
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      elevation: 4,
      child: ListTile(
        title: Text(
          "$kur - ${_ulkeAdlari[kur] ?? ''}", // Para birimi ve ülke adı
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text("${_oranlar[kur]?.toStringAsFixed(4)} ₺"),
      ),
    );
  }

  void _hesapla() {
    double? deger =
        double.tryParse(_controller.text); // Kullanıcının girdiği değer
    double? oran = _oranlar[_secilenKur]; // Seçilen para biriminin oranı

    if (deger != null && oran != null) {
      setState(() {
        _sonuc = deger * oran; // Sonucu hesapla
      });
    }
  }

  void _verileriInternettenCek() async {
    try {
      Uri uri = Uri.parse(_baseUrl + _apiKey);
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        Map<String, dynamic>? parsedResponse = jsonDecode(response.body);

        if (parsedResponse != null && parsedResponse.containsKey('rates')) {
          Map<String, dynamic> rates = parsedResponse["rates"];
          double? baseTlKuru = rates["TRY"];

          if (baseTlKuru != null) {
            for (String ulkeKuru in rates.keys) {
              double? baseKur = double.tryParse(rates[ulkeKuru].toString());
              if (baseKur != null) {
                double tlKuru = baseTlKuru / baseKur;
                _oranlar[ulkeKuru] = tlKuru; // Oranları kaydet
              }
            }
            _filtrelenenKurlar = _oranlar.keys.toList();
            setState(() {}); // Ekranı güncelle
          }
        }
      }
    } catch (e) {
      print("Hata: $e"); // Hata oluşursa ekrana yazdır
    }
  }
}

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnaSayfa extends StatefulWidget {
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final String _apiKey = "31700c5fad45c6653e87460deb461111"; // API anahtarı
  final String _baseUrl =
      "http://api.exchangeratesapi.io/v1/latest?access_key="; // API URL'si

  TextEditingController _controller =
      TextEditingController(); // Kullanıcı girişini almak için
  Map<String, double> _oranlar =
      {}; // Para birimlerinin oranlarını saklamak için
  Map<String, String> _ulkeAdlari = {
    // Para birimlerine ait ülke isimleri
    "AUD": "Avustralya Doları",
    "CAD": "Kanada Doları",
    "CHF": "İsviçre Frangı",
    "CNY": "Çin Yuanı",
    "GBP": "İngiliz Sterlini",
    "JPY": "Japon Yeni",
    "USD": "Amerikan Doları",
    "TRY": "Türk Lirası",
    "EUR": "Euro",
    "BRL": "Brezilya Reali",
    "INR": "Hindistan Rupisi",
    "MXN": "Meksika Pesosu",
    "NZD": "Yeni Zelanda Doları",
    "NOK": "Norveç Kronu",
    "SEK": "İsveç Kronu",
    "DKK": "Danimarka Kronu",
    "ZAR": "Güney Afrika Randı",
    "SGD": "Singapur Doları",
    "KRW": "Güney Kore Wonu",
    "HKD": "Hong Kong Doları",
    "PLN": "Polonya Zlotisi",
    "RUB": "Rus Rublesi",
    "AED": "Birleşik Arap Emirlikleri Dirhemi",
    "ARS": "Arjantin Pesosu",
    "EGP": "Mısır Lirası",
    "IDR": "Endonezya Rupiahı",
    "ILS": "İsrail Şekeli",
    "MYR": "Malezya Ringgiti",
    "PHP": "Filipin Pesosu",
    "SAR": "Suudi Arabistan Riyali",
    "THB": "Tayland Bahtı",
    "UAH": "Ukrayna Grivnası",
    "CLP": "Şili Pesosu",
    "COP": "Kolombiya Pesosu",
    "CZK": "Çek Korunası",
    "HUF": "Macar Forinti",
    "ISK": "İzlanda Kronu",
    "KWD": "Kuveyt Dinarı",
    "MAD": "Fas Dirhemi",
    "OMR": "Umman Riyali",
    "QAR": "Katar Riyali",
    "RON": "Romanya Leyi",
    "BGN": "Bulgar Levası",
    "HRK": "Hırvat Kunası",
    "BHD": "Bahreyn Dinarı",
    "JOD": "Ürdün Dinarı",
    "LKR": "Sri Lanka Rupisi",
    "PKR": "Pakistan Rupisi",
    "TWD": "Tayvan Doları",
    "VND": "Vietnam Dongu",
    "BDT": "Bangladeş Takası",
    "NGN": "Nijerya Nairası",
    "KES": "Kenya Şilini",
    "TZS": "Tanzanya Şilini",
    "GHS": "Gana Cedi",
    "UGX": "Uganda Şilini",
    "ZMW": "Zambiya Kvaçası",
    "MUR": "Mauritius Rupisi",
    "MGA": "Madagaskar Ariarisi",
    "XOF": "Batı Afrika CFA Frangı",
    "XAF": "Orta Afrika CFA Frangı",
    "XCD": "Doğu Karayip Doları",
    "JMD": "Jamaika Doları",
    "SLL": "Sierra Leone Leonesi",
    "SCR": "Seyşeller Rupisi",
    "MVR": "Maldiv Rufiyası",
    "KZT": "Kazak Tengesi",
    "MNT": "Moğol Tugriki",
    "LAK": "Laos Kipi",
    "MMK": "Myanmar Kyatı",
    "KHR": "Kamboçya Rieli",
    "BND": "Brunei Doları",
    "FJD": "Fiji Doları",
    "PGK": "Papua Yeni Gine Kinası",
    "WST": "Samoa Talası",
    "TOP": "Tonga Paʻangası",
    "TMT": "Türkmenistan Manatı",
    "GEL": "Gürcistan Larisi",
    "MDL": "Moldova Leyi",
    "AZN": "Azerbaycan Manatı",
    "BAM": "Bosna-Hersek Markı",
    "MKD": "Makedonya Dinarı",
    "RSD": "Sırp Dinarı",
    "ALL": "Arnavutluk Leki",
    "BYN": "Beyaz Rusya Rublesi",
    "KGS": "Kırgızistan Somu",
    "UZS": "Özbekistan Somu",
    "TJS": "Tacikistan Somonisi",
    "AFN": "Afganistan Afganisi",
    "LRD": "Liberya Doları",
    "GNF": "Gine Frangı",
    "MWK": "Malavi Kvaçası",
    "NAD": "Namibya Doları",
    "ETB": "Etiyopya Birri",
    "DJF": "Cibuti Frangı",
    "BIF": "Burundi Frangı",
    "CDF": "Kongo Frangı",
    "SDG": "Sudan Lirası"
    // Diğer para birimleri eklenebilir
  };

  String _secilenKur = "USD"; // Varsayılan seçilen para birimi
  double _sonuc = 0; // Hesaplanan sonucu saklamak için

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verileriInternettenCek(); // Verileri API'den çek
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // AppBar oluştur
      body: _oranlar.isNotEmpty
          ? _buildBody() // Eğer oranlar varsa gövdeyi oluştur
          : Center(
              child:
                  CircularProgressIndicator()), // Veriler yükleniyorsa göster
      backgroundColor: Colors.lightBlue[50], // Arka plan rengi
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Kur Dönüştürücü",
          style: TextStyle(color: Colors.white)), // Başlık
      backgroundColor: Colors.blueAccent, // AppBar rengi
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildKurDonusturuRow(), // Para birimi dönüştürme satırı
          SizedBox(height: 16),
          _buildSonucText(), // Sonucu gösteren metin
          SizedBox(height: 16),
          _buildAyiriciCizgi(), // Ayırıcı çizgi
          SizedBox(height: 16),
          _buildKurList(), // Para birimleri listesini göster
        ],
      ),
    );
  }

  Widget _buildKurDonusturuRow() {
    return Row(
      children: [
        _buildKurTextField(), // Miktar giriş alanı
        SizedBox(width: 16),
        _buildKurDropdown(), // Para birimi seçimi
      ],
    );
  }

  Widget _buildKurTextField() {
    return Expanded(
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          filled: true,
          fillColor: Colors.white,
          labelText: "Miktar",
          labelStyle: TextStyle(color: Colors.blueAccent),
        ),
        onChanged: (String yeniDeger) {
          _hesapla(); // Kullanıcı yeni bir değer girdiğinde hesapla
        },
      ),
    );
  }

  Widget _buildKurDropdown() {
    return DropdownButton<String>(
      value: _secilenKur,
      icon: Icon(Icons.arrow_downward, color: Colors.blueAccent),
      underline: SizedBox(),
      items: _oranlar.keys.map((String kur) {
        return DropdownMenuItem<String>(
          value: kur,
          child: Text(
              "$kur - ${_ulkeAdlari[kur] ?? 'Bilinmeyen Ülke'}"), // Para birimi ve ülke adı
        );
      }).toList(),
      onChanged: (String? yeniDeger) {
        if (yeniDeger != null) {
          _secilenKur = yeniDeger; // Seçilen para birimini güncelle
          _hesapla(); // Hesaplama yap
        }
      },
    );
  }

  Widget _buildSonucText() {
    return Text(
      "${_sonuc.toStringAsFixed(4)} ₺", // Hesaplanan sonucu göster
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent, // Sonuç rengi
      ),
    );
  }

  Widget _buildAyiriciCizgi() {
    return Container(
      height: 2,
      color: Colors.grey,
      margin: EdgeInsets.symmetric(vertical: 8),
    );
  }

  Widget _buildKurList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _oranlar.keys.length,
        itemBuilder: _buildListItem, // Liste öğelerini oluştur
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    String kur = _oranlar.keys.toList()[index]; // Seçilen para birimi
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      elevation: 4,
      child: ListTile(
        title: Text(
          "$kur - ${_ulkeAdlari[kur] ?? ''}", // Para birimi ve ülke adı
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing:
            Text("${_oranlar.values.toList()[index].toStringAsFixed(4)} ₺"),
      ),
    );
  }

  void _hesapla() {
    double? deger =
        double.tryParse(_controller.text); // Kullanıcının girdiği değer
    double? oran = _oranlar[_secilenKur]; // Seçilen para biriminin oranı

    if (deger != null && oran != null) {
      setState(() {
        _sonuc = deger * oran; // Sonucu hesapla
      });
    }
  }

  void _verileriInternettenCek() async {
    try {
      Uri uri = Uri.parse(_baseUrl + _apiKey);
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        Map<String, dynamic>? parsedResponse = jsonDecode(response.body);

        if (parsedResponse != null && parsedResponse.containsKey('rates')) {
          Map<String, dynamic> rates = parsedResponse["rates"];
          double? baseTlKuru = rates["TRY"];

          if (baseTlKuru != null) {
            for (String ulkeKuru in rates.keys) {
              double? baseKur = double.tryParse(rates[ulkeKuru].toString());
              if (baseKur != null) {
                double tlKuru = baseTlKuru / baseKur;
                _oranlar[ulkeKuru] = tlKuru; // Oranları kaydet
              }
            }
            setState(() {}); // UI güncelle
          } else {
            _showErrorMessage("TL kuru bulunamadı!");
          }
        } else {
          _showErrorMessage("API'den geçersiz veri geldi!");
        }
      } else {
        _showErrorMessage("API isteği başarısız oldu: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorMessage("Veri çekilirken hata oluştu: $e");
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hata"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Tamam"),
            ),
          ],
        );
      },
    );
  }
}*/
//----------------------------------------------------------------------------------------------------------------------
/*import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnaSayfa extends StatefulWidget {
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final String _apiKey = "31700c5fad45c6653e87460deb461111";

  final String _baseUrl =
      "http://api.exchangeratesapi.io/v1/latest?access_key=";

  TextEditingController _controller = TextEditingController();

  Map<String, double> _oranlar = {};

  String _secilenKur = "USD";
  double _sonuc = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verileriInternettenCek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _oranlar.isNotEmpty
          ? _buildBody()
          : Center(child: CircularProgressIndicator()),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Kur Dönüştürücü"),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildKurDonusturuRow(),
          SizedBox(height: 16),
          _buildSonucText(),
          SizedBox(height: 16),
          _buildAyiriciCizgi(),
          SizedBox(height: 16),
          _buildKurList(),
        ],
      ),
    );
  }

  Widget _buildKurDonusturuRow() {
    return Row(
      children: [
        _buildKurTextField(),
        SizedBox(width: 16),
        _buildKurDropdown(),
      ],
    );
  }

  Widget _buildKurTextField() {
    return Expanded(
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (String yeniDeger) {
          _hesapla();
        },
      ),
    );
  }

  Widget _buildKurDropdown() {
    return DropdownButton<String>(
      value: _secilenKur,
      icon: Icon(Icons.arrow_downward),
      underline: SizedBox(),
      items: _oranlar.keys.map((String kur) {
        return DropdownMenuItem<String>(
          value: kur,
          child: Text(kur),
        );
      }).toList(),
      onChanged: (String? yeniDeger) {
        if (yeniDeger != null) {
          _secilenKur = yeniDeger;
          _hesapla();
        }
      },
    );
  }

  Widget _buildSonucText() {
    return Text(
      "${_sonuc.toStringAsFixed(4)} ₺",
      style: TextStyle(
        fontSize: 24,
      ),
    );
  }

  Widget _buildAyiriciCizgi() {
    return Container(
      height: 2,
      color: Colors.black,
    );
  }

  Widget _buildKurList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _oranlar.keys.length,
        itemBuilder: _buildListItem,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
      title: Text(_oranlar.keys.toList()[index]),
      trailing: Text("${_oranlar.values.toList()[index].toStringAsFixed(4)} ₺"),
    );
  }

  void _hesapla() {
    double? deger = double.tryParse(_controller.text);
    double? oran = _oranlar[_secilenKur];

    if (deger != null && oran != null) {
      setState(() {
        _sonuc = deger * oran;
      });
    }
  }

  void _verileriInternettenCek() async {
    Uri uri = Uri.parse(_baseUrl + _apiKey);
    http.Response response = await http.get(uri);

    Map<String, dynamic> parsedResponse = jsonDecode(response.body);

    Map<String, dynamic> rates = parsedResponse["rates"];

    double? baseTlKuru = rates["TRY"];

    if (baseTlKuru != null) {
      for (String ulkeKuru in rates.keys) {
        double? baseKur = double.tryParse(rates[ulkeKuru].toString());
        if (baseKur != null) {
          double tlKuru = baseTlKuru / baseKur;
          _oranlar[ulkeKuru] = tlKuru;
        }
      }
    }

    setState(() {});
  }
}
------------------------------------------------------------------------------------------------
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnaSayfa extends StatefulWidget {
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final String _apiKey = "31700c5fad45c6653e87460deb461111";
  final String _baseUrl = "http://api.exchangeratesapi.io/v1/latest?access_key=";

  TextEditingController _controller = TextEditingController();
  Map<String, double> _oranlar = {};
  String _secilenKur = "USD";
  double _sonuc = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verileriInternettenCek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _oranlar.isNotEmpty
          ? _buildBody()
          : Center(child: CircularProgressIndicator()),
      backgroundColor: Colors.lightBlue[50], // Arka plan rengi
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Kur Dönüştürücü", style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blueAccent,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildKurDonusturuRow(),
          SizedBox(height: 16),
          _buildSonucText(),
          SizedBox(height: 16),
          _buildAyiriciCizgi(),
          SizedBox(height: 16),
          _buildKurList(),
        ],
      ),
    );
  }

  Widget _buildKurDonusturuRow() {
    return Row(
      children: [
        _buildKurTextField(),
        SizedBox(width: 16),
        _buildKurDropdown(),
      ],
    );
  }

  Widget _buildKurTextField() {
    return Expanded(
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          filled: true,
          fillColor: Colors.white,
          labelText: "Miktar",
          labelStyle: TextStyle(color: Colors.blueAccent),
        ),
        onChanged: (String yeniDeger) {
          _hesapla();
        },
      ),
    );
  }

  Widget _buildKurDropdown() {
    return DropdownButton<String>(
      value: _secilenKur,
      icon: Icon(Icons.arrow_downward, color: Colors.blueAccent),
      underline: SizedBox(),
      items: _oranlar.keys.map((String kur) {
        return DropdownMenuItem<String>(
          value: kur,
          child: Text(kur),
        );
      }).toList(),
      onChanged: (String? yeniDeger) {
        if (yeniDeger != null) {
          _secilenKur = yeniDeger;
          _hesapla();
        }
      },
    );
  }

  Widget _buildSonucText() {
    return Text(
      "${_sonuc.toStringAsFixed(4)} ₺",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent, // Sonuç rengi
      ),
    );
  }

  Widget _buildAyiriciCizgi() {
    return Container(
      height: 2,
      color: Colors.grey,
      margin: EdgeInsets.symmetric(vertical: 8),
    );
  }

  Widget _buildKurList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _oranlar.keys.length,
        itemBuilder: _buildListItem,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      elevation: 4,
      child: ListTile(
        title: Text(
          _oranlar.keys.toList()[index],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text("${_oranlar.values.toList()[index].toStringAsFixed(4)} ₺"),
      ),
    );
  }

  void _hesapla() {
    double? deger = double.tryParse(_controller.text);
    double? oran = _oranlar[_secilenKur];

    if (deger != null && oran != null) {
      setState(() {
        _sonuc = deger * oran;
      });
    }
  }

  void _verileriInternettenCek() async {
    Uri uri = Uri.parse(_baseUrl + _apiKey);
    http.Response response = await http.get(uri);

    Map<String, dynamic> parsedResponse = jsonDecode(response.body);
    Map<String, dynamic> rates = parsedResponse["rates"];
    double? baseTlKuru = rates["TRY"];

    if (baseTlKuru != null) {
      for (String ulkeKuru in rates.keys) {
        double? baseKur = double.tryParse(rates[ulkeKuru].toString());
        if (baseKur != null) {
          double tlKuru = baseTlKuru / baseKur;
          _oranlar[ulkeKuru] = tlKuru;
        }
      }
    }

    setState(() {});
  }
}

------------------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnaSayfa extends StatefulWidget {
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final String _apiKey = "31700c5fad45c6653e87460deb461111"; // API anahtarı
  final String _baseUrl =
      "http://api.exchangeratesapi.io/v1/latest?access_key="; // API URL'si

  TextEditingController _controller =
      TextEditingController(); // Kullanıcı girişini almak için
  Map<String, double> _oranlar =
      {}; // Para birimlerinin oranlarını saklamak için
  Map<String, String> _ulkeAdlari = {
    // Para birimlerine ait ülke isimleri
    "AUD": "Avustralya Doları",
    "CAD": "Kanada Doları",
    "CHF": "İsviçre Frangı",
    "CNY": "Çin Yuanı",
    "GBP": "İngiliz Sterlini",
    "JPY": "Japon Yeni",
    "USD": "Amerikan Doları",
    "NZD": "Yeni Zelanda Doları",
    "SEK": "İsveç Kronu",
    "NOK": "Norveç Kronu",
    "DKK": "Danimarka Kronu",
    "SGD": "Singapur Doları",
    "HKD": "Hong Kong Doları",
    "INR": "Hindistan Rupisi",
    "MXN": "Meksika Pesosu",
    "BRL": "Brezilya Reali",
    "ZAR": "Güney Afrika Randı",
    "RUB": "Rus Rublesi",
    "TRY": "Türk Lirası",
    "ARS": "Arjantin Pesosu",
    "IDR": "Endonezya Rupisi",
    "KRW": "Güney Kore Wonu",
    "MYR": "Malezya Ringgiti",
    "THB": "Tayland Bahtı",
    "ILS": "İsrail Şekeli",
    "AED": "Birleşik Arap Emirlikleri Dirhemi",
    "TWD": "Yeni Tayvan Doları",
    "PHP": "Filipin Pesosu",
    "CLP": "Şili Pesosu",
    "COP": "Kolombiya Pesosu",
    "PEN": "Peru Solu",
    "SAR": "Suudi Arabistan Riyali",
    "BHD": "Bahreyn Dinarı",
    "KWD": "Kuveyt Dinarı",
    "QAR": "Katar Riyali",
    "OMR": "Umman Riyali",
    "JOD": "Ürdün Dinarı",

    // Diğer para birimleri eklenebilir
  };

  String _secilenKur = "USD"; // Varsayılan seçilen para birimi
  double _sonuc = 0; // Hesaplanan sonucu saklamak için

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verileriInternettenCek(); // Verileri API'den çek
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // AppBar oluştur
      body: _oranlar.isNotEmpty
          ? _buildBody() // Eğer oranlar varsa gövdeyi oluştur
          : Center(
              child:
                  CircularProgressIndicator()), // Veriler yükleniyorsa göster
      backgroundColor: Colors.lightBlue[50], // Arka plan rengi
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Kur Dönüştürücü",
          style: TextStyle(color: Colors.white)), // Başlık
      backgroundColor: Colors.blueAccent, // AppBar rengi
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildKurDonusturuRow(), // Para birimi dönüştürme satırı
          SizedBox(height: 16),
          _buildSonucText(), // Sonucu gösteren metin
          SizedBox(height: 16),
          _buildAyiriciCizgi(), // Ayırıcı çizgi
          SizedBox(height: 16),
          _buildKurList(), // Para birimleri listesini göster
        ],
      ),
    );
  }

  Widget _buildKurDonusturuRow() {
    return Row(
      children: [
        _buildKurTextField(), // Miktar giriş alanı
        SizedBox(width: 16),
        _buildKurDropdown(), // Para birimi seçimi
      ],
    );
  }

  Widget _buildKurTextField() {
    return Expanded(
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          filled: true,
          fillColor: Colors.white,
          labelText: "Miktar",
          labelStyle: TextStyle(color: Colors.blueAccent),
        ),
        onChanged: (String yeniDeger) {
          _hesapla(); // Kullanıcı yeni bir değer girdiğinde hesapla
        },
      ),
    );
  }

  Widget _buildKurDropdown() {
    return DropdownButton<String>(
      value: _secilenKur,
      icon: Icon(Icons.arrow_downward, color: Colors.blueAccent),
      underline: SizedBox(),
      items: _oranlar.keys.map((String kur) {
        return DropdownMenuItem<String>(
          value: kur,
          child: Text(kur), // Para birimini göster
        );
      }).toList(),
      onChanged: (String? yeniDeger) {
        if (yeniDeger != null) {
          _secilenKur = yeniDeger; // Seçilen para birimini güncelle
          _hesapla(); // Hesaplama yap
        }
      },
    );
  }

  Widget _buildSonucText() {
    return Text(
      "${_sonuc.toStringAsFixed(4)} ₺", // Hesaplanan sonucu göster
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent, // Sonuç rengi
      ),
    );
  }

  Widget _buildAyiriciCizgi() {
    return Container(
      height: 2,
      color: Colors.grey,
      margin: EdgeInsets.symmetric(vertical: 8),
    );
  }

  Widget _buildKurList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _oranlar.keys.length,
        itemBuilder: _buildListItem, // Liste öğelerini oluştur
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    String kur = _oranlar.keys.toList()[index]; // Seçilen para birimi
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      elevation: 4,
      child: ListTile(
        title: Text(
          "$kur - ${_ulkeAdlari[kur] ?? ''}", // Para birimi ve ülke adı
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing:
            Text("${_oranlar.values.toList()[index].toStringAsFixed(4)} ₺"),
      ),
    );
  }

  void _hesapla() {
    double? deger =
        double.tryParse(_controller.text); // Kullanıcının girdiği değer
    double? oran = _oranlar[_secilenKur]; // Seçilen para biriminin oranı

    if (deger != null && oran != null) {
      setState(() {
        _sonuc = deger * oran; // Sonucu hesapla
      });
    }
  }

  void _verileriInternettenCek() async {
    Uri uri = Uri.parse(_baseUrl + _apiKey);
    http.Response response = await http.get(uri);

    Map<String, dynamic> parsedResponse = jsonDecode(response.body);
    Map<String, dynamic> rates =
        parsedResponse["rates"]; // API'den gelen döviz oranları
    double? baseTlKuru = rates["TRY"]; // TL'nin temel kuru

    if (baseTlKuru != null) {
      for (String ulkeKuru in rates.keys) {
        double? baseKur = double.tryParse(rates[ulkeKuru].toString());
        if (baseKur != null) {
          double tlKuru = baseTlKuru / baseKur; // TL cinsinden oranı hesapla
          _oranlar[ulkeKuru] = tlKuru; // Oranları kaydet
        }
      }
    }

    setState(() {}); // UI güncelle
  }
}
*/