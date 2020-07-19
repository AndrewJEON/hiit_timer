import 'package:equatable/equatable.dart';

class TimerModel extends Equatable {
  final String description;
  final Duration duration;

  TimerModel({
    this.description,
    this.duration,
  });

  TimerModel.initial()
      : description = 'Work',
        duration = const Duration(seconds: 30);

  TimerModel copyWith({
    String description,
    Duration duration,
  }) {
    return TimerModel(
      description: description ?? this.description,
      duration: duration ?? this.duration,
    );
  }

  TimerModel.fromJson(Map<String, dynamic> json)
      : description = json['description'],
        duration = Duration(seconds: json['duration']);

  Map<String, dynamic> toJson() => {
        'description': description,
        'duration': duration.inSeconds,
      };

  @override
  List<Object> get props => [description, duration];
}
