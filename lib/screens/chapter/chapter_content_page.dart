import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/chapter_controller.dart';
import 'package:stories/screens/chapter/edit_chapter_page.dart';
import 'package:stories/utils/reading_time_calculator.dart';

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final controller = Get.put(ChapterController());

    // Load initial content
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getChapterContent(widget.chapterId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.chapterTitle.value.isEmpty ? widget.chapterTitle : controller.chapterTitle.value)),
        centerTitle: true,
        actions: [
          if (widget.status == 'draft')
            Obx(() => IconButton(
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
              tooltip: 'Publish this chapter to make it visible to readers',
              onPressed: controller.isLoading.value ? null : () => showDialog(
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
                        foregroundColor: colorScheme.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit chapter title and content',
            onPressed: () async {
              try {
                final chapterContent = await controller.getChapterContent(widget.chapterId);
                if (chapterContent != null) {
                  final result = await Get.to(() => EditChapterPage(
                    chapterId: widget.chapterId,
                    bookId: widget.bookId,
                    initialTitle: chapterContent['title'] ?? '',
                    initialContent: chapterContent['content'] ?? '',
                  ));
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to load chapter content: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            child: Obx(() => LinearProgressIndicator(
              value: controller.isLoading.value ? null : _scrollProgress.value,
              backgroundColor: colorScheme.surfaceVariant,
              color: colorScheme.primary,
              minHeight: 1,
            )),
          ),
          Expanded(
            child: Obx(() {
              final content = controller.currentContent.value;
              if (content.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                controller: _scrollController,
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
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () async {
                            final prevChapter = await controller.getPreviousChapter(widget.bookId, controller.currentChapterOrder.value);
                            if (prevChapter != null) {
                              Get.off(() => ChapterContentPage(
                                chapterId: prevChapter['id'],
                                bookId: widget.bookId,
                                chapterTitle: prevChapter['title'],
                                status: prevChapter['status'],
                              ));
                            }
                          },
                          tooltip: 'Previous Chapter',
                        ),
                        const SizedBox(width: 32),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () async {
                            final nextChapter = await controller.getNextChapter(widget.bookId, controller.currentChapterOrder.value);
                            if (nextChapter != null) {
                              Get.off(() => ChapterContentPage(
                                chapterId: nextChapter['id'],
                                bookId: widget.bookId,
                                chapterTitle: nextChapter['title'],
                                status: nextChapter['status'],
                              ));
                            }
                          },
                          tooltip: 'Next Chapter',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
} 