import 'package:flutter/material.dart';
import '../widgets/reward_item.dart';
import '../helpers/sqflite_helper.dart';
import '../firebase_auth.dart';
import '../helpers/firestore_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _coinBalance = 0;

  @override
  void initState() {
    super.initState();
    _fetchCoinBalance();
  }

  Future<void> _fetchCoinBalance() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final balance = await _dbHelper.getCurrency(user.uid);
      setState(() {
        _coinBalance = balance ?? 0;
      });
    }
  }

  Future<void> _redeemCoupon(String userId, int rewardCost, String type,
      int discountPercentage) async {
    if (_coinBalance >= rewardCost) {
      try {
        // Purchase coupon in database
        await _dbHelper.purchaseCoupon(userId, type, discountPercentage);

        // Deduct coins
        final newBalance = _coinBalance - rewardCost;
        await _dbHelper.updateCurrency(userId, newBalance);

        setState(() {
          _coinBalance = newBalance;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$type Coupon Purchased!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error purchasing coupon: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough coins!')),
      );
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _coinBalance);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                  mainAxisExtent: 180,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                children: [
                  RewardItem(
                    imagePath: 'assets/images/10percent_coupon.png',
                    title: '10% Off Coupon',
                    cost: '10 Coins',
                    onRedeem: () async {
                      final user = await _authService.getCurrentUser();
                      if (user != null) {
                        _redeemCoupon(user.uid, 10, '10% Off', 10);
                      }
                    },
                  ),
                  RewardItem(
                    imagePath: 'assets/images/15percent_coupon.png',
                    title: '15% Off Coupon',
                    cost: '75 Coins',
                    onRedeem: () async {
                      final user = await _authService.getCurrentUser();
                      if (user != null) {
                        _redeemCoupon(user.uid, 75, '15% Off', 15);
                      }
                    },
                  ),
                  RewardItem(
                    imagePath: 'assets/images/DT-Giftcard.png',
                    title: 'Raffle Entry',
                    cost: '10 Coins',
                    onRedeem: () async {
                      final user = await _authService.getCurrentUser();
                      if (user != null) {
                        if (_coinBalance >= 10) {
                          // Check if user has enough coins
                          try {
                            // Deduct coins
                            final newBalance = _coinBalance - 10;
                            await _dbHelper.updateCurrency(
                                user.uid, newBalance);

                            setState(() {
                              _coinBalance = newBalance;
                            });

                            // Add raffle entry to Firestore
                            await FirestoreService()
                                .addRaffleEntryToFirestore(user.uid);

                            // Safely handle null email, providing an empty string if it's null
                            final email = user.email ??
                                ''; // Default to an empty string if null

                            // Add raffle entry to the local SQLite table
                            await _dbHelper.purchaseRaffleEntry(
                                user.uid, email);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Raffle entry purchased!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error purchasing raffle entry: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Not enough coins!')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
