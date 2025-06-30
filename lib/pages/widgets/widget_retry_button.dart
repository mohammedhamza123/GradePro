import 'package:flutter/material.dart';

class RetryButton extends StatelessWidget {
  final void Function()? onPress;
  final String? errorMessege;

  const RetryButton({super.key, this.onPress, this.errorMessege});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPress,
        child: Column(
          children: [
            Text("ERROR: $errorMessege"),
            const Text("إعادة المحاولة"),
          ],
        ),
      ),
    );
  }
}
