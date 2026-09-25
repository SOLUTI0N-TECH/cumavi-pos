import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Six-box SMS code input.
///
/// One hidden [TextField] holds the value and the boxes render each digit, so
/// paste and autofill keep working. [value] lets the screen fill the code
/// (the demo code banner) without the keyboard.
class VerificationCodeField extends StatefulWidget {
  const VerificationCodeField({
    required this.onChanged,
    this.value = '',
    this.length = 6,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final String value;
  final int length;

  @override
  State<VerificationCodeField> createState() => _VerificationCodeFieldState();
}

class _VerificationCodeFieldState extends State<VerificationCodeField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(VerificationCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(
          children: List<Widget>.generate(widget.length, (int index) {
            final String digits = _controller.text;
            final bool isFilled = index < digits.length;
            final bool isActive = index == digits.length;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == widget.length - 1 ? 0 : 8,
                ),
                child: Container(
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isActive ? AppColors.ink : AppColors.border,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    isFilled ? digits[index] : '',
                    style: AppTextStyles.amountLg.copyWith(fontSize: 28),
                  ),
                ),
              ),
            );
          }),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: widget.length,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (String value) {
                setState(() {});
                widget.onChanged(value);
              },
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
        ),
      ],
    );
  }
}
