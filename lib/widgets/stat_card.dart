import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subText;
  final double? progress;
  final List<Color> gradientColors;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subText,
    this.progress,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.moonColors!.gohan,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient top accent
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  label.toUpperCase(),
                  style: context.moonTypography!.body.text12.copyWith(
                    color: context.moonColors!.trunks,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                // Value
                Text(
                  value,
                  style: context.moonTypography!.heading.text32.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Sub text
                if (subText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subText!,
                    style: context.moonTypography!.body.text12.copyWith(
                      color: context.moonColors!.trunks,
                    ),
                  ),
                ],
                // Progress bar
                if (progress != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.moonColors!.goku,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress!.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
