import 'package:flutter/material.dart';

void main() {
  runApp(const ResponsiveEcommerceApp());
}

class ResponsiveEcommerceApp extends StatelessWidget {
  const ResponsiveEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive E-Commerce Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CatalogResponsiveScreen(),
    );
  }
}

/// Product Data Model
class Product {
  final int id;
  final String title;
  final String category;
  final double price;
  final double rating;
  final IconData icon;
  final Color accentColor;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.rating,
    required this.icon,
    required this.accentColor,
  });
}

class CatalogResponsiveScreen extends StatefulWidget {
  const CatalogResponsiveScreen({super.key});

  @override
  State<CatalogResponsiveScreen> createState() => _CatalogResponsiveScreenState();
}

class _CatalogResponsiveScreenState extends State<CatalogResponsiveScreen> {
  String selectedCategory = 'All';
  int selectedNavIndex = 0;

  final List<String> categories = ['All', 'Electronics', 'Footwear', 'Accessories', 'Audio'];

  final List<Product> products = const [
    Product(
      id: 1,
      title: 'Noise Cancelling Headphones',
      category: 'Audio',
      price: 129.99,
      rating: 4.8,
      icon: Icons.headphones,
      accentColor: Colors.blueAccent,
    ),
    Product(
      id: 2,
      title: 'Mechanical Gaming Keyboard',
      category: 'Electronics',
      price: 89.50,
      rating: 4.7,
      icon: Icons.keyboard,
      accentColor: Colors.deepPurple,
    ),
    Product(
      id: 3,
      title: 'Smart Fitness Tracker',
      category: 'Electronics',
      price: 49.99,
      rating: 4.5,
      icon: Icons.watch,
      accentColor: Colors.teal,
    ),
    Product(
      id: 4,
      title: 'Ultralight Running Shoes',
      category: 'Footwear',
      price: 79.99,
      rating: 4.6,
      icon: Icons.run_circle_outlined,
      accentColor: Colors.orange,
    ),
    Product(
      id: 5,
      title: 'Leather Minimalist Wallet',
      category: 'Accessories',
      price: 34.99,
      rating: 4.3,
      icon: Icons.wallet_giftcard,
      accentColor: Colors.brown,
    ),
    Product(
      id: 6,
      title: 'Wireless Studio Earbuds',
      category: 'Audio',
      price: 59.99,
      rating: 4.6,
      icon: Icons.earbuds,
      accentColor: Colors.cyan,
    ),
    Product(
      id: 7,
      title: 'Ergonomic Vertical Mouse',
      category: 'Electronics',
      price: 39.99,
      rating: 4.4,
      icon: Icons.mouse,
      accentColor: Colors.indigo,
    ),
    Product(
      id: 8,
      title: 'Polarized Aviator Sunglasses',
      category: 'Accessories',
      price: 24.99,
      rating: 4.2,
      icon: Icons.visibility,
      accentColor: Colors.pink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = selectedCategory == 'All'
        ? products
        : products.where((p) => p.category == selectedCategory).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeScreen = constraints.maxWidth >= 800;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'GadgetStore Catalog',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.indigo.shade50,
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Row(
            children: [
              // Show NavigationRail for Desktop / Tablet (Large Screen)
              if (isLargeScreen)
                NavigationRail(
                  selectedIndex: selectedNavIndex,
                  onDestinationSelected: (int index) {
                    setState(() => selectedNavIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Icon(Icons.storefront, color: Colors.indigo, size: 36),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Shop'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite_border),
                      selectedIcon: Icon(Icons.favorite),
                      label: Text('Wishlist'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Account'),
                    ),
                  ],
                ),

              // Main Catalog View
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Screen Size Indicator Badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.indigo.shade50,
                      child: Row(
                        children: [
                          Icon(
                            isLargeScreen ? Icons.desktop_windows : Icons.phone_android,
                            size: 18,
                            color: Colors.indigo,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isLargeScreen
                                ? 'Large Screen Layout (Width: ${constraints.maxWidth.toInt()}px - Grid View)'
                                : 'Mobile Screen Layout (Width: ${constraints.maxWidth.toInt()}px - Adaptive Grid)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Category Filter Chips
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = category == selectedCategory;
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) {
                                setState(() => selectedCategory = category);
                              }
                            },
                            selectedColor: Colors.indigo,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        },
                      ),
                    ),

                    // Responsive Grid of Products using LayoutBuilder
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, gridConstraints) {
                          int crossAxisCount = 2;
                          double childAspectRatio = 0.72;

                          if (gridConstraints.maxWidth >= 1100) {
                            crossAxisCount = 4;
                            childAspectRatio = 0.85;
                          } else if (gridConstraints.maxWidth >= 750) {
                            crossAxisCount = 3;
                            childAspectRatio = 0.78;
                          } else if (gridConstraints.maxWidth < 450) {
                            crossAxisCount = 1;
                            childAspectRatio = 1.35;
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              return ProductCard(product: filteredProducts[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isLargeScreen
              ? null
              : BottomNavigationBar(
                  currentIndex: selectedNavIndex,
                  onTap: (val) => setState(() => selectedNavIndex = val),
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Shop'),
                    BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
                    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
                  ],
                ),
        );
      },
    );
  }
}

/// Reusable Custom Widget: ProductCard
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Product Graphic Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: product.accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    product.icon,
                    size: 50,
                    color: product.accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Category tag
            Text(
              product.category.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),

            // Product Title
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 8),

            // Price and Rating Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 15, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(
                      product.rating.toString(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.title} added to cart!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
