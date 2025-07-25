import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'splash_screen.dart';
import 'results_screen.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final _primaryExpenditureController = TextEditingController();
  final _secondaryExpenditureController = TextEditingController();
  final _tertiaryExpenditureController = TextEditingController();
  final _primaryGdpController = TextEditingController();
  final _secondaryGdpController = TextEditingController();
  final _tertiaryGdpController = TextEditingController();
  final _yearController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              prediction: data['prediction'].toString(),
              confidence: data['confidence'],
              message: data['message'],
            ),
          ),
        );
      } else {
        _showErrorDialog('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Data'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SplashScreen()),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(Icons.input, size: 48, color: Colors.blue[700]),
                        SizedBox(height: 12),
                        Text(
                          'Enter Education Data',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Provide government expenditure data to predict school life expectancy',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Government Expenditure Section
                _buildSectionCard(
                  'Government Expenditure (USD millions)',
                  Icons.attach_money,
                  [
                    _buildTextField(
                      controller: _primaryExpenditureController,
                      label: 'Primary Education',
                      hint: 'e.g., 1000',
                      validator: (value) =>
                          _validateExpenditure(value, 'primary education'),
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _secondaryExpenditureController,
                      label: 'Secondary Education',
                      hint: 'e.g., 800',
                      validator: (value) =>
                          _validateExpenditure(value, 'secondary education'),
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _tertiaryExpenditureController,
                      label: 'Tertiary Education',
                      hint: 'e.g., 500',
                      validator: (value) =>
                          _validateExpenditure(value, 'tertiary education'),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // GDP Percentage Section
                _buildSectionCard('Expenditure as % of GDP', Icons.pie_chart, [
                  _buildTextField(
                    controller: _primaryGdpController,
                    label: 'Primary Education (%)',
                    hint: 'e.g., 2.0',
                    validator: (value) =>
                        _validateGdp(value, 'primary education'),
                  ),
                  SizedBox(height: 12),
                  _buildTextField(
                    controller: _secondaryGdpController,
                    label: 'Secondary Education (%)',
                    hint: 'e.g., 1.5',
                    validator: (value) =>
                        _validateGdp(value, 'secondary education'),
                  ),
                  SizedBox(height: 12),
                  _buildTextField(
                    controller: _tertiaryGdpController,
                    label: 'Tertiary Education (%)',
                    hint: 'e.g., 1.0',
                    validator: (value) =>
                        _validateGdp(value, 'tertiary education'),
                  ),
                ]),

                SizedBox(height: 16),

                // Year Section
                _buildSectionCard('Year', Icons.calendar_today, [
                  _buildTextField(
                    controller: _yearController,
                    label: 'Year',
                    hint: 'e.g., 2023',
                    validator: (value) => _validateYear(value),
                  ),
                ]),

                SizedBox(height: 32),

                // Predict Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _makePrediction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                              Text(
                                'Predicting...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.analytics,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Predict',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  String? _validateExpenditure(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName expenditure';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    double val = double.parse(value);
    if (val < 0 || val > 100000) {
      return 'Value must be between 0 and 100,000';
    }
    return null;
  }

  String? _validateGdp(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName GDP %';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    double val = double.parse(value);
    if (val < 0 || val > 20) {
      return 'Value must be between 0 and 20';
    }
    return null;
  }

  String? _validateYear(String? value) {
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
  }
}
