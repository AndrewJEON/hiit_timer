import 'package:equatable/equatable.dart';

class TimerPieceModel extends Equatable {
  final String tts;
  final Duration duration;

  TimerPieceModel({
    this.tts,
    this.duration,
  });

  TimerPieceModel.initial()
      : tts = 'Work',
        duration = const Duration(seconds: 30);

  TimerPieceModel copyWith({
    String description,
    Duration duration,
  }) {
    return TimerPieceModel(
      tts: description ?? this.tts,
      duration: duration ?? this.duration,
    );
  }

  TimerPieceModel.fromJson(Map<String, dynamic> json)
      : tts = json['description'],
        duration = Duration(seconds: json['duration']);

  Map<String, dynamic> toJson() => {
        'description': tts,
        'duration': duration.inSeconds,
      };

  @override
  List<Object> get props => [tts, duration];
}
