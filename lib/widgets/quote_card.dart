import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wellbeing_mobile_app/theme/app_colors.dart';
// Assuming QuoteModel is in a models folder and accessible:
import '../models/quote_model.dart'; 

class QuoteCard extends StatelessWidget {
  final QuoteModel quoteData;

  const QuoteCard({super.key, required this.quoteData});

  @override
  Widget build(BuildContext context) {
    // Check for the loading state (using the internal flag in the model)
    if (quoteData.isLoading) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(Icons.psychology_outlined, size: 30, color: AppColors.textSubtle),
              SizedBox(width: 15),
              Text(
                'Finding today\'s inspiration...',
                style: TextStyle(fontSize: 18, color: AppColors.textSubtle),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.primaryColor, // Use a contrasting color for impact
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.quoteLeft,
                  size: 20,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  'Daily Inspiration',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white54, height: 20),
            // The Quote Text
            Text(
              quoteData.quote,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            // The Author
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— ${quoteData.author}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
