import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/book_model.dart';
import 'package:stories/utils/cached_image_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/utils/user_service.dart';

class EditBookPage extends GetView<BookDetailsController> {
  final BookModel book;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  // Move these to the controller
  late final BookDetailsController _controller;

  EditBookPage({Key? key, required this.book}) : super(key: key) {
    _titleController.text = book.title;
    _descriptionController.text = book.description;
    _controller = Get.find<BookDetailsController>(tag: book.id);
    // Initialize the reactive variables in the controller
    _controller.selectedGenres.value = List<String>.from(book.genre);
    _controller.selectedType.value = book.bookType;
    _controller.selectedImage.value = null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _controller.selectedImage.value = File(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth < 600 ? screenWidth - 32.0 : 600.0;

    // Define available genres and types
    final availableGenres = [
      'Fantasy',
      'Science Fiction',
      'Romance',
      'Mystery',
      'Thriller',
      'Horror',
      'Historical',
      'Literary',
      'Young Adult',
      'Children',
    ];

    final availableTypes = [
      'Novel',
      'Novella',
      'Short Story',
      'Poetry',
      'Non-Fiction',
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 200,
            actions: [
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await _controller.updateBook(
                        book.id,
                        _titleController.text.trim(),
                        _descriptionController.text.trim(),
                        genres: _controller.selectedGenres,
                        bookType: _controller.selectedType.value,
                        coverImage: _controller.selectedImage.value,
                      );
                      Get.back();
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to update book: ${e.toString()}',
                        backgroundColor: colorScheme.error,
                        colorText: colorScheme.onError,
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Obx(() {
                    if (_controller.selectedImage.value != null) {
                      return Image.file(
                        _controller.selectedImage.value!,
                        fit: BoxFit.cover,
                      );
                    }
                    return CachedImageManager.getBookCover(
                      book.bookCover != null
                          ? '${_controller.pb.baseUrl}/api/files/books/${book.id}/${book.bookCover}'
                          : null,
                      fit: BoxFit.cover,
                    );
                  }),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          colorScheme.surface.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Book Title',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _titleController,
                                focusNode: _titleFocusNode,
                                style: textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: 'Enter book title',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Book Cover',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image),
                                label: const Text('Change Cover Image'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Book Type',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(() => Wrap(
                                spacing: 8,
                                children: availableTypes.map((type) {
                                  final isSelected = _controller.selectedType.value == type;
                                  return FilterChip(
                                    label: Text(type),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      _controller.selectedType.value = type;
                                    },
                                  );
                                }).toList(),
                              )),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Genres',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(() => Wrap(
                                spacing: 8,
                                children: availableGenres.map((genre) {
                                  final isSelected = _controller.selectedGenres.contains(genre);
                                  return FilterChip(
                                    label: Text(genre),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        _controller.selectedGenres.add(genre);
                                      } else {
                                        _controller.selectedGenres.remove(genre);
                                      }
                                    },
                                  );
                                }).toList(),
                              )),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _descriptionController,
                                focusNode: _descriptionFocusNode,
                                style: textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                ),
                                maxLines: 10,
                                decoration: InputDecoration(
                                  hintText: 'Enter book description',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  alignLabelWithHint: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 