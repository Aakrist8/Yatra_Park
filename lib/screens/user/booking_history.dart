import 'package:flutter/material.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  bool _isActiveTab = false;

  @override
  Widget build(BuildContext context) {
    const Color customBgColor = Color(0xFF161C2A); // Deep midnight blue
    const Color cardBgColor = Color(0xFF1E2432);   //  cards

    // Sample data list matching the text in your image mockup
    final List<Map<String, dynamic>> completedSessions = [
      {
        'date': 'May 29, 2026',
        'fee': 'NPR 120.00',
        'duration': '02h : 14m',
        'vehicle': 'BA 2 CH 1234',
        'method': 'KHALTI',
        'isCash': false,
      },
      {
        'date': 'May 29, 2026',
        'fee': 'NPR 120.00',
        'duration': '02h : 14m',
        'vehicle': 'BA 2 CH 1234',
        'method': 'KHALTI',
        'isCash': false,
      },
      {
        'date': 'May 29, 2026',
        'fee': 'NPR 120.00',
        'duration': '02h : 14m',
        'vehicle': 'BA 2 CH 1234',
        'method': 'KHALTI',
        'isCash': false,
      },
      {
        'date': 'May 29, 2026',
        'fee': 'NPR 120.00',
        'duration': '02h : 14m',
        'vehicle': 'BA 2 CH 1234',
        'method': 'KHALTI',
        'isCash': false,
      },
      {
        'date': 'May 28, 2026',
        'fee': 'NPR 75.00',
        'duration': '01h : 05m',
        'vehicle': 'BA 2 CH 1234',
        'method': 'CASH',
        'isCash': true,
      }
    ];


    return Scaffold(
      backgroundColor: customBgColor, // Sets the dark background color across the full screen

      // --- 1. THE TOP APP BAR ---
      appBar: AppBar(
        backgroundColor: customBgColor,
        elevation: 0, // Removes the shadow underneath the top app bar
        centerTitle: true, // Centers the title text horizontally
        title: const Text(
          'Booking History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      // --- 2. THE MAIN BODY CONTENT ---
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Adds side spacing
        child: Column(
          children: [
            const SizedBox(height: 10), // Small spacer line

            // --- TOGGLE TRAY (Active / Completed Pill) ---
            Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF212837), // Lighter background
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  // ACTIVE BUTTON TAB
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isActiveTab = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isActiveTab ? const Color(0xFF384358) : Colors.transparent,
                          borderRadius: BorderRadius.circular(21),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Active',
                          style: TextStyle(
                            color: _isActiveTab ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // COMPLETED BUTTON TAB
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isActiveTab = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isActiveTab ? const Color(0xFF384358) : Colors.transparent,
                          borderRadius: BorderRadius.circular(21),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            color: !_isActiveTab ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24), // Spacing below toggle tray

            // --- LIST OF HISTORY CARDS ---
            Expanded(
              child: _isActiveTab
                  ? const Center(
                child: Text('No Active Sessions', style: TextStyle(color: Colors.grey)),
              )
                  : ListView.builder(
                itemCount: completedSessions.length,
                physics: const BouncingScrollPhysics(), // Adds iOS styled scroll bounce mechanics
                itemBuilder: (context, index) {
                  final item = completedSessions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Text
                        Text(
                          item['date'],
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 10),

                        // Fee Row
                        Row(
                          children: [
                            const Text('Parking Fee: ', style: TextStyle(color: Colors.white, fontSize: 16)),
                            Text(
                              item['fee'],
                              style: const TextStyle(color: Color(0xFFE57C50), fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Duration Row
                        Row(
                          children: [
                            const Text('Duration: ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Text(item['duration'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Nepal Registration Style License Plate Box
                        Row(
                          children: [
                            const Text('Vehicle: ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3545),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue.shade700),
                              ),
                              child: Row(
                                children: [
                                  Container(width: 3, height: 12, color: Colors.blue), // Country side indicator bar
                                  const SizedBox(width: 6),
                                  Text(
                                    item['vehicle'],
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Colors.white10, height: 1), // Divider break line inside card
                        ),

                        // Bottom Status Line (PAID tag + payment type indicator)
                        Row(
                          children: [
                            const Text('Status: ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            const Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            const Text('PAID', style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            const Text('•', style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 6),

                            // Conditional logic: if it's not cash, print the mini purple Khalti badge circle
                            if (!item['isCash']) ...[
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                                child: const Text(' K ', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              item['method'],
                              style: TextStyle(
                                  color: item['isCash'] ? Colors.grey : Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ],
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
}