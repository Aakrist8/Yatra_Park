import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  bool _isActiveTab = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _activeSessions = [];
  List<Map<String, dynamic>> _completedSessions = [];

  @override
  void initState() {
    super.initState();
    _fetchParkingSessions();
  }

  /// 🧠 Fetch real parking sessions from Supabase
  Future<void> _fetchParkingSessions() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await Supabase.instance.client
          .from('parking_sessions')
          .select()
          .eq('user_id', user.id)
          .order('entry_time', ascending: false);

      final List<Map<String, dynamic>> sessions = List<Map<String, dynamic>>.from(response);

      final active = <Map<String, dynamic>>[];
      final completed = <Map<String, dynamic>>[];

      for (var session in sessions) {
        final status = (session['status'] as String? ?? '').toLowerCase();
        if (status == 'active' || status == 'ongoing') {
          active.add(session);
        } else {
          completed.add(session);
        }
      }

      setState(() {
        _activeSessions = active;
        _completedSessions = completed;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error fetching parking sessions: $error');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 🧠 Convert Supabase UTC timestamp to Nepal Standard Time (UTC+5:45)
  DateTime _toNepalTime(String timestamp) {
    final utcTime = DateTime.parse(timestamp).toUtc();
    return utcTime.add(const Duration(hours: 5, minutes: 45));
  }

  /// 🧠 Dynamic calculation of fare based on total elapsed duration
  /// Base Rate: NPR 60 for 1st hour | NPR 30 for every additional hour or part thereof
  double _calculateDynamicFare(String? entryTimeString) {
    if (entryTimeString == null) return 0.0;

    final entryTimeUtc = DateTime.tryParse(entryTimeString)?.toUtc();
    if (entryTimeUtc == null) return 0.0;

    final nowUtc = DateTime.now().toUtc();
    final difference = nowUtc.difference(entryTimeUtc);

    if (difference.isNegative || difference.inMinutes == 0) return 60.0;

    // First hour rate
    double totalFare = 60.0;

    // Additional hours
    if (difference.inMinutes > 60) {
      int remainingMinutes = difference.inMinutes - 60;
      int additionalHours = (remainingMinutes / 60).ceil();
      totalFare += additionalHours * 30.0;
    }

    return totalFare;
  }

  /// 🧠 Calculate duration cleanly for both active (live) and completed sessions
  String _calculateDuration(Map<String, dynamic> item, bool isCompleted) {
    final entryString = item['entry_time'] as String?;
    if (entryString == null) return '00h : 00m';

    final entryTime = DateTime.tryParse(entryString)?.toUtc();
    if (entryTime == null) return '00h : 00m';

    DateTime endTime;
    if (isCompleted && item['exit_time'] != null) {
      endTime = DateTime.tryParse(item['exit_time'] as String)?.toUtc() ?? DateTime.now().toUtc();
    } else {
      endTime = DateTime.now().toUtc();
    }

    final difference = endTime.difference(entryTime);
    if (difference.isNegative) return '00h : 00m';

    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');

    return '${hours}h : ${minutes}m';
  }

  /// 🧠 Helper to format date in Nepal Standard Time (e.g. Jul 22, 2026 • 05:37 PM)
  String _formatNepalDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final nepaliTime = _toNepalTime(dateString);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(nepaliTime);
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color customBgColor = Color(0xFF161C2A);
    const Color cardBgColor = Color(0xFF1E2432);

    final currentList = _isActiveTab ? _activeSessions : _completedSessions;

    return Scaffold(
      backgroundColor: customBgColor,
      appBar: AppBar(
        backgroundColor: customBgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Booking History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // TOGGLE TRAY (Active / Completed)
            Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF212837),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  // ACTIVE TAB
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
                          'Active (${_activeSessions.length})',
                          style: TextStyle(
                            color: _isActiveTab ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // COMPLETED TAB
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
                          'Completed (${_completedSessions.length})',
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

            const SizedBox(height: 24),

            // MAIN LIST AREA
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
                  : RefreshIndicator(
                onRefresh: _fetchParkingSessions,
                child: currentList.isEmpty
                    ? Center(
                  child: Text(
                    _isActiveTab ? 'No Active Sessions' : 'No Completed Sessions',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: currentList.length,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    final item = currentList[index];
                    final isCompleted = !_isActiveTab;

                    // 🧠 Dynamic Fare Handling
                    String fareText;
                    if (isCompleted) {
                      final dbFare = item['current_fare'] ?? item['final_fare'] ?? item['amount'];
                      fareText = dbFare != null
                          ? 'NPR ${double.parse(dbFare.toString()).toStringAsFixed(2)}'
                          : 'NPR 0.00';
                    } else {
                      // Live dynamic rate for active sessions (including 200+ hours)
                      final liveFare = _calculateDynamicFare(item['entry_time']);
                      fareText = 'NPR ${liveFare.toStringAsFixed(2)}';
                    }

                    final vehicle = item['vehicle_plate'] ?? 'UNASSIGNED';
                    final dateText = _formatNepalDate(item['entry_time'] ?? item['created_at']);
                    final durationText = _calculateDuration(item, isCompleted);
                    final paymentMethod = (item['payment_method'] as String? ?? 'KHALTI').toUpperCase();
                    final isCash = paymentMethod == 'CASH';

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
                          // Date in Nepal Standard Time
                          Text(
                            dateText,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 10),

                          // Fee Row
                          Row(
                            children: [
                              const Text('Parking Fee: ', style: TextStyle(color: Colors.white, fontSize: 16)),
                              Text(
                                fareText,
                                style: const TextStyle(
                                  color: Color(0xFFE57C50),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Duration
                          Row(
                            children: [
                              const Text('Duration: ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Text(durationText, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Vehicle License Plate Badge
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
                                    Container(width: 3, height: 12, color: Colors.blue),
                                    const SizedBox(width: 6),
                                    Text(
                                      vehicle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: Colors.white10, height: 1),
                          ),

                          // Status line
                          Row(
                            children: [
                              const Text('Status: ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              Icon(
                                isCompleted ? Icons.check_circle : Icons.timer_outlined,
                                color: isCompleted ? Colors.green : Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isCompleted ? 'PAID' : 'PARKED',
                                style: TextStyle(
                                  color: isCompleted ? Colors.green : Colors.amber,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isCompleted) ...[
                                const SizedBox(width: 6),
                                const Text('•', style: TextStyle(color: Colors.grey)),
                                const SizedBox(width: 6),
                                if (!isCash) ...[
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.purple,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text(
                                      ' K ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  paymentMethod,
                                  style: TextStyle(
                                    color: isCash ? Colors.grey : Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}