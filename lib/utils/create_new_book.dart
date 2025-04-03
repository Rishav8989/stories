import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../utils/user_service.dart'; // Ensure this path is correct

class CreateNewBookPage extends StatefulWidget {
  const CreateNewBookPage({Key? key}) : super(key: key);

  @override
  State<CreateNewBookPage> createState() => _CreateNewBookPageState();
}

class _CreateNewBookPageState extends State<CreateNewBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedGenre; // Nullable for initial empty state
  // Removed _selectedStatus and _isOriginal
  bool _isLoading = false;
  XFile? _bookCover;

  // Updated list of genres
  final List<String> _genres = [
    'Fantasy', 'Fiction', 'Science', 'Thriller', 'Horror', 'Romance',
    'Historical', 'Literary', 'Young Adult', 'Children\'s Fiction',
    'Adventure', 'Humor', 'Comedy', 'Fanfiction', 'Magical',
    'Biography', 'Non-Fiction','Other'
  ];
  // Removed _statuses list

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );

    if (image != null && mounted) {
      setState(() {
        _bookCover = image;
      });
    }
  }

  Future<void> _createBook() async {
    // Validate form (only title and genre now)
    if (!_formKey.currentState!.validate()) return;

    // Check if genre is selected (already handled by validator)
    if (_selectedGenre == null) {
       Get.snackbar(
        'Missing Information',
        'Please select a Genre.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userService = Get.find<UserService>();
      final userId = await userService.getUserId();

      if (userId == null) {
        throw Exception('Authentication required. Please log in again.');
      }

      List<http.MultipartFile> files = [];
      if (_bookCover != null) {
        files.add(await http.MultipartFile.fromPath(
          'book_cover',
          _bookCover!.path,
        ));
      }

      // Create book record - status and is_orignal are now hardcoded
      final book = await userService.pb.collection('books').create(
        body: {
          "title": _titleController.text.trim(),
          "author": userId,
          "status": "draft",         // Hardcoded status
          "is_orignal": true,          // Hardcoded as true (original work)
          "Genre": _selectedGenre!,
          "book_type": "Novels",
        },
        files: files,
      );

      if (mounted) {
         Get.snackbar(
          'Success',
          'Book "${book.data['title']}" created successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Reset form fields
        _formKey.currentState?.reset();
        _titleController.clear();
        setState(() {
           _bookCover = null;
           _selectedGenre = null; // Reset genre dropdown
           // No need to reset status or isOriginal anymore
        });
      }

    } catch (e) {
       if (mounted) {
         Get.snackbar(
          'Error',
          'Failed to create book: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
       }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Book'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Book Cover Picker ---
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                            image: _bookCover != null
                                ? DecorationImage(
                                    image: FileImage(File(_bookCover!.path)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _bookCover == null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 50,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add Book Cover (Optional)',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Book Title ---
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Book Title*',
                        border: OutlineInputBorder(),
                        hintText: 'Enter the title of your book',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Genre Dropdown ---
                    DropdownButtonFormField<String>(
                      value: _selectedGenre,
                      decoration: const InputDecoration(
                        labelText: 'Genre*',
                        border: OutlineInputBorder(),
                        hintText: 'Select Genre',
                      ),
                      isExpanded: true,
                      items: _genres.map((String genre) {
                        return DropdownMenuItem(value: genre, child: Text(genre));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() => _selectedGenre = newValue);
                      },
                      validator: (value) => value == null ? 'Please select a genre' : null,
                    ),
                    const SizedBox(height: 16),

                    // --- Status Dropdown REMOVED ---

                    // --- Original Work Switch REMOVED ---

                    const SizedBox(height: 24), // Keep spacing before button

                    // --- Create Button ---
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createBook,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      icon: _isLoading
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(Icons.add_circle_outline),
                      label: Text(_isLoading ? 'Creating...' : 'Create Book'),
                    ),
                  ],
                ),
              ),
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

extension StringExtension on String {
  String? get capitalizeFirst {
    // Still useful if you display status elsewhere, but not needed here.
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}