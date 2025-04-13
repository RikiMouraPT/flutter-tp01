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

  /// This function is called when the user presses a button to select the base.
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

  /// This function is called when the user presses a button to enter a number.
  void buttonPressed(String input) {
    fromController.text += input;
    calculate(fromBase, toBase);
  }

  /// This function is called to calculate the result based on the selected base.
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

  bool waitingForSecondOperand = false;
  String selectedOperation = "";
  int firstOperand = 0;
  
  /// This function is called when the user presses an operation button.
  void operationPressed(String op) {
    if (formkey.currentState!.validate()) {
      setState(() {
        selectedOperation = op;
        firstOperand = int.parse(fromController.text, radix: fromBase);
        fromController.clear();
        waitingForSecondOperand = true;
      });
    }
  }

  /// This function is called to evaluate the result based on the selected operation.
  void evaluate() {
    if (formkey.currentState!.validate() && selectedOperation != "" && waitingForSecondOperand) {
      int secondOperand = int.parse(fromController.text, radix: fromBase);
      int result = 0;

      switch (selectedOperation) {
        case '+':
          result = firstOperand + secondOperand;
          break;
        case '-':
          result = firstOperand - secondOperand;
          break;
        case 'X':
          result = firstOperand * secondOperand;
          break;
        case '÷':
          if (secondOperand != 0) {
            result = firstOperand ~/ secondOperand;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Erro: Divisão por zero"),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.red,
              )
            );
            return;
          }
          break;
      }

      fromController.text = result.toRadixString(fromBase).toUpperCase();
      calculate(fromBase, toBase);

      setState(() {
        selectedOperation = "";
        firstOperand = 0;
        waitingForSecondOperand = false;
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
            SizedBox(height: 50,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: fromBase == 16 ? () => buttonPressed("A") : null, 
                  child: Text(
                    "A",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("🚀🔥🔥🔥🔥🚀 VIVA AO HÉLDER 🚀🔥🔥🔥🔥🚀"),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Text(
                    " ",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  ),
                ),
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
                    "CE", 
                    style: TextStyle(
                      fontSize: 35
                    )
                  )
                ),
                TextButton(
                  onPressed: () => fromController.text = fromController.text.substring(0, fromController.text.length - 1),
                  child: Text(
                    "⌫", 
                    style: TextStyle(
                      fontSize: 35
                    )
                  )
                ),
                TextButton(
                  onPressed: () => operationPressed("+"), 
                  child: Text(
                    "+",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: fromBase == 16 ? () => buttonPressed("B") : null,
                  child: Text(
                    "B",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => buttonPressed("7") : null, 
                  child: Text(
                    "7",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 ? () => buttonPressed("8") : null, 
                  child: Text(
                    "8",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  ),
                ),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 ? () => buttonPressed("9") : null, 
                  child: Text(
                    "9",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
                TextButton(
                  onPressed: () => operationPressed("-"),
                  child: Text(
                    "-",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: fromBase == 16 ? () => buttonPressed("C") : null, 
                  child: Text(
                    "C",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => buttonPressed("4") : null, 
                  child: Text(
                    "4",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => buttonPressed("5") : null, 
                  child: Text(
                    "5",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  ),
                ),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => buttonPressed("6") : null, 
                  child: Text(
                    "6",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
                TextButton(
                  onPressed: () => operationPressed("X"), 
                  child: Text(
                    "X",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: fromBase == 16 ? () => buttonPressed("D") : null,  
                  child: Text(
                    "D",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 || fromBase == 2 ? () => buttonPressed("1") : null, 
                  child: Text(
                    "1",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => buttonPressed("2") : null, 
                  child: Text(
                    "2",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  ),
                ),
                TextButton(
                  onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 ? () => buttonPressed("3") : null, 
                  child: Text(
                    "3",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
                TextButton(
                  onPressed: () => operationPressed("÷"),
                  child: Text(
                    "÷",
                    style: TextStyle(
                      fontSize: 35
                    ),
                  )
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 4,),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: fromBase == 16 ? () => buttonPressed("E") : null,
                    child: Text("E", style: TextStyle(fontSize: 35)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: fromBase == 16 ? () => buttonPressed("F") : null,
                    child: Text("F", style: TextStyle(fontSize: 35)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: fromBase == 16 || fromBase == 10 || fromBase == 8 || fromBase == 2
                        ? () => buttonPressed("0")
                        : null,
                    child: Text("0", style: TextStyle(fontSize: 35)),
                  ),
                ),
                Expanded(
                  flex: 2, // ocupa o espaço de dois botões
                  child: TextButton(
                    onPressed: () => evaluate(),
                    child: Text(
                      "=",
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
