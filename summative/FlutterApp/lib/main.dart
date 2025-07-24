import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Education Prediction App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PredictionScreen(),
    );
  }
}

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final _primaryExpenditureController = TextEditingController();
  final _secondaryExpenditureController = TextEditingController();
  final _tertiaryExpenditureController = TextEditingController();
  final _primaryGdpController = TextEditingController();
  final _secondaryGdpController = TextEditingController();
  final _tertiaryGdpController = TextEditingController();
  final _yearController = TextEditingController();

  String _prediction = '';
  String _confidence = '';
  String _message = '';
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Set default values
    _yearController.text = '2023';
  }

  @override
  void dispose() {
    _primaryExpenditureController.dispose();
    _secondaryExpenditureController.dispose();
    _tertiaryExpenditureController.dispose();
    _primaryGdpController.dispose();
    _secondaryGdpController.dispose();
    _tertiaryGdpController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _makePrediction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _prediction = '';
      _confidence = '';
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://education-prediction-api.onrender.com/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'primary_expenditure_usd': double.parse(
            _primaryExpenditureController.text,
          ),
          'secondary_expenditure_usd': double.parse(
            _secondaryExpenditureController.text,
          ),
          'tertiary_expenditure_usd': double.parse(
            _tertiaryExpenditureController.text,
          ),
          'primary_expenditure_gdp': double.parse(_primaryGdpController.text),
          'secondary_expenditure_gdp': double.parse(
            _secondaryGdpController.text,
          ),
          'tertiary_expenditure_gdp': double.parse(_tertiaryGdpController.text),
          'year': int.parse(_yearController.text),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _prediction = data['prediction'].toString();
          _confidence = data['confidence'];
          _message = data['message'];
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Education Prediction Model'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.school, size: 48, color: Colors.blue[700]),
                          SizedBox(height: 8),
                          Text(
                            'School Life Expectancy Predictor',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Predict educational outcomes based on government expenditure',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Input Fields
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Government Expenditure (USD millions)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 12),

                          _buildTextField(
                            controller: _primaryExpenditureController,
                            label: 'Primary Education',
                            hint: 'e.g., 1000',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter primary education expenditure';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              double val = double.parse(value);
                              if (val < 0 || val > 100000) {
                                return 'Value must be between 0 and 100,000';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 8),

                          _buildTextField(
                            controller: _secondaryExpenditureController,
                            label: 'Secondary Education',
                            hint: 'e.g., 800',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter secondary education expenditure';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              double val = double.parse(value);
                              if (val < 0 || val > 100000) {
                                return 'Value must be between 0 and 100,000';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 8),

                          _buildTextField(
                            controller: _tertiaryExpenditureController,
                            label: 'Tertiary Education',
                            hint: 'e.g., 500',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter tertiary education expenditure';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              double val = double.parse(value);
                              if (val < 0 || val > 100000) {
                                return 'Value must be between 0 and 100,000';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expenditure as % of GDP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 12),

                          _buildTextField(
                            controller: _primaryGdpController,
                            label: 'Primary Education (%)',
                            hint: 'e.g., 2.0',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter primary education GDP %';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              double val = double.parse(value);
                              if (val < 0 || val > 20) {
                                return 'Value must be between 0 and 20';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 8),

                          _buildTextField(
                            controller: _secondaryGdpController,
                            label: 'Secondary Education (%)',
                            hint: 'e.g., 1.5',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter secondary education GDP %';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              double val = double.parse(value);
                              if (val < 0 || val > 20) {
                                return 'Value must be between 0 and 20';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 8),

                          _buildTextField(
                            controller: _tertiaryGdpController,
                            label: 'Tertiary Education (%)',
                            hint: 'e.g., 1.0',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter tertiary education GDP %';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              double val = double.parse(value);
                              if (val < 0 || val > 20) {
                                return 'Value must be between 0 and 20';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Year',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 12),

                          _buildTextField(
                            controller: _yearController,
                            label: 'Year',
                            hint: 'e.g., 2023',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a year';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid year';
                              }
                              int year = int.parse(value);
                              if (year < 2010 || year > 2030) {
                                return 'Year must be between 2010 and 2030';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Predict Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _makePrediction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Predicting...'),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Predict',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),

                  SizedBox(height: 20),

                  // Results
                  if (_prediction.isNotEmpty || _errorMessage.isNotEmpty)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_prediction.isNotEmpty) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.analytics,
                                    color: Colors.green[700],
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Prediction Results',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildResultRow(
                                'School Life Expectancy',
                                '$_prediction years',
                              ),
                              SizedBox(height: 8),
                              _buildResultRow('Confidence Level', _confidence),
                              SizedBox(height: 8),
                              _buildResultRow('Analysis', _message),
                            ] else if (_errorMessage.isNotEmpty) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Colors.red[700],
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Error',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
