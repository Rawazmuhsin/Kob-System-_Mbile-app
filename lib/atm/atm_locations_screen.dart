// lib/atm/atm_locations_screen.dart
import 'package:flutter/material.dart';
import '../services/atm_service.dart';
import '../models/atm_location.dart';
import 'atm_qr_screen.dart';

class ATMLocationsScreen extends StatefulWidget {
  const ATMLocationsScreen({super.key});

  @override
  State<ATMLocationsScreen> createState() => _ATMLocationsScreenState();
}

class _ATMLocationsScreenState extends State<ATMLocationsScreen> {
  final ATMService _atmService = ATMService.instance;

  @override
  Widget build(BuildContext context) {
    final atmLocations = _atmService.getAllATMLocations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ATM Locations'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.atm, size: 48, color: Colors.blue[800]),
                  const SizedBox(height: 8),
                  Text(
                    'Select ATM Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose an ATM to generate your QR code',
                    style: TextStyle(fontSize: 14, color: Colors.blue[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: atmLocations.length,
                itemBuilder: (context, index) {
                  final atm = atmLocations[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.atm,
                          color: Colors.blue[800],
                          size: 32,
                        ),
                      ),
                      title: Text(
                        atm.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            atm.address,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color:
                                      atm.status == 'Online'
                                          ? Colors.green
                                          : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                atm.status,
                                style: TextStyle(
                                  color:
                                      atm.status == 'Online'
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing:
                          atm.status == 'Online'
                              ? Icon(
                                Icons.qr_code,
                                color: Colors.blue[800],
                                size: 32,
                              )
                              : Icon(
                                Icons.block,
                                color: Colors.grey[400],
                                size: 32,
                              ),
                      onTap:
                          atm.status == 'Online' ? () => _selectATM(atm) : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectATM(ATMLocation atm) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ATMQRScreen(atmLocation: atm)),
    );
  }
}
