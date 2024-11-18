import 'package:flutter/material.dart';
import '../helpers/sqflite_helper.dart';
import '../firebase_auth.dart';

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
      // TODO: Add method to fetch raffle entries when implemented
      setState(() {
        _userRewards = coupons;
      });
    }
  }

  String _formatDate(int millisecondsSinceEpoch) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return "${date.month}/${date.day}/${date.year}";
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
                    reward['type'].toString().contains('Coupon')
                        ? Icons.local_offer
                        : Icons.confirmation_number,
                  ),
                  title: Text(reward['type']),
                  subtitle: Text(
                      'Expires: ${_formatDate(reward['expiration_date'])}'),
                  trailing: ElevatedButton(
                    onPressed: () => _showRewardDetails(reward),
                    child: Text('View'),
                  ),
                );
              },
            ),
    );
  }

  void _showRewardDetails(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reward Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Type: ${reward['type']}'),
            if (reward['coupon_code'] != null)
              Text('Coupon Code: ${reward['coupon_code']}'),
            Text('Purchased: ${_formatDate(reward['purchase_date'])}'),
            Text('Expires: ${_formatDate(reward['expiration_date'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
