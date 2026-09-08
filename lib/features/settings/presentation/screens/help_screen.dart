import 'package:flutter/material.dart';

/// Static content for now — revisit if you want a real FAQ or a
/// WhatsApp/call link to support instead.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Getting an order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text("Orders are assigned to you by the dispatch team. You'll see them appear on the Live tab."),
              SizedBox(height: 20),
              Text('Marking an order delivered', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('Open the order from the Live tab and tap Mark delivered once you have handed it to the customer.'),
              SizedBox(height: 20),
              Text('Need more help?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('Contact your dispatcher directly for now.'),
            ],
          ),
        ),
      ),
    );
  }
}
