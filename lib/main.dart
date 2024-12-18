import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rfid_counter/json_save.dart';
import 'package:rfid_counter/rfidCards.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: const MyHomePage(title: 'RFID Tag Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const channel = MethodChannel("com.example.rfid_counter/method");
  static const stream = EventChannel('com.example.rfid_counter/event');
  bool visible = true;
  double dist = 15;
  // ignore: non_constant_identifier_names
  Map<String, List<Map>> RFIDs = {};

  addReadData(data) {
    var category = setCategory(data["EPC"]);
    if (RFIDs[category] == null) {
      RFIDs[category] = [];
    }
    RFIDs[category]?.add(data);
    Local.update(RFIDs);
    setState(() {});
  }

  String setCategory(String? EPC) {
    String category = "unknown";

    if (EPC == null) {
      return category;
    }
    if (EPC.startsWith("1001")) {
      category = "betsheet";
    } else if (EPC.startsWith("1002")) {
      category = "Duvet";
    } else if (EPC.startsWith("1003")) {
      category = "Pillow Case";
    } else if (EPC.startsWith("2001")) {
      category = "Towel";
    }

    return category;
  }

  handleOptions(String s) {
    switch (s) {
      case 'Stop':
        showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.3),
            builder: (context) {
              return Material(
                  color: Colors.transparent,
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Are You sure?"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                      child: Text("YES"),
                                      onPressed: () => Navigator.pop(context, true)),
                                  TextButton(
                                      child: Text("NO"),
                                      onPressed: () => Navigator.pop(context, false)),
                                ],
                              )
                            ],
                          ))));
            }).then((r) {
          if (r) {
            channel.invokeListMethod("stop");
          }
        });

        break;
      case 'Setup':
        showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.3),
            builder: (con) {
              return SliderModal(dist: dist);
            }).then((r) {
          int dist = r.round();
          channel.invokeMethod("setDistance", <String, dynamic>{'dist': dist});
        });
        break;
      case 'Clear All':
        showDialog(
            context: context,
            builder: (context) {
              return Material(
                  color: Colors.transparent,
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Are You sure?"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                      child: Text("YES"),
                                      onPressed: () => Navigator.pop(context, true)),
                                  TextButton(
                                      child: Text("NO"),
                                      onPressed: () => Navigator.pop(context, false)),
                                ],
                              )
                            ],
                          ))));
            }).then((r) {
          if (r) {
            RFIDs.clear();
            Local.update(RFIDs);
            setState(() {});
          }
        });
        break;
      case 'Send':
        Local.export(RFIDs).then((e) {
          setState(() {});
        });
        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    stream.receiveBroadcastStream().listen((event) {
      addReadData(event);
    });
    channel.invokeListMethod("init").then((value) => channel.invokeListMethod("start"));
    Local.load().then((value) {
      RFIDs = Map.from(value);
      setState(() {});
      channel.setMethodCallHandler((call) {
        if (call.method == 'addReadData') {
          addReadData(call.arguments);
        }
        return Future(() => null);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: handleOptions,
            itemBuilder: (BuildContext context) {
              return {'Stop', 'Setup', 'Clear All', 'Send'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
        backgroundColor: const Color(0xFF00FFC3),
        elevation: 4,
        title: Text(widget.title),
      ),
      body: Align(
          alignment: Alignment.center,
          child: ListView.builder(
              itemCount: RFIDs.keys.length,
              itemBuilder: (context, index) {
                var title = RFIDs.keys.toList()[index];
                return RFIDCards(title: title, rfids: RFIDs[title]!);
              })),
    );
  }
}

class SliderModal extends StatefulWidget {
  SliderModal({super.key, required this.dist});
  double dist;
  @override
  State<SliderModal> createState() => _MySliderModalState();
}

class _MySliderModalState extends State<SliderModal> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Align(
            alignment: Alignment.center,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Set Distance"),
                    Slider(
                        value: widget.dist,
                        min: 5,
                        max: 30,
                        divisions: 30,
                        label: widget.dist.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            widget.dist = value;
                          });
                        }),
                    TextButton(
                        child: Text("Ok"), onPressed: () => Navigator.pop(context, widget.dist))
                  ],
                ))));
  }
}
