import 'package:flutter/material.dart';
import '../helpers/sqflite_helper.dart';

class RedeemCouponModal extends StatelessWidget {
  final Map<String, dynamic> reward;
  final VoidCallback
      onAccept; // This callback will be triggered when Accept is pressed

  const RedeemCouponModal({
    required this.reward,
    required this.onAccept,
    super.key,
  });

  String _formatDate(int millisecondsSinceEpoch) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return "${date.month}/${date.day}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Coupon Details'),
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
          onPressed:
              onAccept, // Call the onAccept callback to delete and update the UI
          child: Text('ACCEPT'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(), // Close the modal without accepting
          child: Text('CLOSE'),
        ),
      ],
    );
  }
}
