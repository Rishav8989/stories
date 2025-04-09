// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_rules.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscussionRules _$DiscussionRulesFromJson(Map<String, dynamic> json) =>
    DiscussionRules(
      id: json['id'] as String,
      user: json['user'] as String,
      book: json['book'] as String,
      rules: json['rules'] as String,
    );

Map<String, dynamic> _$DiscussionRulesToJson(DiscussionRules instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'book': instance.book,
      'rules': instance.rules,
    };
