import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const ProZarUygulamasi());
}

class ProZarUygulamasi extends StatelessWidget {
  const ProZarUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // Varsa özel fontun, buraya yazabilirsin
      ),
      home: const ZarEkrani(),
    );
  }
}

class ZarEkrani extends StatefulWidget {
  const ZarEkrani({super.key});

  @override
  State<ZarEkrani> createState() => _ZarEkraniState();
}

// TickerProviderStateMixin: Animasyon için gerekli 'vakit'i sağlar
class _ZarEkraniState extends State<ZarEkrani> with TickerProviderStateMixin {
  // Zar numaraları
  int zar1 = 1;
  int zar2 = 1;
  bool ciftZarMi = false; // Modu takip eder

  // Animasyon Kontrolcüleri
  late AnimationController _animController;
  late Animation<double> _donusAnim; // Dönüş efekti
  late Animation<double> _yukseklikAnim; // Havadan düşme (Y ekseni)
  late Animation<double> _olcekAnim; // Sekme hissi (Scale)

  @override
  void initState() {
    super.initState();

    // 1. Ana Kontrolcü: Animasyonun toplam süresini belirler (600ms)
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 2. Dönüş Animasyonu: Zar 3 tam tur (3 * 2 * pi) döner, elasticOut ile yaylanarak durur
    _donusAnim = Tween<double>(begin: 0, end: 3 * 2 * pi).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 1.0, curve: Curves.elasticOut),
      ),
    );

    // 3. Yükseklik Animasyonu: Zar -200 pikselden (ekranın üstünden) 0'a (kendi yerine) düşer
    _yukseklikAnim = Tween<double>(begin: -200, end: 0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.bounceOut),
      ),
    );

    // 4. Ölçek Animasyonu: Düşerken %80 boyutunda başlar, interval içinde %100'e (1.0) çıkar
    _olcekAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.decelerate),
      ),
    );
  }

  @override
  void dispose() {
    // Hafıza sızıntısını önlemek için kontrolcüyü temizle
    _animController.dispose();
    super.dispose();
  }

  void zarSalla(bool ciftMi) {
    setState(() {
      ciftZarMi = ciftMi;

      // Animasyonu başa sar ve yeniden oynat
      _animController.reset();
      _animController.forward();

      // Rastgele sayıları üret
      zar1 = Random().nextInt(6) + 1;
      if (ciftZarMi) {
        zar2 = Random().nextInt(6) + 1;
      } else {
        zar2 = 0; // Tek zar modunda 2. zar 0 olsun
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Atılan zarların toplamını hesapla (sadece tek veya çift zar açıksa)
    int toplam = zar1 + (ciftZarMi ? zar2 : 0);

    return Scaffold(
      // Modern Koyu Degrade Arka Plan
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50), // Üst koyu mavi
              Color(0xFF4CA1AF), // Alt açık mavi
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Sonuç Paneli (Neon Efektli)
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'SONUÇ',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      '$toplam',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Zarlar ve Profesyonel Sekme Animasyonu
              Expanded(
                child: Center(
                  // Bu Widget'lar (Builder'lar) animasyon değerlerine göre zarı günceller
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          _yukseklikAnim.value,
                        ), // Y ekseninde düşme
                        child: Transform.scale(
                          scale: _olcekAnim.value, // Ölçekli sekme
                          child: Transform.rotate(
                            angle: _donusAnim.value, // Kendi etrafında dönüş
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ZarTasarimi(zarNo: zar1),
                                // Çift zar modu açıksa araya boşluk koy ve 2. zarı göster
                                if (ciftZarMi) const SizedBox(width: 40),
                                if (ciftZarMi) ZarTasarimi(zarNo: zar2),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 3. Butonlar Paneli (Modern Stil)
              Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // BUTON 1: TEK ZAR
                    ElevatedButton(
                      onPressed: () => zarSalla(false), // Tek zar modu
                      style: dynamicButtonStyle(Colors.orange),
                      child: const Text(
                        'TEK ZAR AT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // BUTON 2: ÇİFT ZAR
                    ElevatedButton(
                      onPressed: () => zarSalla(true), // Çift zar modu
                      style: dynamicButtonStyle(Colors.cyan),
                      child: const Text(
                        'ÇİFT ZAR AT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ortak Buton Stili (Temiz Kod için)
  ButtonStyle dynamicButtonStyle(Color mainColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: mainColor.withOpacity(0.8),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
      elevation: 10,
      shadowColor: mainColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    );
  }
}

// Zar Resminin Tasarımı ve Gölgesi (Temiz Kod için ayrı bir Widget)
class ZarTasarimi extends StatelessWidget {
  final int zarNo;
  const ZarTasarimi({super.key, required this.zarNo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(5, 10), // Gölge sağa ve aşağı
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0), // Resim ile beyaz kutu arası boşluk
        child: Image.asset(
          'assets/zar$zarNo.png',
          height: 120, // Zarlar biraz daha küçük olsun
          width: 120,
          errorBuilder: (context, error, stackTrace) {
            // Resimler hazır değilse hata vermeden kırmızı rakam gösterir
            return Container(
              height: 120,
              width: 120,
              color: Colors.red,
              alignment: Alignment.center,
              child: Text(
                '$zarNo',
                style: const TextStyle(fontSize: 80, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
