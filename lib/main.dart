import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ProZarUygulamasi());
}

class ProZarUygulamasi extends StatelessWidget {
  const ProZarUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: const AnaMenuEkrani(),
    );
  }
}

// ==========================================
// 1. ANA MENÜ EKRANI
// ==========================================
class AnaMenuEkrani extends StatelessWidget {
  const AnaMenuEkrani({super.key});

  void _isimleriSor(BuildContext context) {
    final p1Controller = TextEditingController(text: "Oyuncu 1");
    final p2Controller = TextEditingController(text: "Oyuncu 2");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C3E50),
          title: const Text(
            "Düello Başlıyor",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: p1Controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "1. Oyuncu",
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: p2Controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "2. Oyuncu",
                  labelStyle: TextStyle(color: Colors.cyanAccent),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "İptal",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DuelloEkrani(
                      p1Name: p1Controller.text,
                      p2Name: p2Controller.text,
                    ),
                  ),
                );
              },
              child: const Text("BAŞLA"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.casino, size: 120, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            const Text(
              "ZAR MERKEZİ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 60),
            _menuButonu(
              ikon: Icons.looks_one,
              metin: "TEK ZAR AT",
              renk: Colors.orangeAccent,
              tikla: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SerbestZarEkrani(ciftZarMi: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _menuButonu(
              ikon: Icons.looks_two,
              metin: "ÇİFT ZAR AT",
              renk: Colors.lightGreenAccent,
              tikla: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SerbestZarEkrani(ciftZarMi: true),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _menuButonu(
              ikon: Icons.sports_kabaddi,
              metin: "ZAR DÜELLOSU",
              renk: Colors.purpleAccent,
              tikla: () => _isimleriSor(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButonu({
    required IconData ikon,
    required String metin,
    required Color renk,
    required VoidCallback tikla,
  }) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: tikla,
        icon: Icon(ikon, size: 28),
        label: Text(
          metin,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: renk,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
        ),
      ),
    );
  }
}

// ==========================================
// 2. SERBEST ZAR EKRANI (SES SORUNU ÇÖZÜLDÜ)
// ==========================================
class SerbestZarEkrani extends StatefulWidget {
  final bool ciftZarMi;
  const SerbestZarEkrani({super.key, required this.ciftZarMi});
  @override
  State<SerbestZarEkrani> createState() => _SerbestZarEkraniState();
}

class _SerbestZarEkraniState extends State<SerbestZarEkrani>
    with SingleTickerProviderStateMixin {
  int zar1 = 1;
  int zar2 = 1;
  late AnimationController _animController;
  late Animation<double> _donusAnim, _yukseklikAnim, _olcekAnim;
  final AudioPlayer _player = AudioPlayer(); // Ses oynatıcısı

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animController.value = 1.0;
    _donusAnim = Tween<double>(begin: 0, end: 4 * pi).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _yukseklikAnim = Tween<double>(begin: -200, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.bounceOut),
    );
    _olcekAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.decelerate),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _player.dispose(); // Bellek sızıntısını önlemek için kapat
    super.dispose();
  }

  void zarSalla() async {
    // SES ÇÖZÜMÜ: Sesi çalarken await kullanıyoruz ve hata yakalıyoruz
    try {
      await _player.stop(); // Eğer ses çalıyorsa durdur ve baştan çal
      await _player.play(AssetSource('zar_sesi.mp3'));
    } catch (e) {
      debugPrint("Ses Çalma Hatası: $e");
    }

    setState(() {
      _animController.reset();
      _animController.forward();
      zar1 = Random().nextInt(6) + 1;
      if (widget.ciftZarMi) zar2 = Random().nextInt(6) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2027),
        foregroundColor: Colors.white,
        title: Text(widget.ciftZarMi ? "Çift Zar" : "Tek Zar"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.ciftZarMi)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text(
                        "1. ZAR",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$zar1",
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "-",
                      style: TextStyle(color: Colors.white54, fontSize: 40),
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        "2. ZAR",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$zar2",
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Text(
                "SONUÇ: $zar1",
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _yukseklikAnim.value),
                child: Transform.scale(
                  scale: _olcekAnim.value,
                  child: Transform.rotate(
                    angle: _donusAnim.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ZarTasarimi(zarNo: zar1, color: Colors.white),
                        if (widget.ciftZarMi) const SizedBox(width: 40),
                        if (widget.ciftZarMi)
                          ZarTasarimi(zarNo: zar2, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: zarSalla,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("SALLA"),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. DÜELLO EKRANI (SES SORUNU ÇÖZÜLDÜ)
// ==========================================
class DuelloEkrani extends StatefulWidget {
  final String p1Name;
  final String p2Name;
  const DuelloEkrani({super.key, required this.p1Name, required this.p2Name});
  @override
  State<DuelloEkrani> createState() => _DuelloEkraniState();
}

class _DuelloEkraniState extends State<DuelloEkrani>
    with TickerProviderStateMixin {
  int zar1 = 1;
  int zar2 = 1;
  int p1Skor = 0;
  int p2Skor = 0;
  bool p1Atabilir = true;
  bool p2Atabilir = false;
  late AnimationController _c1, _c2;
  late Animation<double> _y1, _y2, _d1, _d2;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _c2 = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _c1.value = 1.0;
    _c2.value = 1.0;
    _y1 = Tween<double>(
      begin: -200,
      end: 0,
    ).animate(CurvedAnimation(parent: _c1, curve: Curves.bounceOut));
    _y2 = Tween<double>(
      begin: -200,
      end: 0,
    ).animate(CurvedAnimation(parent: _c2, curve: Curves.bounceOut));
    _d1 = Tween<double>(
      begin: 0,
      end: 4 * pi,
    ).animate(CurvedAnimation(parent: _c1, curve: Curves.elasticOut));
    _d2 = Tween<double>(
      begin: 0,
      end: 4 * pi,
    ).animate(CurvedAnimation(parent: _c2, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _player.dispose();
    super.dispose();
  }

  void p1ZarAt() async {
    if (!p1Atabilir) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('zar_sesi.mp3'));
    } catch (e) {
      debugPrint("Ses Hatası: $e");
    }

    setState(() {
      _c1.reset();
      _c1.forward();
      zar1 = Random().nextInt(6) + 1;
      p1Atabilir = false;
      p2Atabilir = true;
    });
  }

  void p2ZarAt() async {
    if (!p2Atabilir) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('zar_sesi.mp3'));
    } catch (e) {
      debugPrint("Ses Hatası: $e");
    }

    setState(() {
      _c2.reset();
      _c2.forward();
      zar2 = Random().nextInt(6) + 1;
      p2Atabilir = false;
      p1Atabilir = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          if (zar1 > zar2)
            p1Skor++;
          else if (zar2 > zar1)
            p2Skor++;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2027),
        foregroundColor: Colors.white,
        title: const Text("Zar Düellosu"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSkorTablosu(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildZarSutunu(
                    widget.p1Name,
                    zar1,
                    _y1,
                    _d1,
                    p1Atabilir,
                    p1ZarAt,
                    Colors.orangeAccent,
                  ),
                  const SizedBox(width: 50),
                  _buildZarSutunu(
                    widget.p2Name,
                    zar2,
                    _y2,
                    _d2,
                    p2Atabilir,
                    p2ZarAt,
                    Colors.cyanAccent,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  p1Atabilir
                      ? "Sıra: ${widget.p1Name}"
                      : "Sıra: ${widget.p2Name}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkorTablosu() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _skorItem(widget.p1Name, p1Skor, Colors.orangeAccent),
          const Text(
            "VS",
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          _skorItem(widget.p2Name, p2Skor, Colors.cyanAccent),
        ],
      ),
    );
  }

  Widget _skorItem(String name, int skor, Color color) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          "$skor",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildZarSutunu(
    String name,
    int no,
    Animation<double> y,
    Animation<double> d,
    bool aktif,
    VoidCallback tikla,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: y,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, y.value),
            child: Transform.rotate(
              angle: d.value,
              child: ZarTasarimi(zarNo: no, color: color),
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: aktif ? tikla : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: aktif ? color : Colors.grey,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          child: Text(
            aktif ? "ZAR AT" : "BEKLE",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class ZarTasarimi extends StatelessWidget {
  final int zarNo;
  final Color color;
  const ZarTasarimi({super.key, required this.zarNo, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Image.asset(
          'assets/zar$zarNo.png',
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => Center(
            child: Text("$zarNo", style: TextStyle(fontSize: 40, color: color)),
          ),
        ),
      ),
    );
  }
}
