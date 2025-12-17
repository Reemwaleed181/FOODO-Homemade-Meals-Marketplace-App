import 'package:flutter/material.dart';

class PartnerApproach extends StatelessWidget {
  const PartnerApproach({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real Food, Real Chefs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Instead of fake seed data, consider these approaches:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildApproachItem(
            icon: Icons.restaurant,
            title: 'Partner with Local Restaurants',
            description: 'Work with existing restaurants to offer their meals through your app',
          ),
          
          _buildApproachItem(
            icon: Icons.people,
            title: 'Recruit Real Home Chefs',
            description: 'Find actual home cooks who want to sell their meals',
          ),
          
          _buildApproachItem(
            icon: Icons.work,
            title: 'Start with Your Own Kitchen',
            description: 'You cook and deliver meals initially to test the concept',
          ),
          
          _buildApproachItem(
            icon: Icons.event,
            title: 'Pop-up Events',
            description: 'Organize food events where chefs can showcase their meals',
          ),
        ],
      ),
    );
  }

  Widget _buildApproachItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.orange.shade600,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
