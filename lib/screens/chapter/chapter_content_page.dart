import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/chapter_controller.dart';
import 'package:stories/screens/chapter/edit_chapter_page.dart';
import 'package:stories/utils/reading_time_calculator.dart';
import 'package:stories/utils/user_service.dart';

class ChapterContentPage extends StatefulWidget {
  final String chapterId;
  final String bookId;
  final String chapterTitle;
  final String status;

  const ChapterContentPage({
    Key? key,
    required this.chapterId,
    required this.bookId,
    required this.chapterTitle,
    required this.status,
  }) : super(key: key);

  @override
  State<ChapterContentPage> createState() => _ChapterContentPageState();
}

class _ChapterContentPageState extends State<ChapterContentPage> {
  final ScrollController _scrollController = ScrollController();
  final RxDouble _scrollProgress = 0.0.obs;
  final RxBool _isLoadingPrevious = false.obs;
  final RxBool _isLoadingNext = false.obs;
  final RxBool _isAuthor = false.obs;
  late final ChapterController controller;
  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChapterController());
    _userService = Get.find<UserService>();
    _scrollController.addListener(_updateScrollProgress);
    _loadChapterContent();
    _checkIfAuthor();
  }

  Future<void> _checkIfAuthor() async {
    _isAuthor.value = await controller.isBookOwner(widget.bookId);
  }

  Future<void> _loadChapterContent() async {
    try {
      await controller.getChapterContent(widget.chapterId);
    } catch (e) {
      print('Error loading chapter content: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollProgress() {
    if (!_scrollController.hasClients) return;
    
    final double currentScroll = _scrollController.offset;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    
    if (maxScroll <= 0) {
      _scrollProgress.value = 1.0;
    } else {
      _scrollProgress.value = (currentScroll / maxScroll).clamp(0.0, 1.0);
    }
  }

  Future<void> _navigateToPreviousChapter() async {
    if (_isLoadingPrevious.value) return;
    
    _isLoadingPrevious.value = true;
    try {
      final prevChapter = await controller.getPreviousChapter(
        widget.bookId, 
        controller.currentChapterOrder.value
      );
      
      if (prevChapter != null) {
        print('Previous chapter found: ${prevChapter['title']}');
        await Get.off(
          () => ChapterContentPage(
            chapterId: prevChapter['id'],
            bookId: widget.bookId,
            chapterTitle: prevChapter['title'],
            status: prevChapter['status'],
          ),
          preventDuplicates: false,
        );
      } else {
        Get.snackbar(
          'No Previous Chapter',
          'You are at the first chapter',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error navigating to previous chapter: $e');
      Get.snackbar(
        'Error',
        'Failed to load previous chapter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      _isLoadingPrevious.value = false;
    }
  }

  Future<void> _navigateToNextChapter() async {
    if (_isLoadingNext.value) return;
    
    _isLoadingNext.value = true;
    try {
      final nextChapter = await controller.getNextChapter(
        widget.bookId, 
        controller.currentChapterOrder.value
      );
      
      if (nextChapter != null) {
        print('Next chapter found: ${nextChapter['title']}');
        await Get.off(
          () => ChapterContentPage(
            chapterId: nextChapter['id'],
            bookId: widget.bookId,
            chapterTitle: nextChapter['title'],
            status: nextChapter['status'],
          ),
          preventDuplicates: false,
        );
      } else {
        Get.snackbar(
          'No Next Chapter',
          'You are at the last chapter',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error navigating to next chapter: $e');
      Get.snackbar(
        'Error',
        'Failed to load next chapter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      _isLoadingNext.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: false,
            // expandedHeight: 120.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Obx(() => Text(
                controller.chapterTitle.value.isEmpty 
                  ? widget.chapterTitle 
                  : controller.chapterTitle.value,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                ),
              )),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: Obx(() => LinearProgressIndicator(
                value: controller.isLoading.value ? null : _scrollProgress.value,
                backgroundColor: colorScheme.surfaceVariant,
                color: colorScheme.primary,
                minHeight: 2,
              )),
            ),
            actions: [
              Obx(() => _isAuthor.value ? Row(
                children: [
                  if (widget.status == 'draft')
                    IconButton(
                      icon: controller.isLoading.value 
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.publish),
                      tooltip: 'Publish chapter',
                      onPressed: controller.isLoading.value ? null : () => _showPublishDialog(context),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit chapter',
                    onPressed: () => _navigateToEdit(context),
                  ),
                ],
              ) : const SizedBox.shrink()),
            ],
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              final content = controller.currentContent.value;
              if (content.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      ReadingTimeCalculator.calculateReadingTime(content),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => ElevatedButton.icon(
                          onPressed: _isLoadingPrevious.value ? null : _navigateToPreviousChapter,
                          icon: _isLoadingPrevious.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: colorScheme.onPrimaryContainer,
                          ),
                        )),
                        const SizedBox(width: 16),
                        Obx(() => ElevatedButton.icon(
                          onPressed: _isLoadingNext.value ? null : _navigateToNextChapter,
                          icon: const Icon(Icons.arrow_forward),
                          label: _isLoadingNext.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: colorScheme.onPrimaryContainer,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _showPublishDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Chapter'),
        content: const Text('Once published, this chapter will be visible to all readers. Are you sure you want to publish?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await controller.publishChapter(widget.chapterId);
              if (success) {
                Get.back(result: 'published');
              }
            },
            child: const Text('Publish'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    try {
      final chapterContent = await controller.getChapterContent(widget.chapterId);
      if (chapterContent != null) {
        final result = await Get.to(() => EditChapterPage(
          chapterId: widget.chapterId,
          bookId: widget.bookId,
          initialTitle: chapterContent['title'] ?? '',
          initialContent: chapterContent['content'] ?? '',
        ));
        if (result == true) {
          await _loadChapterContent();
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load chapter content: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }
} 