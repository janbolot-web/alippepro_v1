import 'package:flutter/material.dart';

class StoreItem extends StatelessWidget {
  final dynamic store; // Replace with the appropriate type for your store data
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddProduct;

  const StoreItem({
    super.key,
    required this.store,
    required this.onEdit,
    required this.onDelete,
    required this.onAddProduct,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Store logo
            Container(
              width: 60, // Set the width of the square
              height: 60, // Set the height of the square
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    12), // Border radius for rounded corners
                image: DecorationImage(
                  image: NetworkImage(store['logo'] ?? ''), // Assuming store has a 'logo' URL
                  fit: BoxFit.cover, // Makes the image cover the entire square
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Store details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['name'], // Store name
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    store['location'], // Store location
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Action buttons
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAddProduct,
            ),
          ],
        ),
      ),
    );
  }
}
