import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analytics.g.dart';

@JsonSerializable()
class Analytics extends Equatable {
  final double totalAmount;
  final int transactionCount;
  final double averageAmount;
  final Map<String, dynamic> byType;
  final Map<String, dynamic> byStatus;
  final AnalyticsTrends? trends;

  const Analytics({
    required this.totalAmount,
    required this.transactionCount,
    required this.averageAmount,
    required this.byType,
    required this.byStatus,
    this.trends,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsToJson(this);

  @override
  List<Object?> get props =>
      [totalAmount, transactionCount, averageAmount, byType, byStatus, trends];
}

@JsonSerializable()
class AnalyticsTrends extends Equatable {
  final List<DailyTrend> daily;

  const AnalyticsTrends({
    required this.daily,
  });

  factory AnalyticsTrends.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsTrendsFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsTrendsToJson(this);

  @override
  List<Object?> get props => [daily];
}

@JsonSerializable()
class DailyTrend extends Equatable {
  final String date;
  final double amount;
  final int count;

  const DailyTrend({
    required this.date,
    required this.amount,
    required this.count,
  });

  factory DailyTrend.fromJson(Map<String, dynamic> json) =>
      _$DailyTrendFromJson(json);

  Map<String, dynamic> toJson() => _$DailyTrendToJson(this);

  @override
  List<Object?> get props => [date, amount, count];
}
