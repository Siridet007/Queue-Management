import 'dart:convert';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:queue_management/model/model.dart';
import 'package:queue_management/page/print.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  double? width;
  double? height;
  String text = 'Select Language';
  String wait = 'Waiting';
  String wait2 = 'queue';
  int number = 0;
  String printBT = 'Take Queue Here';
  String lan = 'en';
  bool select = false;
  DateTime dateTime = DateTime.now();
  List<GetQueue>? queueList = [];
  VideoPlayerController? controller;

  Future<void> loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String date = DateFormat("dd/MM/yyyy").format(dateTime);
    if (date != preferences.getString('date')) {
      deleteDate();
    } else {
      print(date);
    }
    number = preferences.getInt('number') ?? 0;
  }

  Future<void> deleteDate() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('number', 0);
  }

  Future<void> saveData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String date = DateFormat("dd/MM/yyyy").format(dateTime);
    await preferences.setString('date', date);
  }

  Future<List<GetQueue>?> getQueueData() async {
    String domain = "http://220.200.30.45:3007/nextqueue?qtype=A";
    try {
      Response response = await Dio().post(domain);

      // Check if response.data contains a list or map
      if (response.data is List) {
        // Directly handle a list of objects
        return GetQueue.fromJsonList(response.data);
      } else if (response.data is Map) {
        // Handle if the Map contains a list
        if (response.data.containsKey('data') &&
            response.data['data'] is List) {
          return GetQueue.fromJsonList(response.data['data']);
        } else {
          // Handle the case where it's just a single object and wrap it in a list
          return [GetQueue.fromJson(response.data)];
        }
      } else {
        print("Unexpected data format: ${response.data}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enabled;
    controller = VideoPlayerController.asset('assets/images/BG-teblet.mp4')
      ..setLooping(true) // Enable looping
      ..initialize().then((_) {
        setState(() {}); // Refresh to show the video once initialized
        controller!.play(); // Start playing automatically
      });

    super.initState();
    loadData();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    WakelockPlus.enable();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            /*Container(
              width: width,
              height: height,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/BG-teblet.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),*/
            SizedBox(
              width: width,
              height: height,
              child: AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: VideoPlayer(controller!),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: width,
                height: height,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 220),
                        Text(
                          'Welcome',
                          style: TextStyle(
                            fontFamily: 'en',
                            fontSize: 85,
                            color: Colors.yellow.shade700,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 5,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          'Please Press For\n  Queue Number.',
                          style: TextStyle(
                            fontFamily: 'en',
                            fontSize: 40,
                            color: Colors.yellow.shade700,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 5,
                          ),
                        ),
                        const SizedBox(height: 50),
                        InkWell(
                          onTap: () {
                            setState(() {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => const AlertDialog(
                                  backgroundColor: Colors.transparent,
                                  title: SizedBox(
                                    height: 200,
                                    child: CircularProgressIndicator(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                              getQueueData().then((value) {
                                setState(() {
                                  queueList = value;
                                  if (queueList == null) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'THERE\'S SOMETHING WRONG. PLEASE CONTACT THE STAFF.',
                                          style: TextStyle(
                                            color: Colors.yellow,
                                            fontFamily: 'th',
                                          ),
                                        ),
                                        duration: Duration(seconds: 5),
                                        backgroundColor: Colors.red,
                                        elevation: 50,
                                      ),
                                    );
                                  } else {
                                    print(jsonEncode(queueList));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PrintPage(
                                          waitingText:
                                              '${queueList!.first.queuewait}',
                                          q: queueList!.first.nextqueue,
                                          date: DateFormat('dd MMM yyyy HH:mm')
                                              .format(
                                            DateTime.parse(
                                              queueList!.first.qdate.toString(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                });
                              });
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrintPage(
                                      waitingText: '10',
                                      q: 'T05',
                                      date: '25/11/2024'),
                                ),
                              );*/
                            });
                          },
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              //border: Border.all(),
                              //borderRadius: BorderRadius.circular(30),
                              color: Colors.yellow.shade700,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Press',
                                  style: TextStyle(
                                    fontFamily: 'en',
                                    fontSize: 40,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    /*select
                        ? SizedBox(
                            width: width! * .1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      text = 'Select Language';
                                      wait = 'Waiting';
                                      wait2 = 'queue';
                                      printBT = 'Take Queue Here';
                                      lan = 'EN';
                                      select = !select;
                                    });
                                  },
                                  child: Container(
                                    width: 75,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            AssetImage('assets/images/flags/el.png'),
                                        fit: BoxFit.fill,
                                        alignment: Alignment.centerRight,
                                      ),
                                      //border: Border.all(),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      text = 'เลือกภาษา';
                                      wait = 'จำนวนคิว';
                                      wait2 = 'คิว';
            
                                      printBT = 'รับบัตรคิวที่นี่';
                                      lan = 'TH';
                                      select = !select;
                                    });
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            AssetImage('assets/images/flags/th.png'),
                                        fit: BoxFit.contain,
                                        alignment: Alignment.centerRight,
                                      ),
                                      //border: Border.all(),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      text = '選擇語言';
                                      wait = '佇列數';
                                      wait2 = '佇列';
            
                                      printBT = '領取排隊卡';
                                      lan = 'CHS';
                                      select = !select;
                                    });
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            AssetImage('assets/images/flags/cn2.png'),
                                        fit: BoxFit.contain,
                                        alignment: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      text = '选择语言';
                                      wait = '队列数量';
                                      wait2 = '队列';
            
                                      printBT = '领取排队卡';
                                      lan = 'CHT';
                                      select = !select;
                                    });
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/flags/cn1.png'),
                                          fit: BoxFit.contain,
                                          alignment: Alignment.centerRight),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      text = 'Выберите язык';
                                      wait = 'количество';
                                      wait2 = 'очередь';
            
                                      printBT = 'Получите карту очереди';
                                      lan = 'RS';
                                      select = !select;
                                    });
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            AssetImage('assets/images/flags/rs.png'),
                                        fit: BoxFit.contain,
                                        alignment: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      text = 'اختر اللغة';
                                      wait = 'عدد قوائم الانتظار';
                                      wait2 = 'طابور';
            
                                      printBT = 'الحصول على بطاقة الانتظار';
                                      lan = 'AE';
                                      select = !select;
                                    });
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            AssetImage('assets/images/flags/ae.png'),
                                        fit: BoxFit.contain,
                                        alignment: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      text = '言語を選択してください';
                                      wait = 'キューの数';
                                      wait2 = '列';
            
                                      printBT = 'キューカードを入手する';
                                      lan = 'JP';
                                      select = !select;
                                    });
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            AssetImage('assets/images/flags/jp.png'),
                                        fit: BoxFit.contain,
                                        alignment: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: width! * .1,
                          ),*/
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
