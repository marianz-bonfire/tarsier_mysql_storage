import 'package:flutter/material.dart';
import 'package:flutter_example/models/category_model.dart';
import 'package:flutter_example/tables/category_table.dart';

// Category List Page
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Category> _categories = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshCategories();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future refreshCategories() async {
    setState(() => isLoading = true);

    _categories = await CategoryTable().all();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category List'),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ListTile(
            title: Text(category.name),
            subtitle: Text(
                '${category.description} - ${category.isActive == 1 ? "Active" : "Inactive"}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditCategoryPage(
                      category: category,
                      onSave: (updatedCategory) async {
                        await CategoryTable().update(category.id!, {
                          CategoryFields.name: updatedCategory.name,
                          CategoryFields.description:
                              updatedCategory.description,
                          CategoryFields.isActive: updatedCategory.isActive
                        });
                        refreshCategories();
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditCategoryPage(
                onSave: (newCategory) async {
                  await CategoryTable().createObject(newCategory);
                  refreshCategories();
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Add/Edit Category Page
class AddEditCategoryPage extends StatefulWidget {
  final Category? category;
  final void Function(Category category) onSave;

  const AddEditCategoryPage({super.key, this.category, required this.onSave});

  @override
  State<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.category?.description ?? '');
    _isActive = widget.category?.isActive == 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = Category(
        name: _nameController.text,
        description: _descriptionController.text,
        isActive: _isActive ? 1 : 0,
      );
      widget.onSave(category);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('Status:'),
                  const SizedBox(width: 16.0),
                  Switch(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                  Text(_isActive ? 'Active' : 'Inactive'),
                ],
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _saveCategory,
                child: Text(
                    widget.category == null ? 'Add Category' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
