import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Bolivian phone input: fixed +591 prefix plus the 8-digit number.
class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    required this.controller,
    required this.onChanged,
    this.focused = false,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 56,
          width: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.input,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('+591', style: AppTextStyles.bodyLarge),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.expand_more_rounded, size: 16),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: '7654 3210',
              enabledBorder: focused
                  ? OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: const BorderSide(
                        color: AppColors.ink,
                        width: 2,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
