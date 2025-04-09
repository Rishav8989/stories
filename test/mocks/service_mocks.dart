import 'package:mockito/annotations.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/utils/user_service.dart';
import 'package:stories/models/book_model.dart';
import 'package:stories/models/chapter_model.dart';

@GenerateMocks([
  UserService,
  PocketBase,
  RecordService,
], customMocks: [
  MockSpec<RecordModel>(
    as: #MockPocketbaseRecord,
  ),
  MockSpec<BookModel>(
    as: #MockBookModel,
  ),
  MockSpec<ChapterModel>(
    as: #MockChapterModel,
  ),
])
void main() {} 