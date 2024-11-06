import 'package:flutter/material.dart';
import '../widgets/reward_item.dart';
import '../helpers/sqflite_helper.dart'; // Import your DatabaseHelper
import '../firebase_auth.dart'; // Import FirebaseAuthService

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  int _coinBalance = 0;

  @override
  void initState() {
    super.initState();
    _fetchCoinBalance();
  }

  // Fetch the user's current coin balance from the database
  Future<void> _fetchCoinBalance() async {
    final user = await _authService.getCurrentUser(); // Get the current user
    if (user != null) {
      final userId = user.uid; // Get the Firebase user ID
      final balance = await DatabaseHelper().getCurrency(userId);
      setState(() {
        _coinBalance = balance ?? 0; // Set balance or default to 0 if not found
      });
    }
  }

  // Deduct coins and update the balance
  Future<void> _redeemReward(String userId, int rewardCost) async {
    if (_coinBalance >= rewardCost) {
      final newBalance = _coinBalance - rewardCost;
      // Update the balance in the database
      await DatabaseHelper().updateCurrency(userId, newBalance);
      setState(() {
        _coinBalance = newBalance;
      });
      // Show a success message or perform some action
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Reward redeemed! New balance: $_coinBalance Coins'),
      ));
    } else {
      // Show an error message if the user doesn't have enough coins
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Not enough coins!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.gif_box, size: 24),
            SizedBox(width: 8),
            Text('Rewards Shop'),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Center the Row containing the icon and balance
            Center(
              child: Row(
                mainAxisSize: MainAxisSize
                    .min, // Makes the row only as wide as its content
                children: [
                  Icon(Icons.monetization_on,
                      size: 24, color: Colors.amber[600]),
                  SizedBox(width: 8),
                  Text('$_coinBalance Coins', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                children: [
                  RewardItem(
                    icon: Icons.gif_box_outlined,
                    title: '5% Off Coupon',
                    cost: '50 Coins',
                    onRedeem: () async {
                      final user = await _authService.getCurrentUser();
                      if (user != null) {
                        _redeemReward(user.uid, 50); // Deduct 50 coins
                      }
                    },
                  ),
                  RewardItem(
                    icon: Icons.local_offer_outlined,
                    title: 'Raffle Ticket',
                    cost: '100 Coins',
                    onRedeem: () async {
                      final user = await _authService.getCurrentUser();
                      if (user != null) {
                        _redeemReward(user.uid, 100); // Deduct 100 coins
                      }
                    },
                  ),
                  // Add more RewardItem widgets here as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
