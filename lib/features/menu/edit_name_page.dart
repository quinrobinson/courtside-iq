// Edit Name — Phase 4.15b
//
// Measured from 496:1952: sub-page header "Edit name", a single Field with
// the label ABOVE the input, and a lime "Save changes" button.
//
// THE FRAME DRAWS ONE FIELD, "FULL NAME". The table has first_name and
// last_name, and v1 collected them separately. One field is the better
// screen - a parent typing their own name does not want two boxes - so the
// split happens on save: everything before the last space is the first name.
//
// That is lossy for a name like "Ana Maria Diaz Lopez", which becomes
// first "Ana Maria Diaz" and last "Lopez". It round-trips exactly, which is
// what matters here: nothing in the app displays the halves separately.
//
// SAVE IS DISABLED UNTIL SOMETHING CHANGES, matching v1. An enabled button
// that does nothing is a worse answer than a disabled one.

import 'package:flutter/material.dart';

import '/courtside_iq/design/ci_theme.dart';
import '/courtside_iq/design/components/ci_button.dart';
import '/courtside_iq/design/components/ci_field.dart';
import '/courtside_iq/design/components/ci_sub_page_header.dart';
import '/courtside_iq/design/tokens/ci_colors.dart';
import '/courtside_iq/design/tokens/ci_metrics.dart';
import 'account_repository.dart';
import 'ci_account_snackbar.dart';

class EditNamePage extends StatefulWidget {
  const EditNamePage({
    super.key,
    this.repository = const AccountRepository(),
    this.onSaved,
  });

  final AccountRepository repository;
  final VoidCallback? onSaved;

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  final _controller = TextEditingController();
  String _original = '';
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await widget.repository.load();
    if (!mounted) return;
    setState(() {
      _original = profile.fullName;
      _controller.text = _original;
      _loaded = true;
    });
  }

  bool get _dirty => _controller.text.trim() != _original.trim();
  bool get _valid => _controller.text.trim().isNotEmpty;

  Future<void> _save() async {
    final full = _controller.text.trim();
    setState(() => _saving = true);

    // Split at the LAST space. "Alex Rivera" -> Alex / Rivera; "Alex" ->
    // Alex / empty, which the table allows.
    final cut = full.lastIndexOf(' ');
    final first = cut == -1 ? full : full.substring(0, cut).trim();
    final last = cut == -1 ? '' : full.substring(cut + 1).trim();

    await widget.repository.updateName(firstName: first, lastName: last);
    if (!mounted) return;

    widget.onSaved?.call();
    Navigator.of(context).maybePop();
    showAccountResult(context, message: 'Your name has been updated.');
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
                const CiSubPageHeader(title: 'Edit name'),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                        CiSpace.screen, CiSpace.s6, CiSpace.screen, CiSpace.s6),
                    children: [
                      CiField(
                        label: 'Full name',
                        controller: _controller,
                        enabled: _loaded,
                        keyboardType: TextInputType.name,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 48),
                      CiButton(
                        label: 'Save changes',
                        style: CiButtonStyle.lime,
                        expand: true,
                        busy: _saving,
                        // Disabled until something actually changed, matching
                        // v1. A button that saves an unchanged name is noise.
                        onPressed:
                            _dirty && _valid && !_saving ? _save : null,
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
