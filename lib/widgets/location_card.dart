import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import '../models/cache_location.dart';

class LocationCard extends StatelessWidget {
  final CacheLocation location;
  final VoidCallback onToggle;
  final VoidCallback? onHintTap;
  final bool showHint;

  const LocationCard({
    super.key,
    required this.location,
    required this.onToggle,
    this.onHintTap,
    this.showHint = false,
  });

  Color _getSizeColor() {
    if (location.size > 1024 * 1024 * 1024)
      return const Color(0xFFF85149); // huge
    if (location.size > 100 * 1024 * 1024)
      return const Color(0xFFD29922); // large
    if (location.size > 10 * 1024 * 1024)
      return const Color(0xFF3FB950); // medium
    return const Color(0xFF6E7681); // small
  }

  Color _getRiskColor() {
    switch (location.risk.toLowerCase()) {
      case 'high':
        return const Color(0xFFF85149);
      case 'medium':
        return const Color(0xFFD29922);
      default:
        return const Color(0xFF3FB950);
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: context.moonColors!.gohan,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: location.selected
              ? const Color(0xFF3FB950)
              : context.moonColors!.beerus,
        ),
        boxShadow: location.selected
            ? [
                BoxShadow(
                  color: const Color(0xFF3FB950).withOpacity(0.05),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: location.selected
                          ? const Color(0xFF3FB950)
                          : context.moonColors!.gohan,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: location.selected
                            ? const Color(0xFF3FB950)
                            : context.moonColors!.beerus,
                        width: 2,
                      ),
                    ),
                    child: location.selected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Risk + Hint
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location.name,
                              style: context.moonTypography!.heading.text16
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          // Risk badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: riskColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              location.risk.toUpperCase(),
                              style: context.moonTypography!.body.text10
                                  .copyWith(
                                    color: riskColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Hint button
                          if (onHintTap != null)
                            GestureDetector(
                              onTap: onHintTap,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.moonColors!.gohan,
                                  border: Border.all(
                                    color: context.moonColors!.beerus,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "?",
                                    style: context.moonTypography!.body.text12
                                        .copyWith(
                                          color: context.moonColors!.trunks,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        location.description,
                        style: context.moonTypography!.body.text14.copyWith(
                          color: context.moonColors!.trunks,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Path
                      Text(
                        location.path.replaceFirst(
                          RegExp(r'/Users/[^/]+'),
                          '~',
                        ),
                        style: context.moonTypography!.body.text12.copyWith(
                          color: context.moonColors!.trunks,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Size
                Text(
                  location.sizeHuman,
                  style: context.moonTypography!.heading.text20.copyWith(
                    color: _getSizeColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Hint panel
          if (showHint)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.moonColors!.gohan,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.moonColors!.beerus),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HintSection(
                    icon: "📖",
                    title: "What is this?",
                    content: location.hint,
                  ),
                  const SizedBox(height: 12),
                  _HintSection(
                    icon: "⚡",
                    title: "Impact of Cleaning",
                    content: location.impact,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HintSection extends StatelessWidget {
  final String icon;
  final String title;
  final String content;

  const _HintSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$icon $title",
          style: context.moonTypography!.body.text12.copyWith(
            color: context.moonColors!.piccolo,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: context.moonTypography!.body.text14.copyWith(
            color: context.moonColors!.trunks,
          ),
        ),
      ],
    );
  }
}
