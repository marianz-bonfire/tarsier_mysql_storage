import 'package:flutter/material.dart';
import 'package:flutter_example/ui/screens/category_screen.dart';
import 'package:flutter_example/ui/screens/notes_page.dart';
import 'package:flutter_example/ui/screens/product_screen.dart';
import 'package:flutter_example/ui/screens/user_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return GestureDetector(
              onTap: () async {
                // Handle menu item tap
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item['title']} tapped!')),
                );
                if (item['title'] == 'Notes') {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NotesPage()),
                  );
                } else if (item['title'] == 'Users') {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const UsersPage()),
                  );
                } else if (item['title'] == 'Products') {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const ProductPage()),
                  );
                } else if (item['title'] == 'Category') {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const CategoryPage()),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'],
                      size: 48.0,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> menuItems = [
  {
    'title': 'Users',
    'icon': Icons.person,
  },
  {
    'title': 'Notes',
    'icon': Icons.note,
  },
  {
    'title': 'Products',
    'icon': Icons.shopping_cart,
  },
  {
    'title': 'Category',
    'icon': Icons.category,
  },
];
