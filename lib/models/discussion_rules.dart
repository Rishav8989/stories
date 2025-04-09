import 'package:json_annotation/json_annotation.dart';

part 'discussion_rules.g.dart';

@JsonSerializable()
class DiscussionRules {
  final String id;
  final String user;
  final String book;
  final String rules;

  DiscussionRules({
    required this.id,
    required this.user,
    required this.book,
    required this.rules,
  });

  factory DiscussionRules.fromJson(Map<String, dynamic> json) => _$DiscussionRulesFromJson(json);

  Map<String, dynamic> toJson() => _$DiscussionRulesToJson(this);
} 