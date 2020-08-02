import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../bloc/timer_creating/timer_creating_bloc.dart';
import '../../../data/models/model_timer_piece.dart';

class TimerOptions {
  static const copy = 'Copy';
  static const delete = 'Delete';
  static const moveUp = 'Move Up';
  static const moveDown = 'Move Down';
  static const all = [copy, delete, moveUp, moveDown];
}

class TimerView extends StatefulWidget {
  final TimerPieceModel timer;
  final int setIndex;
  final int index;

  const TimerView({
    Key key,
    @required this.timer,
    @required this.setIndex,
    @required this.index,
  }) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  final _hourController = TextEditingController();
  final _minuteController = TextEditingController();
  final _secondController = TextEditingController();
  final _ttsController = TextEditingController();

  final _hourFocusNode = FocusNode();
  final _minuteFocusNode = FocusNode();
  final _secondFocusNode = FocusNode();
  final _ttsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hourController.text =
        widget.timer.duration.inHours.toString().padLeft(2, '0');
    _minuteController.text = widget.timer.duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    _secondController.text = widget.timer.duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    _ttsController.text = widget.timer.tts;

    _hourFocusNode.addListener(() {
      if (_hourFocusNode.hasFocus) {
        _hourController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _hourController.text.length,
        );
      }
      if (_hourController.text.length < 2) {
        _hourController.text = _hourController.text.padLeft(2, '0');
      }
      context.bloc<TimerCreatingBloc>().add(
            TimerDurationChanged(
              duration: Duration(
                hours: int.tryParse(_hourController.text),
                minutes: int.tryParse(_minuteController.text),
                seconds: int.tryParse(_secondController.text),
              ),
              setIndex: widget.setIndex,
              index: widget.index,
            ),
          );
    });
    _minuteFocusNode.addListener(() {
      if (_minuteFocusNode.hasFocus) {
        _minuteController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _minuteController.text.length,
        );
      }
      if (_minuteController.text.length < 2) {
        _minuteController.text = _minuteController.text.padLeft(2, '0');
      }
      if (int.tryParse(_minuteController.text) >= 60) {
        _minuteController.text = '59';
      }
      context.bloc<TimerCreatingBloc>().add(
            TimerDurationChanged(
              duration: Duration(
                hours: int.tryParse(_hourController.text),
                minutes: int.tryParse(_minuteController.text),
                seconds: int.tryParse(_secondController.text),
              ),
              setIndex: widget.setIndex,
              index: widget.index,
            ),
          );
    });
    _secondFocusNode.addListener(() {
      if (_secondFocusNode.hasFocus) {
        _secondController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _secondController.text.length,
        );
      }
      if (_secondController.text.length < 2) {
        _secondController.text = _secondController.text.padLeft(2, '0');
      }
      if (int.tryParse(_secondController.text) >= 60) {
        _secondController.text = '59';
      }
      context.bloc<TimerCreatingBloc>().add(
            TimerDurationChanged(
              duration: Duration(
                hours: int.tryParse(_hourController.text),
                minutes: int.tryParse(_minuteController.text),
                seconds: int.tryParse(_secondController.text),
              ),
              setIndex: widget.setIndex,
              index: widget.index,
            ),
          );
    });
    _ttsFocusNode.addListener(() {
      if (_ttsFocusNode.hasFocus) {
        _ttsController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _ttsController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _ttsFocusNode.dispose();
    _secondFocusNode.dispose();
    _minuteFocusNode.dispose();
    _hourFocusNode.dispose();
    _ttsController.dispose();
    _secondController.dispose();
    _minuteController.dispose();
    _hourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          duration(),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: description(),
            ),
          ),
          options(),
        ],
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).primaryColor)),
    );
  }

  Widget description() {
    return TextField(
      controller: _ttsController,
      focusNode: _ttsFocusNode,
      maxLines: null,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: 'Text-To-Speech',
      ),
      onChanged: (value) {
        context.bloc<TimerCreatingBloc>().add(
              TimerDescriptionChanged(
                description: value,
                setIndex: widget.setIndex,
                index: widget.index,
              ),
            );
      },
    );
  }

  Widget duration() {
    return Container(
      width: 128,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _hourController,
              focusNode: _hourFocusNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(2),
                WhitelistingTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.end,
              cursorWidth: 0,
              style: TextStyle(color: Colors.white),
              onSubmitted: (value) => FocusScope.of(context).nextFocus(),
              onChanged: (value) {
                if (value.length == 2) {
                  FocusScope.of(context).nextFocus();
                }
              },
            ),
          ),
          Expanded(
            child: Text(
              ':',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _minuteController,
              focusNode: _minuteFocusNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(2),
                WhitelistingTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.end,
              cursorWidth: 0,
              style: TextStyle(color: Colors.white),
              onSubmitted: (value) => FocusScope.of(context).nextFocus(),
              onChanged: (value) {
                if (value.length == 2) {
                  FocusScope.of(context).nextFocus();
                }
              },
            ),
          ),
          Expanded(
            child: Text(
              ':',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _secondController,
              focusNode: _secondFocusNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(2),
                WhitelistingTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.end,
              cursorWidth: 0,
              style: TextStyle(color: Colors.white),
              onSubmitted: (value) => FocusScope.of(context).nextFocus(),
              onChanged: (value) {
                if (value.length == 2) {
                  FocusScope.of(context).nextFocus();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget options() {
    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case TimerOptions.copy:
            context.bloc<TimerCreatingBloc>().add(
                  TimerCopied(
                    setIndex: widget.setIndex,
                    index: widget.index,
                  ),
                );
            break;
          case TimerOptions.delete:
            context.bloc<TimerCreatingBloc>().add(
                  TimerDeleted(
                    setIndex: widget.setIndex,
                    index: widget.index,
                  ),
                );
            break;
          case TimerOptions.moveUp:
            context.bloc<TimerCreatingBloc>().add(
                  TimerMovedUp(
                    setIndex: widget.setIndex,
                    index: widget.index,
                  ),
                );
            break;
          case TimerOptions.moveDown:
            context.bloc<TimerCreatingBloc>().add(
                  TimerMovedDown(
                    setIndex: widget.setIndex,
                    index: widget.index,
                  ),
                );
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) {
        return [
          for (final option in TimerOptions.all)
            PopupMenuItem(
              value: option,
              child: Text(option),
            ),
        ];
      },
    );
  }
}
