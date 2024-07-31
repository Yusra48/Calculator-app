import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expressions/expressions.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = "";
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadLastResult();
  }

  Future<void> _loadLastResult() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _result = _prefs?.getString('last_result') ?? "";
      _controller.text = _result;
    });
  }

  void _calculate() {
    String input = _controller.text;
    try {
      final result = _evaluateExpression(input);
      setState(() {
        _result = result.toString();
        _controller.text = _result;
      });
      _saveLastResult(_result);
    } catch (e) {
      setState(() {
        _result = "Error";
      });
    }
  }

  double _evaluateExpression(String expression) {
    expression = expression.replaceAll(' ', '');
    final exp = Expression.parse(expression);
    final evaluator = const ExpressionEvaluator();
    final result = evaluator.eval(exp, {});
    
    return result.toDouble();
  }

  Future<void> _saveLastResult(String result) async {
    if (_prefs != null) {
      await _prefs?.setString('last_result', result);
    }
  }

  void _appendOperator(String operator) {
    setState(() {
      _controller.text += operator;
    });
  }

  void _appendNumber(String number) {
    setState(() {
      _controller.text += number;
    });
  }

  void _clearInput() {
    setState(() {
      _controller.text = "";
      _result = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Calculator',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: 'Enter expression',
                labelStyle: TextStyle(
                  color: Colors.black,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (value) => _calculate(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _calculate,
              child: Text(
                'Calculate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Result: $_result',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeypadButton('1'),
            _buildKeypadButton('2'),
            _buildKeypadButton('3'),
            _buildKeypadButton('+'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeypadButton('4'),
            _buildKeypadButton('5'),
            _buildKeypadButton('6'),
            _buildKeypadButton('-'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeypadButton('7'),
            _buildKeypadButton('8'),
            _buildKeypadButton('9'),
            _buildKeypadButton('*'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeypadButton('C'),
            _buildKeypadButton('0'),
            _buildKeypadButton('.'),
            _buildKeypadButton('/'),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String text) {
    return ElevatedButton(
      onPressed: () {
        if (text == 'C') {
          _clearInput();
        } else if (text == '.' ||
            text == '+' ||
            text == '-' ||
            text == '*' ||
            text == '/') {
          _appendOperator(text);
        } else {
          _appendNumber(text);
        }
      },
      child: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(60, 60),
        backgroundColor: Colors.grey[900],
        textStyle: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
