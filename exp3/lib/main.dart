import 'package:flutter/material.dart';

void main() {
  runApp(const InteractiveSearchApp());
}

class InteractiveSearchApp extends StatelessWidget {
  const InteractiveSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Search & Filter Interactivity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ProductSearchScreen(),
    );
  }
}

/// Product Model
class ProductItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final bool inStock;
  final IconData icon;

  const ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.inStock,
    required this.icon,
  });
}

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<ProductItem> _allProducts = const [
    ProductItem(id: '1', name: 'MacBook Air M2', category: 'Laptops', price: 999.0, rating: 4.9, inStock: true, icon: Icons.laptop_mac),
    ProductItem(id: '2', name: 'Dell XPS 13', category: 'Laptops', price: 899.0, rating: 4.6, inStock: true, icon: Icons.laptop_windows),
    ProductItem(id: '3', name: 'iPhone 15 Pro', category: 'Phones', price: 1099.0, rating: 4.8, inStock: true, icon: Icons.phone_iphone),
    ProductItem(id: '4', name: 'Samsung Galaxy S24', category: 'Phones', price: 799.0, rating: 4.7, inStock: false, icon: Icons.smartphone),
    ProductItem(id: '5', name: 'iPad Air 5th Gen', category: 'Tablets', price: 599.0, rating: 4.8, inStock: true, icon: Icons.tablet_mac),
    ProductItem(id: '6', name: 'Sony WH-1000XM5', category: 'Audio', price: 349.0, rating: 4.9, inStock: true, icon: Icons.headphones),
    ProductItem(id: '7', name: 'AirPods Pro 2', category: 'Audio', price: 249.0, rating: 4.7, inStock: true, icon: Icons.earbuds),
    ProductItem(id: '8', name: 'Logitech MX Master 3S', category: 'Accessories', price: 99.0, rating: 4.8, inStock: true, icon: Icons.mouse),
    ProductItem(id: '9', name: 'Keychron K2 Keyboard', category: 'Accessories', price: 79.0, rating: 4.5, inStock: false, icon: Icons.keyboard),
    ProductItem(id: '10', name: 'Google Pixel 8', category: 'Phones', price: 699.0, rating: 4.5, inStock: true, icon: Icons.phone_android),
  ];

  String _searchQuery = '';
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 1200);
  bool _onlyInStock = false;
  String _sortBy = 'Name (A-Z)';

  final List<String> _categories = ['All', 'Laptops', 'Phones', 'Tablets', 'Audio', 'Accessories'];
  final List<String> _sortOptions = ['Name (A-Z)', 'Price: Low to High', 'Price: High to Low', 'Top Rated'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductItem> get _filteredProducts {
    return _allProducts.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesPrice = p.price >= _priceRange.start && p.price <= _priceRange.end;
      final matchesStock = !_onlyInStock || p.inStock;
      return matchesSearch && matchesCategory && matchesPrice && matchesStock;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'Price: Low to High':
            return a.price.compareTo(b.price);
          case 'Price: High to Low':
            return b.price.compareTo(a.price);
          case 'Top Rated':
            return b.rating.compareTo(a.rating);
          case 'Name (A-Z)':
          default:
            return a.name.compareTo(b.name);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Search & Filter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade50,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Filters',
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _selectedCategory = 'All';
                _priceRange = const RangeValues(0, 1200);
                _onlyInStock = false;
                _sortBy = 'Name (A-Z)';
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Controls Card (Input Widgets)
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  // 1. Search TextField
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search products by name...',
                      prefixIcon: const Icon(Icons.search, color: Colors.teal),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.teal.shade50.withOpacity(0.4),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Category Filter ChoiceChips
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = _categories[idx];
                        final isSel = cat == _selectedCategory;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                          selectedColor: Colors.teal,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSel ? Colors.white : Colors.black87,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Price Range Slider & Stock Switch
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price Range: \$${_priceRange.start.toInt()} - \$${_priceRange.end.toInt()}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            RangeSlider(
                              values: _priceRange,
                              min: 0,
                              max: 1200,
                              divisions: 24,
                              activeColor: Colors.teal,
                              labels: RangeLabels(
                                '\$${_priceRange.start.toInt()}',
                                '\$${_priceRange.end.toInt()}',
                              ),
                              onChanged: (RangeValues values) {
                                setState(() => _priceRange = values);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          const Text('In Stock Only', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          Switch(
                            value: _onlyInStock,
                            activeColor: Colors.teal,
                            onChanged: (val) => setState(() => _onlyInStock = val),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // 4. Sort Dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing ${filtered.length} products',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Row(
                        children: [
                          const Text('Sort: ', style: TextStyle(fontSize: 12)),
                          DropdownButton<String>(
                            value: _sortBy,
                            underline: const SizedBox(),
                            style: const TextStyle(fontSize: 12.5, color: Colors.teal, fontWeight: FontWeight.bold),
                            items: _sortOptions.map((s) {
                              return DropdownMenuItem(value: s, child: Text(s));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _sortBy = val);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Display List of Filtered Products
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No products found matching filters',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try relaxing your search query or price limits',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade50,
                            child: Icon(item.icon, color: Colors.teal),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Row(
                            children: [
                              Text(item.category, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 8),
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              Text(' ${item.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Text(
                                item.inStock ? '• In Stock' : '• Out of Stock',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: item.inStock ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '\$${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
