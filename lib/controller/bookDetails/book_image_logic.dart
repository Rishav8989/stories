import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/utils/cached_image_manager.dart';

extension BookImageLogic on BookDetailsController {
  Widget getBookCoverImage({double? width, double? height}) {
    final String? imageUrl = book.value?.bookCover != null
        ? '${dotenv.get('POCKETBASE_URL')}/api/files/'
            '${book.value?.collectionId}/${book.value?.id}/${book.value?.bookCover}'
        : null;
    return CachedImageManager.getBookCover(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  Widget getAuthorProfileImage({double? width, double? height}) {
    final authorData = book.value?.expand?['author'] as Map<String, dynamic>?;
    final String? authorId = authorData?['id'];
    final String? avatarFilename = authorData?['avatar'];
    final String? collectionId = authorData?['collectionId'];

    String? imageUrl;
    if (authorId != null && avatarFilename != null && collectionId != null) {
      imageUrl = '${dotenv.get('POCKETBASE_URL')}/api/files/'
          '$collectionId/$authorId/$avatarFilename';
    }

    return CachedImageManager.getProfileImage(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}