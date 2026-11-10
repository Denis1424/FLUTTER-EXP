import 'package:flutter/material.dart';

void main() {
  runApp(const MileageCalculatorApp());
}

class MileageCalculatorApp extends StatelessWidget {
  const MileageCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Mileage Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MileageCalculatorScreen(),
    );
  }
}

class MileageCalculatorScreen extends StatefulWidget {
  const MileageCalculatorScreen({super.key});

  @override
  State<MileageCalculatorScreen> createState() => _MileageCalculatorScreenState();
}

class _MileageCalculatorScreenState extends State<MileageCalculatorScreen> {
  // Global form key for stateful form validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _fuelController = TextEditingController();
  final TextEditingController _fuelPriceController = TextEditingController();

  String _fuelType = 'Petrol';
  String _distanceUnit = 'km'; // km or miles

  // Calculation results
  double? _calculatedMileage;
  double? _costPerUnit;
  double? _totalTripCost;
  String? _efficiencyRating;
  Color? _efficiencyColor;

  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'CNG', 'Hybrid'];

  @override
  void dispose() {
    _distanceController.dispose();
    _fuelController.dispose();
    _fuelPriceController.dispose();
    super.dispose();
  }

  void _calculateMileage() {
    if (_formKey.currentState!.validate()) {
      final double distance = double.parse(_distanceController.text.trim());
      final double fuel = double.parse(_fuelController.text.trim());
      final double? fuelPrice = _fuelPriceController.text.isNotEmpty
          ? double.tryParse(_fuelPriceController.text.trim())
          : null;

      final double mileage = distance / fuel;
      double? costPerDistance;
      double? tripCost;

      if (fuelPrice != null) {
        tripCost = fuel * fuelPrice;
        costPerDistance = tripCost / distance;
      }

      // Determine efficiency category
      String rating;
      Color ratingColor;

      if (_distanceUnit == 'km') {
        if (mileage >= 20.0) {
          rating = 'Excellent Efficiency 🌟';
          ratingColor = Colors.green;
        } else if (mileage >= 14.0) {
          rating = 'Good Mileage 👍';
          ratingColor = Colors.blue;
        } else if (mileage >= 9.0) {
          rating = 'Average Efficiency ⚠️';
          ratingColor = Colors.orange;
        } else {
          rating = 'High Consumption 🛑';
          ratingColor = Colors.red;
        }
      } else {
        // Miles per gallon (mpg approx)
        if (mileage >= 45.0) {
          rating = 'Excellent Efficiency 🌟';
          ratingColor = Colors.green;
        } else if (mileage >= 30.0) {
          rating = 'Good Mileage 👍';
          ratingColor = Colors.blue;
        } else {
          rating = 'Average Efficiency ⚠️';
          ratingColor = Colors.orange;
        }
      }

      setState(() {
        _calculatedMileage = mileage;
        _costPerUnit = costPerDistance;
        _totalTripCost = tripCost;
        _efficiencyRating = rating;
        _efficiencyColor = ratingColor;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _distanceController.clear();
    _fuelController.clear();
    _fuelPriceController.clear();
    setState(() {
      _fuelType = 'Petrol';
      _distanceUnit = 'km';
      _calculatedMileage = null;
      _costPerUnit = null;
      _totalTripCost = null;
      _efficiencyRating = null;
      _efficiencyColor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String unitLabel = _distanceUnit == 'km' ? 'km/L' : 'MPG';

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.directions_car, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text('Car Mileage Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.blue.shade50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trip & Fuel Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Unit & Fuel Type Selection Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _fuelType,
                              decoration: const InputDecoration(
                                labelText: 'Fuel Type',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.local_gas_station),
                              ),
                              items: _fuelTypes.map((type) {
                                return DropdownMenuItem(value: type, child: Text(type));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _fuelType = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _distanceUnit,
                              decoration: const InputDecoration(
                                labelText: 'Distance Unit',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.speed),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'km', child: Text('Kilometers (km)')),
                                DropdownMenuItem(value: 'miles', child: Text('Miles (mi)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _distanceUnit = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Distance TextFormField with validation
                      TextFormField(
                        controller: _distanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Distance Travelled (${_distanceUnit})',
                          hintText: 'e.g. 350.5',
                          prefixIcon: const Icon(Icons.add_road),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the distance travelled';
                          }
                          final num? parsed = double.tryParse(value.trim());
                          if (parsed == null) {
                            return 'Please enter a valid numeric value';
                          }
                          if (parsed <= 0) {
                            return 'Distance must be strictly greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Fuel Consumed TextFormField with validation
                      TextFormField(
                        controller: _fuelController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Fuel Consumed (${_distanceUnit == 'km' ? 'Liters' : 'Gallons'})',
                          hintText: 'e.g. 20.0',
                          prefixIcon: const Icon(Icons.opacity),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter fuel consumed';
                          }
                          final num? parsed = double.tryParse(value.trim());
                          if (parsed == null) {
                            return 'Please enter a valid numeric value';
                          }
                          if (parsed <= 0) {
                            return 'Fuel consumed must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Fuel Price TextFormField (Optional)
                      TextFormField(
                        controller: _fuelPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Fuel Price per unit (Optional)',
                          hintText: 'e.g. 102.50',
                          prefixIcon: const Icon(Icons.currency_rupee),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final num? parsed = double.tryParse(value.trim());
                            if (parsed == null || parsed < 0) {
                              return 'Please enter a valid positive price';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _calculateMileage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.calculate),
                              label: const Text('Calculate Mileage', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _resetForm,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dynamic Result Display Card
            if (_calculatedMileage != null)
              Card(
                elevation: 4,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified, color: Colors.blue, size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            'Calculated Mileage',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Big Mileage Value
                      Text(
                        '${_calculatedMileage!.toStringAsFixed(2)} $unitLabel',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _efficiencyColor!.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _efficiencyColor!),
                        ),
                        child: Text(
                          _efficiencyRating!,
                          style: TextStyle(
                            color: _efficiencyColor!,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Divider(height: 30),

                      // Additional Statistics
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(
                            title: 'Fuel Type',
                            value: _fuelType,
                            icon: Icons.local_gas_station,
                          ),
                          if (_costPerUnit != null)
                            _StatColumn(
                              title: 'Cost / $_distanceUnit',
                              value: '₹${_costPerUnit!.toStringAsFixed(2)}',
                              icon: Icons.price_check,
                            ),
                          if (_totalTripCost != null)
                            _StatColumn(
                              title: 'Total Trip Cost',
                              value: '₹${_totalTripCost!.toStringAsFixed(0)}',
                              icon: Icons.account_balance_wallet,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatColumn({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
