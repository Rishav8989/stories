import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/reader_controller.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/chapter_model.dart';
import 'package:stories/screens/reader/reader_settings_dialog.dart';
import 'package:stories/screens/reader/text_selection_dialog.dart';

class ReaderPage extends StatefulWidget {
  final String chapterId;
  final String bookId;
  final String chapterTitle;
  final String content;

  const ReaderPage({
    Key? key,
    required this.chapterId,
    required this.bookId,
    required this.chapterTitle,
    required this.content,
  }) : super(key: key);

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final readerController = Get.put(ReaderController());
  final bookController = Get.find<BookDetailsController>();
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode contentFocusNode = FocusNode();
  
  int currentChapterIndex = 0;
  bool showSettings = false;
  bool showTableOfContents = false;
  bool showSearch = false;
  bool showStatistics = false;
  String? selectedText;
  int? selectionStart;
  int? selectionEnd;

  @override
  void initState() {
    super.initState();
    _initializeChapter();
    _setupScrollListener();
  }

  void _initializeChapter() {
    final chapters = bookController.chapters
        .where((chapter) => chapter.orderNumber != 0)
        .toList()
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    
    currentChapterIndex = chapters.indexWhere((chapter) => chapter.id == widget.chapterId);
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      final progress = currentScroll / maxScroll;
      readerController.saveProgress(widget.chapterId, progress);
    });
  }

  void _showTextSelectionDialog() {
    if (selectedText != null && selectionStart != null && selectionEnd != null) {
      showDialog(
        context: context,
        builder: (context) => TextSelectionDialog(
          selectedText: selectedText!,
          start: selectionStart!,
          end: selectionEnd!,
          chapterId: widget.chapterId,
          controller: readerController,
        ),
      );
    }
  }

  void _navigateToChapter(int index) {
    final chapters = bookController.chapters
        .where((chapter) => chapter.orderNumber != 0)
        .toList()
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

    if (index >= 0 && index < chapters.length) {
      final chapter = chapters[index];
      Get.to(() => ReaderPage(
        chapterId: chapter.id,
        bookId: widget.bookId,
        chapterTitle: chapter.title,
        content: chapter.content,
      ));
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => showSearch = !showSearch),
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () => setState(() => showTableOfContents = !showTableOfContents),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ReaderSettingsDialog(controller: readerController),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => setState(() => showStatistics = !showStatistics),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildContent(),
          if (showSearch) _buildSearchOverlay(),
          if (showTableOfContents) _buildTableOfContents(),
          if (showStatistics) _buildStatisticsOverlay(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: selectedText != null
          ? FloatingActionButton(
              onPressed: _showTextSelectionDialog,
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildContent() {
    return Obx(() {
      final settings = readerController;
      return SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16.0),
        child: SelectableText(
          widget.content,
          style: TextStyle(
            fontSize: settings.fontSize.value,
            height: settings.lineSpacing.value,
            fontFamily: settings.selectedFont.value,
            color: settings.isDarkMode.value ? Colors.white : Colors.black,
          ),
          onSelectionChanged: (selection, cause) {
            setState(() {
              selectionStart = selection.start;
              selectionEnd = selection.end;
              if (selectionStart != null && selectionEnd != null) {
                selectedText = widget.content.substring(selectionStart!, selectionEnd!);
              } else {
                selectedText = null;
              }
            });
          },
        ),
      );
    });
  }

  Widget _buildSearchOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search in chapter...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => showSearch = false),
            ),
          ),
          onChanged: (value) {
            // Implement search functionality
          },
        ),
      ),
    );
  }

  Widget _buildTableOfContents() {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.7,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            AppBar(
              title: const Text('Table of Contents'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => showTableOfContents = false),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: bookController.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = bookController.chapters[index];
                  if (chapter.orderNumber == 0) return const SizedBox.shrink();
                  return ListTile(
                    title: Text(chapter.title),
                    leading: Text('${chapter.orderNumber}'),
                    selected: chapter.id == widget.chapterId,
                    onTap: () {
                      _navigateToChapter(index - 1); // -1 because we skip the description chapter
                      setState(() => showTableOfContents = false);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Reading Statistics'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => showStatistics = false),
                ),
              ],
            ),
            const Divider(),
            Text('Time spent: ${_formatDuration(readerController.getChapterReadingTime(widget.chapterId))}'),
            Text('Reading speed: ${readerController.getChapterReadingSpeed(widget.chapterId)} words per minute'),
            Text('Progress: ${(readerController.getChapterProgress(widget.chapterId) * 100).round()}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() {
      final chapters = bookController.chapters
          .where((chapter) => chapter.orderNumber != 0)
          .toList()
        ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

      return BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: currentChapterIndex > 0
                  ? () => _navigateToChapter(currentChapterIndex - 1)
                  : null,
            ),
            Text('${currentChapterIndex + 1} of ${chapters.length}'),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: currentChapterIndex < chapters.length - 1
                  ? () => _navigateToChapter(currentChapterIndex + 1)
                  : null,
            ),
          ],
        ),
      );
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '$hours h $minutes m';
    } else if (minutes > 0) {
      return '$minutes m $remainingSeconds s';
    } else {
      return '$remainingSeconds s';
    }
  }
} 