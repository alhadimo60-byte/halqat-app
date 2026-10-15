import 'package:flutter/material.dart';

class DeveloperLogo extends StatelessWidget {
  const DeveloperLogo({
    super.key,
    this.onDarkBackground = false,
    this.compact = false,
  });

  final bool onDarkBackground;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foreground =
        onDarkBackground ? Colors.white : const Color(0xFF065F46);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 8,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: onDarkBackground
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: onDarkBackground
              ? Colors.white.withValues(alpha: 0.28)
              : const Color(0xFFD1FAE5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 23 : 28,
            height: compact ? 23 : 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF047857),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              'H',
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 15 : 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: compact ? 5 : 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'H.Alhadi',
                style: TextStyle(
                  color: foreground,
                  fontSize: compact ? 11 : 13,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 3),
                Text(
                  'DEVELOPER',
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.72),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    height: 1,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
