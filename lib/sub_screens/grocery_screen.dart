import 'package:blinkit_clone/sub_screens/category_sidebar.dart';
import 'package:blinkit_clone/sub_screens/product_grid.dart';
import 'package:blinkit_clone/sub_screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../models/category_model.dart'; // Added import for CategoryModel

class GroceryScreen extends StatefulWidget {
  final Category?
  selectedCategory; // Added optional selected category parameter
  final String?
  superCategoryName; // Added optional super category name parameter

  const GroceryScreen({
    super.key,
    this.selectedCategory,
    this.superCategoryName,
  });

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  String? selectedSuperCategory;
  String? selectedSubCategory;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCategory != null && widget.superCategoryName != null) {
      selectedSuperCategory = widget.superCategoryName;
      selectedSubCategory = widget.selectedCategory!.name;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();

      if (widget.selectedCategory != null) {
        context.read<ProductProvider>().fetchProductsBySubCategory(
          widget.selectedCategory!.name,
        );
      } else {
        context.read<ProductProvider>().fetchProducts();
      }
    });
  }

  void _onCategorySelected(String superCategory, String? subCategory) {
    setState(() {
      selectedSuperCategory = superCategory;
      selectedSubCategory = subCategory;
    });

    if (subCategory != null) {
      context.read<ProductProvider>().fetchProductsBySubCategory(subCategory);
    } else {
      context.read<ProductProvider>().fetchProductsBySuperCategory(
        superCategory,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(
              context,
            ); // Added proper navigation back to home screen
          },
        ),
        title: Text(
          widget.selectedCategory != null
              ? '${widget.superCategoryName}' // Show selected category in title
              : 'Grocery & Kitchen',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer2<CategoryProvider, ProductProvider>(
        builder: (context, categoryProvider, productProvider, child) {
          if (categoryProvider.isLoading &&
              categoryProvider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Row(
            children: [
              CategorySidebar(
                categories: categoryProvider.categories,
                selectedSuperCategory: selectedSuperCategory,
                selectedSubCategory: selectedSubCategory,
                onCategorySelected: _onCategorySelected,
              ),
              Expanded(
                child: ProductGrid(
                  products: productProvider.products,
                  isLoading: productProvider.isLoading,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
