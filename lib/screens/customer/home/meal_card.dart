import 'package:flutter/material.dart';
import '../../../models/meal.dart';
import '../../../widgets/image_with_fallback.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  final bool compact;

  const MealCard({
    required this.meal,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildModernCompact(context);
    }
    return _buildModernCompact(context); // Default to compact mode
  }

  Widget _buildModernCompact(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          // Card container
          Container(
            height: 320,
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.fromLTRB(16, 86, 16, 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4E94AB), Color(0xFF3A7A8F)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600, 
                    color: Colors.white
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  'by ${meal.chef}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFCBD5E0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Calories display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${meal.nutrition.calories} cal',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  meal.description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFE2E8F0), // Lighter text for better contrast
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // Bottom section with price and arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${meal.price.toStringAsFixed(0)} USD',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600, 
                        color: Colors.white
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: onTap,
                        icon: const Icon(
                          Icons.arrow_forward_ios, 
                          size: 14, 
                          color: Color(0xFF4E94AB)
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Circular image overlapping the card
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 1,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: ImageWithFallback(
                  imageUrl: meal.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}