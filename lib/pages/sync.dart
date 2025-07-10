import 'package:grsfApp/global.dart';
import 'package:flutter/material.dart';

class UpdateDataScreen extends StatefulWidget {
  const UpdateDataScreen({super.key});

  @override
  State<UpdateDataScreen> createState() => _UpdateDataScreenState();
}

class _UpdateDataScreenState extends State<UpdateDataScreen> {
  bool _isLoading = false;
  String _statusMessage = "Press the button to update all data.";

  Future<void> _updateAllData() async {

    setState(() {
      _isLoading = true;
      _statusMessage = "Starting update...";
    });


    try {
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _statusMessage = "Updating all tables...";
      });

      await updateAllTables();

      setState(() {
        _statusMessage = "All data updated successfully!";
      });
    } catch (e) {
      print("Error in _updateAllData: $e");
      setState(() {
        _statusMessage = "Update failed: $e";
      });
    } finally {
      print("Setting loading to false");
      setState(() {
        _isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update All Tables'),
        backgroundColor: const Color(0xff16425B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home_filled),
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _updateAllData, //_updateAllTables,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff16425B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text("Update All Data"),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}
