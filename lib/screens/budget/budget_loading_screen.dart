import 'package:flutter/material.dart';
import 'budget_estimation_screen.dart';

/// Budget Loading Screen
class BudgetLoadingScreen extends StatefulWidget {
  const BudgetLoadingScreen({super.key});

  @override
  State<BudgetLoadingScreen> createState() => _BudgetLoadingScreenState();
}

class _BudgetLoadingScreenState extends State<BudgetLoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BudgetEstimationScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Card and coins icon
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(24)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.credit_card, size: 48, color: Colors.black54),
                  Positioned(bottom: 16, right: 16, child: Icon(Icons.monetization_on, size: 28, color: Colors.amber.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text('ESTIMATING BUDGET', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 40),
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Text('CALCULATING TRANSPORT & FEES...', style: TextStyle(fontFamily: 'RobotoMono', fontSize: 11, color: Colors.grey.shade600, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
