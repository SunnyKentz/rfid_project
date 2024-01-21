import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter RFID Read'),
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
  static const readChannel = MethodChannel("com.example.rfid_counter/read");
  int _counter = 0;

  Future<List<String>?> getReading() async {
    await Future.delayed(Duration(seconds: 5));
    return readChannel.invokeListMethod("read");
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readChannel.invokeListMethod("init");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'your readings',
            ),
            FutureBuilder(
                future: getReading(),
                builder: (context, s) {
                  if (s.hasData) {
                    return Expanded(
                        child: ListView.builder(
                            itemCount: s.data!.length,
                            itemBuilder: (context, index) {
                              return Text(s.data![index]);
                            }));
                  }
                  return const Text("waiting for data press on the trigger");
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getReading,
        tooltip: 'scan',
        child: const Icon(Icons.swap_vertical_circle_rounded),
      ),
    );
  }
}
