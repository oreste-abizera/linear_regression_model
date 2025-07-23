import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: PredictionScreen());
  }
}

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _urbanController = TextEditingController();
  final _poorestController = TextEditingController();
  String _prediction = '';

  Future<void> _makePrediction() async {
    try {
      final response = await http.post(
        Uri.parse('https://your-api.onrender.com/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'urban_attendance': double.parse(_urbanController.text),
          'poorest_quintile_attendance': double.parse(_poorestController.text),
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          _prediction = jsonDecode(response.body)['prediction'].toString();
        });
      } else {
        setState(() {
          _prediction = 'Error: Failed to get prediction';
        });
      }
    } catch (e) {
      setState(() {
        _prediction = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rural Attendance Predictor')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urbanController,
              decoration: InputDecoration(
                labelText: 'Urban Attendance Rate (%)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _poorestController,
              decoration: InputDecoration(
                labelText: 'Poorest Quintile Attendance Rate (%)',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _makePrediction, child: Text('Predict')),
            SizedBox(height: 20),
            Text(
              _prediction.isEmpty
                  ? 'Enter values to predict'
                  : 'Prediction: $_prediction%',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
