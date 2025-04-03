import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../utils/user_service.dart';

class CreateNewBookPage extends StatefulWidget {
  const CreateNewBookPage({Key? key}) : super(key: key);

  @override
  State<CreateNewBookPage> createState() => _CreateNewBookPageState();
}

class _CreateNewBookPageState extends State<CreateNewBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedGenre = 'Fantasy';
  String _selectedStatus = 'draft';
  bool _isOriginal = true;
  bool _isLoading = false;
  XFile? _bookCover;

  final List<String> _genres = ['Fantasy', 'Science Fiction', 'Romance', 'Mystery'];
  final List<String> _statuses = ['draft', 'published'];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _bookCover = image;
      });
    }
  }

  Future<void> _createBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userService = Get.find<UserService>();
      final token = await userService.getAuthToken();
      final userId = await userService.getUserId();

      if (token == null || userId == null) {
        throw Exception('Authentication required');
      }

      // Prepare files list
      List<http.MultipartFile> files = [];
      if (_bookCover != null) {
        files.add(await http.MultipartFile.fromPath('book_cover', _bookCover!.path));
      }

      // Create book in PocketBase
      final book = await userService.pb.collection('books').create(
        body: {
          "title": _titleController.text,
          "author": userId,
          "status": _selectedStatus,
          "is_orignal": _isOriginal,
          "Genre": [_selectedGenre],
          "book_type": "Novels",
        },
        files: files,
        headers: {'Authorization': token},
      );

      // Success message
      Get.snackbar(
        'Success',
        'Book created successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear form
      _titleController.clear();
      setState(() => _bookCover = null);

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create book: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Book')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Book Cover Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _bookCover != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_bookCover!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate, size: 50),
                              SizedBox(height: 8),
                              Text('Add Book Cover'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Book Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Genre Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGenre,
                  decoration: const InputDecoration(
                    labelText: 'Genre',
                    border: OutlineInputBorder(),
                  ),
                  items: _genres.map((String genre) {
                    return DropdownMenuItem(value: genre, child: Text(genre));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => _selectedGenre = newValue!);
                  },
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: _statuses.map((String status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => _selectedStatus = newValue!);
                  },
                ),
                const SizedBox(height: 16),

                // Original Work Switch
                SwitchListTile(
                  title: const Text('Original Work'),
                  value: _isOriginal,
                  onChanged: (bool value) {
                    setState(() => _isOriginal = value);
                  },
                ),
                const SizedBox(height: 24),

                // Create Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _createBook,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Book'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}