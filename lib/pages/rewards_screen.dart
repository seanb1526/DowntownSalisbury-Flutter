import 'package:flutter/material.dart';
import '../widgets/reward_item.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

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
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          children: [
            RewardItem(
              icon: Icons.gif_box_outlined,
              title: '50% Off Coupon',
              cost: '500 Coins',
              onRedeem: () {},
            ),
            RewardItem(
              icon: Icons.local_offer_outlined,
              title: 'Raffle Ticket',
              cost: '100 Coins',
              onRedeem: () {},
            ),
          ],
        ),
      ),
    );
  }
}
