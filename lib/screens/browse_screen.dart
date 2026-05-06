import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categories = productProvider.categories;
    final filteredProducts = productProvider.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cellario Lite',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Badge.count(
                count: cart.itemCount,
                isLabelVisible: cart.itemCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar removed as requested
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth >= 600;

          Widget buildGrid() {
            return OrientationBuilder(
              builder: (context, orientation) {
                final int crossAxisCount = orientation == Orientation.portrait ? 2 : 4;
                final double aspectRatio = orientation == Orientation.portrait ? 0.7 : 0.8;
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: aspectRatio,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 0,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Hero(
                                    tag: 'product_${product.id}',
                                    child: CachedNetworkImage(
                                      imageUrl: product.imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                        highlightColor: Theme.of(context).colorScheme.surface,
                                        child: Container(color: Theme.of(context).colorScheme.surface),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, size: 12, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            product.rating.toString(),
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ],
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
                                    product.category.toUpperCase(),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.name,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product.formattedPrice,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          context.read<CartProvider>().addToCart(product);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${product.name} added to cart'),
                                              duration: const Duration(seconds: 2),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                                        ),
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
                  },
                );
              },
            );
          }

          if (isTablet) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = productProvider.selectedCategory == category;
                      return ListTile(
                        title: Text(
                          category,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        selectedColor: Theme.of(context).primaryColor,
                        onTap: () {
                          productProvider.selectCategory(category);
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: buildGrid(),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                // Filter Chips row
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return FilterChip(
                        label: Text(category),
                        selected: productProvider.selectedCategory == category,
                        onSelected: (bool selected) {
                          if (selected) {
                            productProvider.selectCategory(category);
                          }
                        },
                        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      );
                    },
                  ),
                ),
                
                // Grid View
                Expanded(
                  child: buildGrid(),
                ),
              ],
            );
          }
        },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
