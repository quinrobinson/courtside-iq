import 'package:flutter/material.dart';
import 'set_birth_date_sheet.dart';

const _bannerBg   = Color(0xFFE0F7F4);
const _bannerText = Color(0xFF108A7C);

const _fontIBMPlexSans = 'IBM Plex Sans';

class BirthDateProfileBanner extends StatelessWidget {
  const BirthDateProfileBanner({
    super.key,
    required this.playerId,
    required this.playerFirstName,
    this.onSaved,
  });

  final String playerId;
  final String playerFirstName;
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showSetBirthDateSheet(
        context,
        playerId: playerId,
        playerFirstName: playerFirstName,
        onSaved: onSaved,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _bannerBg,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'Set birth year for age-appropriate ratings',
                style: TextStyle(
                  fontFamily: _fontIBMPlexSans,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _bannerText,
                ),
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.arrow_forward,
              size: 18,
              color: _bannerText,
            ),
          ],
        ),
      ),
    );
  }
}
