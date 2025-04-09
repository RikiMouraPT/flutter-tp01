import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Base Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
      ),
      home: const MyHomePage(title: 'Base Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key, 
    required this.title
  });
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController fromController = TextEditingController();

  int fromBase = 0;
  int toBase = 10;
  String binResult = "0";
  String octResult = "0";
  String decResutl = "0";
  String hexResult = "0";

  void fromButton(String base) {
    setState(() {
      if (base == "Bin") {
        fromBase = 2;
      } else if (base == "Oct") {
        fromBase = 8;
      } else if (base == "Dec") {
        fromBase = 10;
      } else if (base == "Hex") {
        fromBase = 16;
      }
    });
  }

  void addInput(String input) {
    fromController.text += input;
    calculate(fromBase, toBase);
  }

  void calculate(int fromBase, int toBase) {
    if (formkey.currentState!.validate()) {
      var parsedInt = int.parse(fromController.text, radix: fromBase);
      setState(() {
        binResult = parsedInt.toRadixString(2).toUpperCase();
        octResult = parsedInt.toRadixString(8).toUpperCase();
        decResutl = parsedInt.toRadixString(10).toUpperCase();
        hexResult = parsedInt.toRadixString(16).toUpperCase();
      });
    }
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => fromButton("Bin"),
                  style: TextButton.styleFrom(
                    backgroundColor: fromBase == 2 ? Colors.lightGreen[100] : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    "Bin",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => fromButton("Oct"),
                  style: TextButton.styleFrom(
                    backgroundColor: fromBase == 8 ? Colors.lightGreen[100] : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    "Oct",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => fromButton("Dec"),
                  style: TextButton.styleFrom(
                    backgroundColor: fromBase == 10 ? Colors.lightGreen[100] : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    "Dec",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => fromButton("Hex"),
                  style: TextButton.styleFrom(
                    backgroundColor: fromBase == 16 ? Colors.lightGreen[100] : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    "Hex",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ],
            ),
            Form(
              key: formkey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50), 
                child: TextFormField(
                  enabled: false,
                  controller: fromController,
                  style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold
                        ),
                  decoration: InputDecoration(
                    label: Text("Number"),
                    suffix: Text(
                      fromBase == 2 ? "bin" 
                      : fromBase == 8 ? "oct" 
                      : fromBase == 10 ? "dec" 
                      : "hex"
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Missing Data";
                    }
                    var parsedInt = int.tryParse(value, radix: fromBase);
                    if (parsedInt == null) {
                      if (fromBase == 2) {
                        return "Enter valid binary values.";
                      } else if (fromBase == 8){
                        return "Enter valid octal values.";
                      }
                      else if (fromBase == 10) {
                        return "Enter valid decimal values.";
                      }
                      else if (fromBase == 16) {
                        return "Enter valid hexadecimal values.";
                      }
                      else {
                        return "Enter valid values.";
                      }
                    }
                    if (parsedInt < 0) {
                      return "Enter a value >= 0";
                    }

                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.only(left: 25),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Bin", 
                        style: TextStyle(
                          fontSize: 25,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      SizedBox(width: 10),
                      Text(
                        binResult,
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.green[900],
                          )
                        )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Oct", 
                        style: TextStyle(
                          fontSize: 25,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      SizedBox(width: 10),
                      Text(
                        octResult, 
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.green[900],
                          )
                        )
                    ],
                  ),	
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Dec", 
                        style: TextStyle(
                          fontSize: 25,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      SizedBox(width: 10),
                      Text(
                        decResutl, 
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.green[900],
                          )
                        )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Hex", 
                        style: TextStyle(
                          fontSize: 25,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      SizedBox(width: 10),
                      Text(
                        hexResult, 
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.green[900],
                          )
                        )
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => {
                    fromController.clear(),
                    setState(() {
                      binResult = "0";
                      octResult = "0";
                      decResutl = "0";
                      hexResult = "0";
                    })
                    }, 
                  child: Text(
                    "C", 
                    style: TextStyle(
                      fontSize: 45
                    )
                  )
                ),
                SizedBox(width: 15),
                TextButton(
                  onPressed: () => fromController.text = fromController.text.substring(0, fromController.text.length - 1),
                  child: Text(
                    "⌫", 
                    style: TextStyle(
                      fontSize: 45
                    )
                  )
                ),
                SizedBox(width: 40,)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => addInput("7") : null, 
                  child: Text(
                    "7",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 ? () => addInput("8") : null, 
                  child: Text(
                    "8",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  ),
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 ? () => addInput("9") : null, 
                  child: Text(
                    "9",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 ? () => addInput("F") : null,  
                  child: Text(
                    "F",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => addInput("4") : null, 
                  child: Text(
                    "4",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => addInput("5") : null, 
                  child: Text(
                    "5",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  ),
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => addInput("6") : null, 
                  child: Text(
                    "6",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 ? () => addInput("E") : null,  
                  child: Text(
                    "E",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 || fromBase == 2 ? () => addInput("1") : null, 
                  child: Text(
                    "1",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => addInput("2") : null, 
                  child: Text(
                    "2",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  ),
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => addInput("3") : null, 
                  child: Text(
                    "3",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 ? () => addInput("D") : null,  
                  child: Text(
                    "D",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 || fromBase == 2 ? () => addInput("0") : null, 
                  child: Text(
                    "0",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 ? () => addInput("A") : null, 
                  child: Text(
                    "A",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  ),
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 ? () => addInput("B") : null,
                  child: Text(
                    "B",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: fromBase == 16 ? () => addInput("C") : null, 
                  child: Text(
                    "C",
                    style: TextStyle(
                      fontSize: 45
                    ),
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
