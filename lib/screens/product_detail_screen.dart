import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedVariant = '256GB';

  final List<String> _variants = ['128GB', '256GB', '512GB', '1TB'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Cellario Lite'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              final isFav = provider.isFavorite(widget.product.id);
              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                tween: Tween(begin: 1.0, end: isFav ? 1.2 : 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : null,
                      ),
                      onPressed: () {
                        provider.toggleFavorite(widget.product.id);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final orientation = MediaQuery.of(context).orientation;
          final isWide = constraints.maxWidth >= 800;
          
          final heroImage = Hero(
            tag: 'product_${widget.product.id}',
            child: SizedBox(
              height: orientation == Orientation.portrait ? (isWide ? 500 : 350) : 200,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: widget.product.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  highlightColor: Theme.of(context).colorScheme.surface,
                  child: Container(color: Theme.of(context).colorScheme.surface),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          );

          final details = Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.product.category,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Price
                  Text(
                    widget.product.formattedPrice,
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Variants
                  const Text(
                    'Select Variant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _variants.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final variant = _variants[index];
                        return ChoiceChip(
                          label: Text(variant),
                          selected: _selectedVariant == variant,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedVariant = variant;
                              });
                            }
                          },
                          selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.product.description} Designed to deliver an unparalleled experience with industry-leading performance and battery life. Perfect for professionals and power users who demand the best from their tech.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Key Specs
                  const Text(
                    'Key Specs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSpecRow(Icons.memory, 'Processor', 'Octa-core 3.2GHz'),
                  const Divider(),
                  _buildSpecRow(Icons.screenshot, 'Display', '6.7" OLED 120Hz'),
                  const Divider(),
                  _buildSpecRow(Icons.battery_full, 'Battery', '5000 mAh Fast Charge'),
                  const Divider(),
                  _buildSpecRow(Icons.camera, 'Camera', '48MP Main / 12MP Ultra-wide'),
                  const SizedBox(height: 32),

                  const SizedBox(height: 40),
                ],
              ),
            );

          return SingleChildScrollView(
            child: isWide 
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: heroImage),
                      Expanded(flex: 1, child: details),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [heroImage, details],
                  ),
          );
        },
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              border: Border(
                top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Price',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          widget.product.formattedPrice,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false).addToCart(widget.product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${widget.product.name} to cart!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        label: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
