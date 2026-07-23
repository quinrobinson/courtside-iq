// Send Feedback — Phase 4.15c
//
// Measured from 508:1972: header "Send feedback", an intro at Regular 15,
// four category chips at Medium 14, a "MESSAGE" label over a multi-line
// field, then a lime "Send feedback".
//
// NO EMAIL FIELD, which v1 had. The signed-in address is already the right
// one, a typo in a hand-typed one makes a reply impossible, and every field
// removed from a feedback form is a reason more people finish it.
//
// THE CONFIRMATION IS A SHEET (667:2553), not a snackbar. Feedback is the one
// thing here that goes somewhere a parent cannot check afterwards - the table
// is insert-only, so there is no sent-items list - and a message that
// vanishes in three seconds is a poor receipt for something they took time to
// write.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_sub_page_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import '/courtside_iq/design/tokens/ci_type.dart';
import 'ci_account_snackbar.dart';
import 'feedback_repository.dart';
import 'feedback_sent_sheet.dart';

class SendFeedbackPage extends StatefulWidget {
  const SendFeedbackPage({
    super.key,
    this.repository = const FeedbackRepository(),
  });

  final FeedbackRepository repository;

  @override
  State<SendFeedbackPage> createState() => _SendFeedbackPageState();
}

class _SendFeedbackPageState extends State<SendFeedbackPage> {
  final _message = TextEditingController();

  /// Idea is preselected, as the frame draws it. A form that opens with
  /// nothing chosen asks a question before the one it actually wants
  /// answered, and Idea is the least loaded default.
  FeedbackCategory _category = FeedbackCategory.idea;
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final ok = await widget.repository.send(
      category: _category,
      message: _message.text,
    );
    if (!mounted) return;

    if (!ok) {
      setState(() => _sending = false);
      // The message STAYS. They took time to write it, and losing it to a
      // failed request would be the app's fault landing on them.
      showAccountResult(context,
          message: "That didn't send. Check your connection and try again.",
          success: false);
      return;
    }

    // Stop the spinner BEFORE the sheet. Left running it spins for as long
    // as the confirmation is open, which is a button still working on
    // something that has already finished.
    setState(() => _sending = false);
    await showFeedbackSentSheet(context);
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return CiSurface.light(
      child: Builder(builder: (context) {
        final c = CiColors.of(context);
        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const CiSubPageHeader(title: 'Send feedback'),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                        CiSpace.screen, CiSpace.s5, CiSpace.screen, CiSpace.s6),
                    children: [
                      Text(
                        "Tell us what's working or what's missing. We read "
                        'every note.',
                        style: CiType.body.copyWith(color: c.textSoft),
                      ),
                      const SizedBox(height: CiSpace.s5),
                      Wrap(
                        spacing: CiSpace.s2,
                        runSpacing: CiSpace.s2,
                        children: [
                          for (final category in FeedbackCategory.values)
                            CiChip(
                              label: category.label,
                              selected: _category == category,
                              onTap: () =>
                                  setState(() => _category = category),
                            ),
                        ],
                      ),
                      const SizedBox(height: CiSpace.s5),
                      CiField(
                        label: 'Message',
                        controller: _message,
                        placeholder: 'Share a bug, an idea, or a question. '
                            'The more detail, the better.',
                        maxLines: 6,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: CiSpace.s8),
                      CiButton(
                        label: 'Send feedback',
                        style: CiButtonStyle.lime,
                        expand: true,
                        busy: _sending,
                        // An empty note is not feedback, and sending one
                        // wastes the trip for both sides.
                        onPressed: _message.text.trim().isEmpty || _sending
                            ? null
                            : _send,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
