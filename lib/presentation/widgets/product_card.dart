import 'package:flutter/material.dart';
import 'package:new_app/app/app_theme.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    super.key,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                    cacheWidth: 400,
                    cacheHeight: 500,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(Icons.checkroom, color: AppTheme.textSecondary, size: 36),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(() => _isFavorite = !_isFavorite),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 16,
                            color: _isFavorite ? const Color(0xFFEF4444) : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. ${(widget.product.price * 280).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                          SizedBox(width: 2),
                          Text('4.8', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
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