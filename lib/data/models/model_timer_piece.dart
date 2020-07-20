import 'package:equatable/equatable.dart';

class TimerPieceModel extends Equatable {
  final String description;
  final Duration duration;

  TimerPieceModel({
    this.description,
    this.duration,
  });

  TimerPieceModel.initial()
      : description = 'Work',
        duration = const Duration(seconds: 30);

  TimerPieceModel copyWith({
    String description,
    Duration duration,
  }) {
    return TimerPieceModel(
      description: description ?? this.description,
      duration: duration ?? this.duration,
    );
  }

  TimerPieceModel.fromJson(Map<String, dynamic> json)
      : description = json['description'],
        duration = Duration(seconds: json['duration']);

  Map<String, dynamic> toJson() => {
        'description': description,
        'duration': duration.inSeconds,
      };

  @override
  List<Object> get props => [description, duration];
}
