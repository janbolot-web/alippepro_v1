import 'package:alippepro_v1/features/market/view/catalogDetail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryItem extends StatefulWidget {
  final String id;
  final String title;
  final String imagePath;

  const CategoryItem({
    super.key,
    required this.id,
    required this.title,
    required this.imagePath,
  });

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CatalogDetailScreen(
                  title: widget.title,
                      id: widget.id,
                    )));
      },
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: NetworkImage(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: GoogleFonts.rubik(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xff1B434D)),
          ),
        ],
      ),
    );
  }
}
