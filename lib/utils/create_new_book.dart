import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/create_book_controller.dart';

class CreateNewBookPage extends StatelessWidget {
  const CreateNewBookPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateBookController());
    
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
              key: controller.formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Book Cover Picker ---
                    Obx(() => _buildCoverPickerSection(controller)),
                    const SizedBox(height: 24),

                    // --- Book Title ---
                    TextFormField(
                      controller: controller.titleController,
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
                    Obx(() => _buildGenreDropdown(controller)),
                    const SizedBox(height: 24),

                    // --- Create Button ---
                    Obx(() => _buildCreateButton(controller)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCoverPickerSection(CreateBookController controller) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: GestureDetector(
        onTap: controller.isLoading.value ? null : controller.pickImage,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
            image: controller.bookCover.value != null
                ? DecorationImage(
                    image: FileImage(File(controller.bookCover.value!.path)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: controller.bookCover.value == null
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
    );
  }
  
  Widget _buildGenreDropdown(CreateBookController controller) {
    return DropdownButtonFormField<String>(
      value: controller.selectedGenre.value,
      decoration: const InputDecoration(
        labelText: 'Genre*',
        border: OutlineInputBorder(),
        hintText: 'Select Genre',
      ),
      isExpanded: true,
      items: controller.genres.map((String genre) {
        return DropdownMenuItem(value: genre, child: Text(genre));
      }).toList(),
      onChanged: (String? newValue) {
        controller.selectedGenre.value = newValue;
      },
      validator: (value) => value == null ? 'Please select a genre' : null,
    );
  }
  
  Widget _buildCreateButton(CreateBookController controller) {
    return ElevatedButton.icon(
      onPressed: controller.isLoading.value ? null : controller.createBook,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
      ),
      icon: controller.isLoading.value
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
      label: Text(controller.isLoading.value ? 'Creating...' : 'Create Book'),
    );
  }
}