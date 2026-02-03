import 'package:flutter/material.dart';
import '../../widgets/buttons/buttons.dart';
import '../home/home_screen.dart';

/// Budget Estimation Screen - Full budget breakdown
class BudgetEstimationScreen extends StatelessWidget {
  const BudgetEstimationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Budget Summary',
                style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            Text('Kyoto, Japan',
                style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 12,
                    color: Colors.grey.shade600)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text('TOTAL ESTIMATED',
                      style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          letterSpacing: 1)),
                  const SizedBox(height: 8),
                  const Text('\$2,450',
                      style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 36,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text('WITHIN BUDGET',
                              style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green.shade800))),
                      const SizedBox(width: 8),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Text('7 DAYS',
                              style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Daily breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('EXPENDITURE BREAKDOWN',
                    style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                TextButton(
                    onPressed: () {},
                    child: const Text('EXPORT CSV',
                        style:
                            TextStyle(fontFamily: 'RobotoMono', fontSize: 11))),
              ],
            ),
            const SizedBox(height: 12),
            _buildDayBreakdown(
                'Day 1', 'Oct 12 • Arrival & Check-In', '\$1,170', [
              _ExpenseItem(Icons.flight, 'Flight to KIX (JAL 402)', '\$650'),
              _ExpenseItem(Icons.hotel, 'Gion Hatanaka (Deposit)', '\$400'),
              _ExpenseItem(Icons.restaurant, 'Welcome Dinner', '\$120'),
            ]),
            _buildDayBreakdown('Day 2', 'Oct 13 • Culture & Food', '\$105', [
              _ExpenseItem(
                  Icons.temple_buddhist, 'Fushimi Inari Donation', '\$10'),
              _ExpenseItem(Icons.restaurant, 'Nishiki Market Lunch', '\$35'),
              _ExpenseItem(Icons.emoji_food_beverage, 'Tea Ceremony', '\$45'),
              _ExpenseItem(Icons.train, 'Local Transport', '\$15'),
            ]),
            _buildDayBreakdown('Day 3', 'Oct 14 • Arashiyama', '\$240', [
              _ExpenseItem(Icons.forest, 'Bamboo Grove', 'FREE'),
              _ExpenseItem(Icons.rowing, 'River Boat Ride', '\$60'),
              _ExpenseItem(Icons.restaurant, 'Kaiseki Dinner', '\$180'),
            ]),
            const SizedBox(height: 24),
            // Saving tips
            const Text('SAVING TIPS',
                style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.auto_awesome,
                        size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text('ITINERA RECOMMENDATIONS',
                        style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700))
                  ]),
                  const SizedBox(height: 12),
                  _buildTip('1',
                      'Use the JR Pass for inter-city travel to save approx 20% on bullet trains.'),
                  _buildTip('2',
                      'Book the Gion Ryokan early to save 15% on accommodation.'),
                  _buildTip('3',
                      'Get a daily bus pass in Kyoto for unlimited rides at \$5/day.'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: PrimaryButton(
            text: 'DONE',
            icon: Icons.check,
            showArrow: false,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayBreakdown(
      String day, String subtitle, String total, List<_ExpenseItem> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(day,
                    style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 11,
                        color: Colors.grey.shade600))
              ]),
              Text(total,
                  style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Icon(item.icon, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(item.label,
                          style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 13,
                              color: Colors.grey.shade700))),
                  Text(item.amount,
                      style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 13,
                          color: Colors.grey.shade700))
                ]),
              )),
        ],
      ),
    );
  }

  Widget _buildTip(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(number,
                      style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700)))),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      color: Colors.blue.shade800,
                      height: 1.4))),
        ],
      ),
    );
  }
}

class _ExpenseItem {
  final IconData icon;
  final String label;
  final String amount;
  _ExpenseItem(this.icon, this.label, this.amount);
}
