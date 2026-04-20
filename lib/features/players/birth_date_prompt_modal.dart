import 'package:flutter/material.dart';
import 'birth_date_prompt_service.dart';
import 'set_birth_date_sheet.dart';

const _modalBg     = Color(0xFFFFFFFF);
const _titleColor  = Color(0xFF1A1A1A);
const _bodyColor   = Color(0xFF787878);
const _btnBg       = Color(0xFF1A1A1A);
const _btnText     = Color(0xFFFFFFFF);
const _linkColor   = Color(0xFF787878);

const _fontMontserrat  = 'Montserrat';
const _fontIBMPlexSans = 'IBM Plex Sans';

Future<void> showBirthDatePromptModal(
  BuildContext context, {
  required String playerId,
  required String playerFirstName,
  VoidCallback? onSaved,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => BirthDatePromptModal(
      playerId: playerId,
      playerFirstName: playerFirstName,
      onSaved: onSaved,
    ),
  );
}

class BirthDatePromptModal extends StatelessWidget {
  const BirthDatePromptModal({
    super.key,
    required this.playerId,
    required this.playerFirstName,
    this.onSaved,
  });

  final String playerId;
  final String playerFirstName;
  final VoidCallback? onSaved;

  Future<void> _handleRemindLater(BuildContext context) async {
    await BirthDatePromptService.markModalDismissed(playerId);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _handleSetBirthYear(BuildContext context) async {
    await BirthDatePromptService.markModalDismissed(playerId);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    await showSetBirthDateSheet(
      context,
      playerId: playerId,
      playerFirstName: playerFirstName,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: _modalBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Help us improve $playerFirstName's ratings",
              style: const TextStyle(
                fontFamily: _fontMontserrat,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _titleColor,
                height: 1.44,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Add $playerFirstName's birth year so Courtside IQ can give age-appropriate ratings compared to players in the same age group.",
              style: const TextStyle(
                fontFamily: _fontIBMPlexSans,
                fontSize: 14,
                color: _bodyColor,
                height: 1.43,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => _handleSetBirthYear(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _btnBg,
                  foregroundColor: _btnText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Set birth year',
                  style: TextStyle(
                    fontFamily: _fontIBMPlexSans,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _handleRemindLater(context),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Remind me later',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _fontIBMPlexSans,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _linkColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
