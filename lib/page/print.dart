import 'dart:typed_data';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:queue_management/page/firstpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrintPage extends StatefulWidget {
  final String? waitingText;
  final String? q;
  final String? date;
  const PrintPage({super.key, this.waitingText, this.q, this.date});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  GlobalKey globalKey = GlobalKey();
  Uint8List? imageData;
  DateTime dateTime = DateTime.now();
  String date = '';
  String time = '';
  bool pp = false;
  String number = '';
  bool conn = true;

  /*Future<void> saveData(num) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String dateSave = DateFormat("dd/MM/yyyy").format(dateTime);
    await preferences.setInt('number', num);
    await preferences.setString('date', dateSave);
  }

  void countNumber() {
    setState(() {
      number++;
      print(number);
      saveData(number);
    });
  }*/

  Future<void> capture() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3);
      ByteData? byteDate =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteDate != null) {
        setState(() {
          imageData = byteDate.buffer.asUint8List();
          prepareQueue(imageData);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> prepareQueue(image3) async {
    const PaperSize paper = PaperSize.mm58;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);
    final PosPrintResult res = await printer.connect('220.200.30.139',
        port: 9100); //172.10.10.210,//192.168.4.230,//220.200.30.139
    if (res == PosPrintResult.success) {
      final ByteData data = await rootBundle.load('assets/images/logo-cm.png');
      final Uint8List imageByte = data.buffer.asUint8List();
      final img.Image? image = img.decodeImage(imageByte);
      final img.Image resizeLogo = img.copyResize(image!, width: 340);

      final ByteData data2 = await rootBundle.load('assets/images/line.png');
      final Uint8List imageByte2 = data2.buffer.asUint8List();
      final img.Image? image2 = img.decodeImage(imageByte2);
      final img.Image resizeLogo2 = img.copyResize(image2!, width: 300);

      final img.Image? decodeImage = img.decodeImage(image3);
      final img.Image resizeImage = img.copyResize(decodeImage!, width: 370);
      printQueue(printer, resizeImage, resizeLogo, resizeLogo2);
    } else {
      //saveData(number - 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'THERE\'S SOMETHING WRONG. PLEASE CONTACT THE STAFF.',
            style: TextStyle(
              color: Colors.yellow,
              fontFamily: 'th',
            ),
          ),
          backgroundColor: Colors.purple,
          elevation: 50,
          duration: const Duration(hours: 1),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FirstPage(),
                ),
              );
            },
          ),
        ),
      );
      /*showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Printer not connect',
            style: TextStyle(
              fontFamily: 'th',
              fontSize: 20,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FirstPage(),
                    ),
                  );
                });
              },
              child: const Text(
                'OK',
                style: TextStyle(fontFamily: 'th', fontSize: 20),
              ),
            ),
          ],
        ),
      );*/
    }
  }

  Future<void> printQueue(NetworkPrinter printer, image, logo, line) async {
    //printer.image(logo, align: PosAlign.left);
    printer.image(image, align: PosAlign.left);
    //printer.image(line, align: PosAlign.left);
    //printer.imageRaster(logo,align: PosAlign.values[2]);
    printer.cut();
    printer.disconnect();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const FirstPage(),
      ),
    );
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
    //number = widget.q!;
    //countNumber();
    date = DateFormat('dd MMM yyyy HH:mm').format(dateTime);
    Future.delayed(
      const Duration(seconds: 2),
      () {
        setState(() {
          capture();
          pp = true;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.purple[50],
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/BG.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all()),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height,
                      ),
                      AnimatedPositioned(
                        top: !pp
                            ? MediaQuery.of(context).size.height * 0.35
                            : 1000,
                        left: MediaQuery.of(context).size.width * 0.18,
                        duration: const Duration(milliseconds: 500),
                        child: RepaintBoundary(
                          key: globalKey,
                          child: Container(
                            width: 420,
                            height: 450,
                            color: Colors.white,
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              children: [
                                Container(
                                  //decoration: BoxDecoration(border: Border.all()),
                                  width: 380,
                                  child: Image.asset(
                                    'assets/images/logo-cm.png',
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                ),
                                Text(
                                  '${widget.q}',
                                  style: const TextStyle(
                                    fontFamily: 'th',
                                    fontSize: 120,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: Image.asset(
                                    'assets/images/line.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                ),
                                Text(
                                  'Now Serving : ${widget.waitingText.toString()}',
                                  style: const TextStyle(
                                    fontFamily: 'th',
                                    fontSize: 25,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                ),
                                const Text(
                                  'Your number will be called shortly',
                                  style: TextStyle(
                                    fontFamily: 'th',
                                    fontSize: 25,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                ),
                                Text(
                                  widget.date.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'th',
                                    fontSize: 25,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 30),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
