import 'package:flutter/material.dart';

const _purple = Color(0xFF7936FF);
const _text = Color(0xFF0F0F0F);
const _border = Color(0xFFE6E6E6);

class AboutStorySheet extends StatelessWidget {
  const AboutStorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const AboutStorySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'About this story',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _text,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          const _Section(
            label: 'HOW THIS STORY IS CREATED',
            body:
                "The development story looks at how a player has been playing across their last five games, not just the most recent. It weighs efficiency, playmaking, effort and disruption, and how those are trending. An AI model reads those signals and writes a short, parent-friendly story about what's clicking, where there's room to grow, and one moment to watch for at the next game.",
          ),
          const SizedBox(height: 20),
          const _Section(
            label: 'WHY IT CHANGES',
            body:
                "Because the story is based on a rolling window of the last five games, every new game you log can nudge the story in a new direction. A strong scoring stretch might give way to a playmaking one. Something that was growing might start clicking. The story is meant to follow a player as they develop, not lock them into a label.",
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.body});
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _purple,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: _text,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
