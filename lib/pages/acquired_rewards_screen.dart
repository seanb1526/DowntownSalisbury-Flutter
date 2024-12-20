import 'package:flutter/material.dart';
import '../helpers/sqflite_helper.dart';
import '../firebase_auth.dart';
import '../widgets/redeem_coupon_modal.dart';
import '../helpers/firestore_service.dart';

class UniversalRewardsScreen extends StatefulWidget {
  const UniversalRewardsScreen({super.key});

  @override
  _UniversalRewardsScreenState createState() => _UniversalRewardsScreenState();
}

class _UniversalRewardsScreenState extends State<UniversalRewardsScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _userRewards = [];

  @override
  void initState() {
    super.initState();
    _fetchUserRewards();
  }

  Future<void> _fetchUserRewards() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final coupons = await _dbHelper.getUserCoupons(user.uid);
      setState(() {
        _userRewards =
            List<Map<String, dynamic>>.from(coupons); // Ensure mutable list
      });
    }
  }

  String _formatDate(int millisecondsSinceEpoch) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return "${date.month}/${date.day}/${date.year}";
  }

  // Show modal with coupon details
  void _showRewardDetails(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (context) => RedeemCouponModal(
        reward: reward,
        onAccept: () async {
          try {
            // Step 1: Save the redeemed coupon to Firestore
            await FirestoreService().saveRedeemedCoupon(
              userId: reward['user_id'].toString(),
              type: reward['type'].toString(),
              discountPercentage:
                  int.parse(reward['discount_percentage'].toString()),
              purchaseDate: DateTime.fromMillisecondsSinceEpoch(
                  int.parse(reward['purchase_date'].toString())),
              expirationDate: DateTime.fromMillisecondsSinceEpoch(
                  int.parse(reward['expiration_date'].toString())),
              couponCode: reward['coupon_code'].toString(),
            );

            // Step 2: Delete the coupon from the SQLite database
            await _dbHelper.deleteCoupon(
                reward['user_id'].toString(), reward['coupon_code'].toString());

            // Step 3: Remove the coupon from the list immediately
            setState(() {
              _userRewards.removeWhere(
                  (r) => r['coupon_code'] == reward['coupon_code']);
            });

            // Step 4: Close the modal
            Navigator.of(context).pop();
          } catch (e) {
            // Handle errors (e.g., Firestore or SQLite write errors)
            print('Error accepting coupon: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to accept coupon. Please try again.')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Rewards'),
      ),
      body: _userRewards.isEmpty
          ? Center(child: Text('No active rewards'))
          : ListView.builder(
              itemCount: _userRewards.length,
              itemBuilder: (context, index) {
                final reward = _userRewards[index];
                return ListTile(
                  leading: Icon(
                    reward['type'].toString().contains('%')
                        ? Icons.local_offer
                        : Icons.confirmation_number,
                  ),
                  title: Text(reward['type']),
                  subtitle: Text(
                      'Expires: ${_formatDate(reward['expiration_date'])}'),
                  trailing: ElevatedButton(
                    onPressed: () => _showRewardDetails(reward),
                    child: Text('Redeem'),
                  ),
                );
              },
            ),
    );
  }
}
