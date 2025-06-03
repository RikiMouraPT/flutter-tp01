import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;

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
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController fromController = TextEditingController();

  int fromBase = 0;
  int toBase = 10;
  String binResult = "0";
  String octResult = "0";
  String decResutl = "0";
  String hexResult = "0";

  int binButtonKey = 0;
  int octButtonKey = 0;
  int decButtonKey = 0;
  int hexButtonKey = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the query history
    queryHistory();
  }

  // Database Methods
  List<Map<String, dynamic>> rows = [];

  void insertHistory(
    String firstOperand,
    String secondOperand,
    String operator,
    String result,
  ) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnFirstOperand: firstOperand,
      DatabaseHelper.columnSecondOperand: secondOperand,
      DatabaseHelper.columnOperator: operator,
      DatabaseHelper.columnResult: result,
    };
    await dbHelper.insert(row);
    queryHistory();
  }

  Future<void> queryHistory() async {
    final allRows = await dbHelper.queryAllRows();
    setState(() {
      rows = allRows;
    });
  }

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
    if (formkey.currentState!.validate() &&
        selectedOperation != "" &&
        waitingForSecondOperand) {
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
              ),
            );
            return;
          }
          break;
      }
      // Insert the operation into the history
      String firstOperandStr =
          firstOperand.toRadixString(fromBase).toUpperCase();
      String secondOperandStr =
          secondOperand.toRadixString(fromBase).toUpperCase();
      String resultStr = result.toRadixString(fromBase).toUpperCase();

      insertHistory(
        firstOperandStr,
        secondOperandStr,
        selectedOperation,
        resultStr,
      );

      fromController.text = result.toRadixString(fromBase).toUpperCase();
      calculate(fromBase, toBase);

      setState(() {
        selectedOperation = "";
        firstOperand = 0;
        waitingForSecondOperand = false;
      });
    }
  }

  /// Builds the ListView to display the history of operations.
  Widget buildListView() {
    if (rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.lightGreen[100],
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              "${row[DatabaseHelper.columnFirstOperand]} "
              "${row[DatabaseHelper.columnOperator]} "
              "${row[DatabaseHelper.columnSecondOperand]} = "
              "${row[DatabaseHelper.columnResult]}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red[400]),
              onPressed: () async {
                await dbHelper.delete(row[DatabaseHelper.columnId]);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("History entry deleted")),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 25,
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.bold,
    );

    final resultStyle = TextStyle(fontSize: 25, color: Colors.green[900]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              queryHistory();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("History"),
                    content: SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child: buildListView(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                      child: child,
                    );
                  },
                  child: TextButton(
                    key: ValueKey<int>(binButtonKey),
                    onPressed: () {
                      setState(() {
                        binButtonKey++;
                        fromButton("Bin");
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: fromBase == 2
                          ? Colors.lightGreen[100]
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text("Bin", style: TextStyle(fontSize: 25)),
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                      child: child,
                    );
                  },
                  child: TextButton(
                    key: ValueKey<int>(octButtonKey),
                    onPressed: () {
                      setState(() {
                        octButtonKey++;
                        fromButton("Oct");
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: fromBase == 8
                          ? Colors.lightGreen[100]
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text("Oct", style: TextStyle(fontSize: 25)),
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                      child: child,
                    );
                  },
                  child: TextButton(
                    key: ValueKey<int>(decButtonKey),
                    onPressed: () {
                      setState(() {
                        decButtonKey++;
                        fromButton("Dec");
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: fromBase == 10
                          ? Colors.lightGreen[100]
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text("Dec", style: TextStyle(fontSize: 25)),
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                      child: child,
                    );
                  },
                  child: TextButton(
                    key: ValueKey<int>(hexButtonKey),
                    onPressed: () {
                      setState(() {
                        hexButtonKey++;
                        fromButton("Hex");
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: fromBase == 16
                          ? Colors.lightGreen[100]
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text("Hex", style: TextStyle(fontSize: 25)),
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
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    label: Text("Number"),
                    suffix: Text(
                      fromBase == 2
                          ? "bin"
                          : fromBase == 8
                          ? "oct"
                          : fromBase == 10
                          ? "dec"
                          : "hex",
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
                      } else if (fromBase == 8) {
                        return "Enter valid octal values.";
                      } else if (fromBase == 10) {
                        return "Enter valid decimal values.";
                      } else if (fromBase == 16) {
                        return "Enter valid hexadecimal values.";
                      } else {
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
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(left: 25),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Bin", style: titleStyle),
                      SizedBox(width: 10),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          binResult,
                          key: ValueKey(binResult),
                          style: resultStyle,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text("Oct", style: titleStyle),
                      SizedBox(width: 10),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          octResult,
                          key: ValueKey(octResult),
                          style: resultStyle,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text("Dec", style: titleStyle),
                      SizedBox(width: 10),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          decResutl,
                          key: ValueKey(decResutl),
                          style: resultStyle,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text("Hex", style: titleStyle),
                      SizedBox(width: 10),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Text(
                          hexResult,
                          key: ValueKey(hexResult),
                          style: resultStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: fromBase == 16 ? () => buttonPressed("A") : null,
                  child: Text("A", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed: null,
                  child: Text(" ", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed:
                      () => {
                        fromController.clear(),
                        setState(() {
                          binResult = "0";
                          octResult = "0";
                          decResutl = "0";
                          hexResult = "0";
                        }),
                      },
                  child: Text("CE", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed:
                      () =>
                          fromController.text = fromController.text.substring(
                            0,
                            fromController.text.length - 1,
                          ),
                  child: Text("⌫", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed: () => operationPressed("+"),
                  child: Text("+", style: TextStyle(fontSize: 35)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: fromBase == 16 ? () => buttonPressed("B") : null,
                  child: Text("B", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed:
                      fromBase == 16 || fromBase == 10 || fromBase == 8
                          ? () => buttonPressed("7")
                          : null,
                  child: Text("7", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed:
                      fromBase == 16 || fromBase == 10
                          ? () => buttonPressed("8")
                          : null,
                  child: Text("8", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed:
                      fromBase == 16 || fromBase == 10
                          ? () => buttonPressed("9")
                          : null,
                  child: Text("9", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed: () => operationPressed("-"),
                  child: Text("-", style: TextStyle(fontSize: 35)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: fromBase == 16 ? () => buttonPressed("C") : null,
                  child: Text("C", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed:
                      fromBase == 16 || fromBase == 10 || fromBase == 8
                          ? () => buttonPressed("4")
                          : null,
                  child: Text("4", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed:
                      fromBase == 16 || fromBase == 10 || fromBase == 8
                          ? () => buttonPressed("5")
                          : null,
                  child: Text("5", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed:
                      fromBase == 16 || fromBase == 10 || fromBase == 8
                          ? () => buttonPressed("6")
                          : null,
                  child: Text("6", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed: () => operationPressed("X"),
                  child: Text("X", style: TextStyle(fontSize: 35)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: fromBase == 16 ? () => buttonPressed("D") : null,
                  child: Text("D", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed:
                      fromBase == 16 ||
                              fromBase == 10 ||
                              fromBase == 8 ||
                              fromBase == 2
                          ? () => buttonPressed("1")
                          : null,
                  child: Text("1", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed:
                      fromBase == 16 || fromBase == 10 || fromBase == 8
                          ? () => buttonPressed("2")
                          : null,
                  child: Text("2", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed:
                      fromBase == 16 || fromBase == 10 || fromBase == 8
                          ? () => buttonPressed("3")
                          : null,
                  child: Text("3", style: TextStyle(fontSize: 35)),
                ),
                TextButton(
                  onPressed: () => operationPressed("÷"),
                  child: Text("÷", style: TextStyle(fontSize: 35)),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 4),
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
                    onPressed:
                        fromBase == 16 ||
                                fromBase == 10 ||
                                fromBase == 8 ||
                                fromBase == 2
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
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
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
