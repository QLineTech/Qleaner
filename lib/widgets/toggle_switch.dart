import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class ToggleSwitch extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  const ToggleSwitch({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.moonTypography!.body.text12.copyWith(
            color: context.moonColors!.trunks,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFF3FB950)
                  : context.moonColors!.beerus,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
