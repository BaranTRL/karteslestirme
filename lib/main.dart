import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Uygulama açık kaldığı sürece en iyi skoru (minimum hamle) tutacak global değişken.
// Başlangıçta çok yüksek bir değer veriyoruz ki ilk bitirmede kolayca geçilebilsin.
int rekorHamle = 99999;

// Uygulamanın başlangıç noktası (Entry point)
void main() {
  runApp(const EfsaneHafizaOyunuApp());
}

// Uygulamanın kök (root) widget'ı. Tema ayarlarını ve ilk açılacak ekranı burada belirliyoruz.
class EfsaneHafizaOyunuApp extends StatelessWidget {
  const EfsaneHafizaOyunuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki 'DEBUG' yazısını kaldırır
      title: 'Hafıza Ustası',
      theme: ThemeData(
        brightness: Brightness.dark, // Karanlık tema
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto', // Genel yazı tipi
      ),
      home: const AnaMenuEkrani(), // Uygulama açıldığında ilk AnaMenuEkrani yüklenecek
    );
  }
}

// --- MODELLER VE ENUMLAR ---
// Oyunun modlarını ve zorluk derecelerini kategorize etmek için Enum kullanıyoruz.
enum OyunModu { klasik, zamanaKarsi, yapayZeka, meydanOkuma }
enum ZorlukDerecesi { kolay, orta, zor, efsane }

// --- ANA MENÜ EKRANI ---
// Durum değiştirebilen (Stateful) bir widget çünkü rekor güncellendiğinde ekranın yenilenmesi gerekiyor.
class AnaMenuEkrani extends StatefulWidget {
  const AnaMenuEkrani({super.key});

  @override
  State<AnaMenuEkrani> createState() => _AnaMenuEkraniState();
}

class _AnaMenuEkraniState extends State<AnaMenuEkrani> {
  
  // Seçilen mod ve zorluk derecesiyle OyunEkrani'na geçiş yapmamızı sağlayan fonksiyon.
  void _oyunaBasla(BuildContext context, OyunModu mod, [ZorlukDerecesi? zorluk]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OyunEkrani(
          secilenMod: mod,
          Zorluk: zorluk ?? ZorlukDerecesi.orta, // Zorluk belirtilmemişse varsayılan 'orta' olur
        ),
      ),
    ).then((_) => setState(() {})); // Oyun bitip geri dönüldüğünde ekranı yeniler (Rekor güncellendiyse ekrana yansır)
  }

  // Klasik, Zamana Karşı veya Yapay Zeka moduna tıklandığında açılan alt menü (Zorluk seçimi)
  void _zorlukSecimDialogu(BuildContext context, OyunModu mod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Zorluk Seç', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Sadece içindeki elemanlar kadar yer kaplar
          children: [
            // Seçime göre Navigator.pop(context) ile dialogu kapatıp hemen ardından oyunu başlatıyoruz
            _ZorlukButonu(metin: 'Kolay (3x4)', onTap: () { Navigator.pop(context); _oyunaBasla(context, mod, ZorlukDerecesi.kolay); }),
            _ZorlukButonu(metin: 'Orta (4x4)', onTap: () { Navigator.pop(context); _oyunaBasla(context, mod, ZorlukDerecesi.orta); }),
            _ZorlukButonu(metin: 'Zor (4x5)', onTap: () { Navigator.pop(context); _oyunaBasla(context, mod, ZorlukDerecesi.zor); }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Arka plan için yukarıdan aşağıya doğru bir renk geçişi (Gradient)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Center(
          // Ekran küçükse veya yataysa taşmaları önlemek için kaydırılabilir alan eklendi
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Oyunun logosu ve başlığı
                const Icon(Icons.style, size: 90, color: Colors.amberAccent),
                const SizedBox(height: 10),
                const Text(
                  'HAFIZA USTASI',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                ),
                const SizedBox(height: 40),
                
                // --- OYUN MODU BUTONLARI ---
                _MenuButonu(
                  baslik: 'Klasik Mod',
                  ikon: Icons.videogame_asset,
                  renk: Colors.blueAccent,
                  onTap: () => _zorlukSecimDialogu(context, OyunModu.klasik),
                ),
                const SizedBox(height: 15),
                _MenuButonu(
                  baslik: 'Zamana Karşı (30sn)',
                  ikon: Icons.timer,
                  renk: Colors.redAccent,
                  onTap: () => _zorlukSecimDialogu(context, OyunModu.zamanaKarsi),
                ),
                const SizedBox(height: 15),
                _MenuButonu(
                  baslik: 'Yapay Zeka VS',
                  ikon: Icons.smart_toy,
                  renk: Colors.purpleAccent,
                  onTap: () => _zorlukSecimDialogu(context, OyunModu.yapayZeka),
                ),
                const SizedBox(height: 15),
                // Challenge (Meydan Okuma) modu zorluk sormaz, direkt 6x7 'efsane' zorlukta başlar
                _MenuButonu(
                  baslik: 'Meydan Okuma (6x7)',
                  ikon: Icons.whatshot,
                  renk: Colors.orangeAccent,
                  onTap: () => _oyunaBasla(context, OyunModu.meydanOkuma, ZorlukDerecesi.efsane),
                ),
                const SizedBox(height: 30),
                
                // Eğer bir rekor kırılmışsa (varsayılan değer değişmişse) rekor kutusunu göster
                if (rekorHamle != 99999)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Text(
                      '🏆 En İyi Meydan Okuma Rekoru: $rekorHamle Hamle',
                      style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- BUTON WIDGETLARI ---
// Ana menüdeki renkli, ikonlu geniş butonların tasarımı
class _MenuButonu extends StatelessWidget {
  final String baslik;
  final IconData ikon;
  final Color renk;
  final VoidCallback onTap;

  const _MenuButonu({required this.baslik, required this.ikon, required this.renk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: renk.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: renk.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: Colors.white),
            const SizedBox(width: 10),
            Text(baslik, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// Zorluk seçimi dialogundaki butonların tasarımı
class _ZorlukButonu extends StatelessWidget {
  final String metin;
  final VoidCallback onTap;

  const _ZorlukButonu({required this.metin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white24,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onTap,
        child: Text(metin, style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}

// --- OYUN EKRANI VE MANTIĞI ---
// Asıl oyunun oynandığı ekran. Seçilen mod ve zorluk buraya parametre olarak gelir.
class OyunEkrani extends StatefulWidget {
  final OyunModu secilenMod;
  final ZorlukDerecesi Zorluk;

  const OyunEkrani({super.key, required this.secilenMod, required this.Zorluk});

  @override
  State<OyunEkrani> createState() => _OyunEkraniState();
}

class _OyunEkraniState extends State<OyunEkrani> {
  // Daha fazla kart için genişletilmiş emoji listesi (Meydan okuma modu için en az 21 çift lazım)
  final List<String> _tumEmojiler = [
    '🍌','🚗','🍎','🐱','⚽','🌟','🍕','🚀','💎','🎸',
    '🐸','🍦','🎈','🎁','🔥','🌻','🍄','🌍','🌈','🍔',
    '🍟','🍩','🏀','🎮','🎲','🎯','🎨','🎬','🎤','🎧'
  ];

  // Oyun tahtasındaki kartların durumlarını tuttuğumuz listeler
  List<String> _oyunKartlari = []; // Hangi indexte hangi emoji var
  List<bool> _acikKartlar = [];    // O an arkası mı çevrili yüzü mü (true = yüzü görünüyor)
  List<bool> _eslesenKartlar = []; // Eşleşip tamamen açık kalması gereken kartlar

  // Oyun mekaniği için kontrol değişkenleri
  int _oncekiSecimIndex = -1; // İlk açılan kartın index'ini tutar. (-1 ise henüz kart seçilmemiştir)
  bool _islemYapiliyor = false; // Animasyon sürerken kullanıcının başka karta tıklamasını engeller
  int _sutunSayisi = 3; // GridView'de yan yana kaç kart olacağı

  // Zamana Karşı Modu Değişkenleri
  int _kalanSure = 30;
  Timer? _zamanlayici;

  // Yapay Zeka Modu Değişkenleri
  bool _oyuncuSirasi = true; // true = Bizim sıramız, false = Yapay zekanın sırası
  int _oyuncuSkor = 0;
  int _yapayZekaSkor = 0;
  final Map<int, String> _yapayZekaHafiza = {}; // Yapay zekanın açılan kartları aklında tuttuğu yapı (Index: Emoji)

  // Meydan Okuma / Klasik Mod Değişkenleri
  int _hamleSayisi = 0; // İki kart açmak 1 hamle sayılır

  // Ekran ilk yüklendiğinde oyun kurulumunu tetikler
  @override
  void initState() {
    super.initState();
    _oyunuKur();
  }

  // Ekran kapatıldığında arka planda sayacın çalışmaya devam etmemesi için Timer'ı yok ederiz
  @override
  void dispose() {
    _zamanlayici?.cancel();
    super.dispose();
  }

  // Seçilen mod ve zorluğa göre tahtayı, değişkenleri ve sayacı sıfırlar
  void _oyunuKur() {
    int kartSayisi;
    
    // Zorluğa göre toplam kart sayısını (çift olmalı) ve sütun sayısını belirliyoruz
    if (widget.secilenMod == OyunModu.meydanOkuma) {
      kartSayisi = 42; // 6x7 Grid (21 çift)
      _sutunSayisi = 6;
    } else {
      if (widget.Zorluk == ZorlukDerecesi.kolay) {
        kartSayisi = 12; // 3x4 (6 çift)
        _sutunSayisi = 3;
      } else if (widget.Zorluk == ZorlukDerecesi.orta) {
        kartSayisi = 16; // 4x4 (8 çift)
        _sutunSayisi = 4;
      } else {
        kartSayisi = 20; // 4x5 (10 çift)
        _sutunSayisi = 4;
      }
    }

    // Kart listesini temizleyip baştan oluşturma
    _oyunKartlari.clear();
    // İhtiyacımız olan kadar emojiyi ana listeden alıyoruz (toplam kartın yarısı kadar)
    List<String> secilenEmojiler = _tumEmojiler.sublist(0, kartSayisi ~/ 2);
    // Aynı emojilerden ikişer tane ekliyoruz ki çiftler oluşsun
    _oyunKartlari.addAll(secilenEmojiler);
    _oyunKartlari.addAll(secilenEmojiler);
    // Kartların yerlerini rastgele karıştırıyoruz
    _oyunKartlari.shuffle();

    // Kartların hepsi başlangıçta kapalı ve eşleşmemiş durumda
    _acikKartlar = List<bool>.filled(kartSayisi, false);
    _eslesenKartlar = List<bool>.filled(kartSayisi, false);
    
    // Oyun mekaniği değişkenlerini sıfırlama
    _oncekiSecimIndex = -1;
    _islemYapiliyor = false;
    _oyuncuSkor = 0;
    _yapayZekaSkor = 0;
    _oyuncuSirasi = true;
    _yapayZekaHafiza.clear();
    _hamleSayisi = 0;

    // Mod zamana karşı ise süreyi 30 yapıp sayacı başlat
    if (widget.secilenMod == OyunModu.zamanaKarsi) {
      _kalanSure = 30;
      _zamanlayiciSistemiBaslat();
    }

    setState(() {}); // Arayüzü günceller
  }

  // Zamana karşı modu için her saniye çalışan geri sayım fonksiyonu
  void _zamanlayiciSistemiBaslat() {
    _zamanlayici?.cancel(); // Eğer çalışan başka bir sayaç varsa durdur
    _zamanlayici = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) { // Widget hala ekrandaysa işlem yap
        setState(() {
          if (_kalanSure > 0) {
            _kalanSure--; // Süreden 1 saniye düş
          } else {
            // Süre 0 olduğunda oyunu durdur ve kaybetme mesajı göster
            _zamanlayici?.cancel();
            _islemYapiliyor = true; // Tıklamaları engelle
            _oyunBittiUyarisi('Süre Bitti! Kaybettin 😢');
          }
        });
      }
    });
  }

  // Kullanıcı bir karta tıkladığında çalışacak ilk kontrol metodu
  void _kartTiklandi(int index) {
    // Tıklamayı engelleme koşulları:
    // 1. İki kart açılmış ve kıyaslanıyorsa (_islemYapiliyor)
    // 2. Kart zaten açıksa veya eşleşmişse
    // 3. Mod yapay zeka ve sıra bizde değilse
    if (_islemYapiliyor || _acikKartlar[index] || _eslesenKartlar[index] || (!_oyuncuSirasi && widget.secilenMod == OyunModu.yapayZeka)) {
      return;
    }

    _hamleYap(index);
  }

  // Tıklanan veya YZ tarafından seçilen kartı açma işlemini yapan metot
  void _hamleYap(int index) {
    setState(() {
      _acikKartlar[index] = true; // Tıklanan kartın yüzünü göster
    });

    // Mod yapay zeka ise, açılan kartın emojisinin ne olduğunu ve nerede olduğunu YZ'nin hafızasına kaydet
    if (widget.secilenMod == OyunModu.yapayZeka) {
      _yapayZekaHafiza[index] = _oyunKartlari[index];
    }

    // Eğer bu hamle ilk açılan kartsa (Önceden açık kart yoksa)
    if (_oncekiSecimIndex == -1) {
      _oncekiSecimIndex = index; // Bu indexi hafızaya al
    } 
    // Eğer bu ikinci açılan kartsa (Eşleşme kontrolü zamanı)
    else {
      _islemYapiliyor = true; // Yeni tıklamaları engelle
      
      // Sadece klasik veya meydan okuma modunda hamle sayısını artır (İki kart açılınca 1 hamle olur)
      if (widget.secilenMod == OyunModu.meydanOkuma || widget.secilenMod == OyunModu.klasik) {
        _hamleSayisi++; 
      }
      _eslesmeKontrolu(index); // İlk açılanla bunu karşılaştır
    }
  }

  // İkinci kart da açıldıktan sonra iki kartın emojisinin aynı olup olmadığını kontrol eder
  void _eslesmeKontrolu(int guncelIndex) {
    // Eşleşme durumu: Yeni açılan kartın emojisi, ilk açılan kartın emojisine eşit mi?
    bool eslesti = _oyunKartlari[guncelIndex] == _oyunKartlari[_oncekiSecimIndex];

    // Animasyonun (kartların bir süre açık kalmasının) görünmesi için 0.8 saniye (800ms) bekletiyoruz
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        if (eslesti) {
          // Kartlar aynıysa: Her iki kartı da 'eşleşti' olarak işaretle (Kalıcı olarak açık kalırlar)
          _eslesenKartlar[guncelIndex] = true;
          _eslesenKartlar[_oncekiSecimIndex] = true;

          if (widget.secilenMod == OyunModu.yapayZeka) {
            // Skoru sırası gelene yaz
            _oyuncuSirasi ? _oyuncuSkor++ : _yapayZekaSkor++;
            // Eşleşen kartları YZ'nin hafızasından sil (Artık onlarla işi kalmadı)
            _yapayZekaHafiza.remove(guncelIndex);
            _yapayZekaHafiza.remove(_oncekiSecimIndex);
          }
        } else {
          // Kartlar farklıysa: Her ikisini de geri kapat
          _acikKartlar[guncelIndex] = false;
          _acikKartlar[_oncekiSecimIndex] = false;
          
          // Eşleşmediği için sıra rakibe geçer (Yapay zeka modundaysak)
          if (widget.secilenMod == OyunModu.yapayZeka) {
            _oyuncuSirasi = !_oyuncuSirasi;
          }
        }

        // Tıklama kilidini kaldır ve ilk seçim hafızasını sıfırla (Yeni tur için)
        _oncekiSecimIndex = -1;
        _islemYapiliyor = false;
      });

      _oyunBittiMiKontrolEt(); // Tüm kartlar eşleşti mi diye kontrol et

      // Eğer oyun bitmediyse ve sıra yapay zekaya geçtiyse YZ hamlesini başlat
      if (widget.secilenMod == OyunModu.yapayZeka && !_oyuncuSirasi && _eslesenKartlar.contains(false)) {
        _yapayZekaHamlesi();
      }
    });
  }

  // Yapay Zekanın düşünme ve kart açma algoritması
  void _yapayZekaHamlesi() async {
    _islemYapiliyor = true; // Oyuncunun bu sırada tıklamasını engelle
    await Future.delayed(const Duration(seconds: 1)); // YZ düşünüyormuş gibi 1 saniye bekle

    int secim1 = -1;
    int secim2 = -1;

    // 1. ADIM: YZ'nin hafızasında aynı emojiden 2 tane var mı kontrol et (Kesin eşleşme var mı?)
    var hafizaListesi = _yapayZekaHafiza.entries.toList();
    for (int i = 0; i < hafizaListesi.length; i++) {
      for (int j = i + 1; j < hafizaListesi.length; j++) {
        if (hafizaListesi[i].value == hafizaListesi[j].value) {
          // Eğer hafızada aynı emojiden iki farklı kart indexi bulursa o ikisini seç
          secim1 = hafizaListesi[i].key;
          secim2 = hafizaListesi[j].key;
          break;
        }
      }
      if (secim1 != -1) break;
    }

    // 2. ADIM: Eğer hafızada iki aynı kart yoksa mecburen rastgele bir kart seçecek
    if (secim1 == -1) {
      // Önce henüz eşleşmemiş ve o an açık olmayan kapalı kartların indexlerini bir listeye al
      List<int> kapaliKartlar = [];
      for (int i = 0; i < _oyunKartlari.length; i++) {
        if (!_eslesenKartlar[i] && !_acikKartlar[i]) kapaliKartlar.add(i);
      }

      if (kapaliKartlar.isNotEmpty) {
        // Kapalı kartlardan rastgele birini birinci seçim yap
        secim1 = kapaliKartlar[Random().nextInt(kapaliKartlar.length)];

        // Şimdi bu seçilen kartın emojisi açıldı. Hemen hafızaya bakıyoruz. 
        // Acaba bu açılan emojinin eşini daha önceden görmüş müydük?
        String acilanEmoji = _oyunKartlari[secim1];
        for (var hafiza in _yapayZekaHafiza.entries) {
          if (hafiza.value == acilanEmoji && hafiza.key != secim1) {
            secim2 = hafiza.key; // Gördüysek ikinci seçimi doğrudan hafızadaki o kart yap
            break;
          }
        }

        // Eğer açtığı ilk kartın eşini hafızada bulamadıysa, ikinci kartı da rastgele açmak zorunda
        if (secim2 == -1) {
          kapaliKartlar.remove(secim1); // İlk seçtiğini listeden çıkar
          if (kapaliKartlar.isNotEmpty) {
            secim2 = kapaliKartlar[Random().nextInt(kapaliKartlar.length)];
          }
        }
      }
    }

    // YZ kartlarını seçtiyse animasyonlu bir şekilde ekrana yansıt
    if (secim1 != -1 && secim2 != -1) {
      if (!mounted) return;
      _islemYapiliyor = false;
      _hamleYap(secim1); // YZ'nin ilk kartını aç

      await Future.delayed(const Duration(milliseconds: 600)); // 0.6 sn bekle (insan gibi algılansın)

      if (!mounted) return;
      _islemYapiliyor = false;
      _hamleYap(secim2); // YZ'nin ikinci kartını aç ve eşleşme kontrolüne (eslesmeKontrolu) git
    }
  }

  // Tüm kartların eslesenKartlar listesinde 'true' olup olmadığına bakar. Oyunun bitişini denetler.
  void _oyunBittiMiKontrolEt() {
    if (!_eslesenKartlar.contains(false)) { // Eğer listede false (eşleşmemiş) kalmadıysa oyun bitmiştir
      _zamanlayici?.cancel(); // Sayacı durdur
      String mesaj = 'Tebrikler, Kazandın! 🎉';

      // Modlara göre özel bitiş mesajları
      if (widget.secilenMod == OyunModu.yapayZeka) {
        if (_oyuncuSkor > _yapayZekaSkor) {
          mesaj = 'Harika! Yapay Zekayı Yendin! 😎';
        } else if (_yapayZekaSkor > _oyuncuSkor) {
          mesaj = 'Yapay Zeka Kazandı 🤖';
        } else {
          mesaj = 'Berabere! 🤝';
        }
      } else if (widget.secilenMod == OyunModu.meydanOkuma) {
        if (_hamleSayisi < rekorHamle) {
          // Yeni rekor kırıldıysa global değişkeni güncelle
          rekorHamle = _hamleSayisi;
          mesaj = 'YENİ REKOR! 🔥\n$_hamleSayisi hamlede bitirdin.';
        } else {
          mesaj = 'Tebrikler!\n$_hamleSayisi hamlede bitirdin.\nEn İyi Skor: $rekorHamle';
        }
      }

      // Dialog penceresini göster
      _oyunBittiUyarisi(mesaj);
    }
  }

  // Oyun bitince ekrana çıkan bilgilendirme ve yeniden oynama dialogu
  void _oyunBittiUyarisi(String mesaj) {
    showDialog(
      context: context,
      barrierDismissible: false, // Ekranda boş yere tıklayarak kapatmayı engeller
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(mesaj, style: const TextStyle(color: Colors.white, height: 1.5), textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              // İki kez pop yapıyoruz çünkü biri Dialogu, diğeri Oyun Ekranını kapatır (Ana menüye döner)
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Ana Menü', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context); // Dialogu kapat
              _oyunuKur();            // Oyunu sıfırla ve yeniden başlat
            },
            child: const Text('Tekrar Oyna', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // Oyun ekranının görsel yapısı
  @override
  Widget build(BuildContext context) {
    // Dinamik responsive yapı: Sütun sayısı 6 ve üzeriyse (meydan okuma) emojiler ve boşluklar daraltılır ki ekrana sığsın
    double emojiBoyutu = _sutunSayisi >= 6 ? 24 : 45;
    double gridBosluk = _sutunSayisi >= 6 ? 6 : 12;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- ÜST BİLGİ VE KONTROL ÇUBUĞU (AppBar muadili) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Geri dönüş butonu
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    
                    // Mod zamana karşı ise ortada saniye göstergesi
                    if (widget.secilenMod == OyunModu.zamanaKarsi)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          // Süre 10 saniyenin altına düşerse kırmızı uyarı rengi olur
                          color: _kalanSure <= 10 ? Colors.redAccent.withOpacity(0.8) : Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Süre: $_kalanSure',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      
                    // Mod meydan okuma ise ortada hamle sayacı
                    if (widget.secilenMod == OyunModu.meydanOkuma)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Hamle: $_hamleSayisi',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      
                    // Mod yapay zeka ise ortada skor tablosu
                    if (widget.secilenMod == OyunModu.yapayZeka)
                      Row(
                        children: [
                          _SkorKutusu(baslik: 'Sen', skor: _oyuncuSkor, aktifSira: _oyuncuSirasi, renk: Colors.blueAccent),
                          const SizedBox(width: 8),
                          _SkorKutusu(baslik: 'Y.Z.', skor: _yapayZekaSkor, aktifSira: !_oyuncuSirasi, renk: Colors.purpleAccent),
                        ],
                      ),
                      
                    // Oyunu yeniden başlatma butonu
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _oyunuKur,
                    ),
                  ],
                ),
              ),

              // --- KARTLARIN DİZİLDİĞİ OYUN ALANI (GridView) ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(), // Scroll yapıldığında iOS tarzı esnek sekme efekti
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _sutunSayisi, // Kaç sütun olacak (örneğin 3, 4 veya 6)
                      crossAxisSpacing: gridBosluk, // Kartlar arası yatay boşluk
                      mainAxisSpacing: gridBosluk,  // Kartlar arası dikey boşluk
                      childAspectRatio: widget.secilenMod == OyunModu.meydanOkuma ? 0.9 : 0.85, // Kartların en/boy oranı
                    ),
                    itemCount: _oyunKartlari.length,
                    itemBuilder: (context, index) {

                      // Kartın açık mı yoksa eşleşmiş mi olduğunu kontrol et (İkisinden biriyse yüzü görünür)
                      bool goster = _acikKartlar[index] || _eslesenKartlar[index];
                      return GestureDetector(
                        onTap: () => _kartTiklandi(index),
                        // AnimatedContainer kullanarak kart açılıp kapanırken yumuşak bir renk geçişi sağlıyoruz
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            // Kart açıksa beyaz tonlu bir gradient, kapalıysa mavi/yeşil tonlu bir gradient alır
                            gradient: goster
                                ? const LinearGradient(colors: [Colors.white, Color(0xFFEEEEEE)])
                                : const LinearGradient(colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: goster ? Colors.white24 : const Color(0xFF00C9FF).withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(2, 4),
                              )
                            ],
                            // Kart eşleştiği anda etrafında yeşil bir çerçeve belirir
                            border: Border.all(
                              color: _eslesenKartlar[index] ? Colors.green : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            // Kart kapalıysa emoji gizlenir (opacity 0), açıksa belirir (opacity 1)
                            child: AnimatedOpacity(
                              opacity: goster ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _oyunKartlari[index],
                                style: TextStyle(fontSize: emojiBoyutu),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SKOR WIDGETI ---
// Yapay zeka modunda üstte görünen oyuncu ve YZ skor kutucuklarının tasarımı
class _SkorKutusu extends StatelessWidget {
  final String baslik;
  final int skor;
  final bool aktifSira; // Eğer sıra bu oyuncudaysa kutucuk aydınlanır ve renklenir
  final Color renk;

  const _SkorKutusu({required this.baslik, required this.skor, required this.aktifSira, required this.renk});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: aktifSira ? renk : Colors.black45, // Sıra onda değilse soluk siyah görünür
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: aktifSira ? Colors.white : Colors.transparent, width: 2),
        boxShadow: aktifSira ? [BoxShadow(color: renk.withOpacity(0.6), blurRadius: 10)] : [],
      ),
      child: Column(
        children: [
          Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(skor.toString(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
