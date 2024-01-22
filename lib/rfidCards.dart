import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RFIDCards extends StatefulWidget {
  RFIDCards({super.key, required this.title, required this.rfids});
  List<Map> rfids;
  final String title;

  @override
  State<RFIDCards> createState() => _MyRFIDCardsState();
}

class _MyRFIDCardsState extends State<RFIDCards> {
  showMore() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return FractionallySizedBox(
              heightFactor: 1,
              child: Container(
                  margin: const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        itemCount: widget.rfids.length,
                        itemBuilder: (context, index) {
                          return Card(
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              color: const Color(0xFF00FFC3),
                              elevation: 5,
                              child: Padding(
                                  key: GlobalKey(),
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                                  child: Stack(
                                    children: [
                                      Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("EPC : ${widget.rfids[index]["EPC"]}",
                                                softWrap: true,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  color: Color(0xFF005E47),
                                                )),
                                            Text("Data : ${widget.rfids[index]["Data"]}",
                                                softWrap: true,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  color: Color(0xFF005E47),
                                                )),
                                            Text("Category : ${widget.rfids[index]["Category"]}",
                                                softWrap: true,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  color: Color(0xFF005E47),
                                                ))
                                          ]),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Text("$index"),
                                      )
                                    ],
                                  )));
                        },
                      ))));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
        child: MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Color(0xFF00FFC3),
            elevation: 5,
            onPressed: showMore,
            child: Padding(
                key: GlobalKey(),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            softWrap: true,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                color: Color(0xFF005E47),
                                overflow: TextOverflow.ellipsis,
                                fontSize: 30)),
                        const Text("RFID Tag",
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Color(0xFF009C77), fontSize: 25))
                      ]),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20), color: const Color(0x7AFFFFFF)),
                      padding: const EdgeInsets.all(20),
                      child: Text("${widget.rfids.length}",
                          style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 30)))
                ]))));
  }
}
