import 'package:flutter/material.dart';
import '../../models/meal.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/image_with_fallback.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  final bool showPopularBadge;
  final bool showChefBadge;

  const MealCard({
    required this.meal,
    required this.onTap,
    this.showPopularBadge = false,
    this.showChefBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ImageWithFallback(
                  imageUrl: meal.image,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                if (showPopularBadge)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: CustomBadge(
                      text: 'Popular',
                      backgroundColor: Colors.orange,
                      textColor: Colors.white,
                    ),
                  ),
                if (showChefBadge)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: CustomBadge(
                      text: 'Community Chef',
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CustomBadge(
                    text: meal.rating.toString(),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'by ${meal.chef}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    meal.description,
                    style: TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                      Text(' ${meal.nutrition.calories} cal'),
                      SizedBox(width: 12),
                      Icon(Icons.people, size: 14),
                      Text(' ${meal.portionSize}'),
                      SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14),
                      Text(' ${meal.prepTime}'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: [
                      ...meal.tags.take(2).map((tag) => CustomBadge(
                        text: tag,
                        size: 10,
                      )),
                      if (meal.isVegetarian)
                        CustomBadge(
                          text: 'Vegetarian',
                          size: 10,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${meal.price}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      CustomButton(
                        text: 'View Details',
                        size: ButtonSize.small,
                        onPressed: onTap,
                      ),
                    ],
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