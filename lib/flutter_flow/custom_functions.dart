import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ff_commons/flutter_flow/lat_lng.dart';
import 'package:ff_commons/flutter_flow/place.dart';
import 'package:ff_commons/flutter_flow/uploaded_file.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/courtside_iq/metrics_config.dart';

double? calculatePlayerFGPercent(
  int? totalFGMade,
  int? totalFGAttempts,
) {
// Add madeTwos and made threes to get totalMade.
  // Add madeTwos, madeThrees, missedTwos, and missedThrees to get totalAttempt.
  // Devide totalMade by totalAttemt and multiply by 100 to get fieldGoalPercent
  if (totalFGMade == null || totalFGAttempts == null) {
    return 0.0;
  }

  if (totalFGAttempts == 0) {
    return 0.0;
  }

  double playerFieldGoalPercent = (totalFGMade / totalFGAttempts) * 100;
  return double.parse(playerFieldGoalPercent.toStringAsFixed(1));
}

int? calculatePlayerAVGBlocks(
  int? totalBlocks,
  int? totalGames,
) {
  // Calculate average points by getting totalPoints divided by total games if it is null return 0
  if (totalBlocks == null || totalGames == null || totalGames == 0) {
    return 0;
  }

  return totalBlocks ~/ totalGames;
}

String? calculate3PTAttemptPercent(
  int? threePTMade,
  int? threePTAttempt,
) {
  // Calculate fg percent from fg made and fg attempts.  Example return should be similar to 5/10 (50%)
  if (threePTMade == null || threePTAttempt == null || threePTAttempt == 0) {
    return null;
  }

  double percent = (threePTMade / threePTAttempt) * 100;
  return '${threePTMade}/${threePTAttempt} (${percent.toStringAsFixed(0)}%)';
}

int? calculatePlayerAVGTurnovers(
  int? totalTurnovers,
  int? totalGames,
) {
// Calculate average points by getting totalPoints divided by total games if it is null return 0
  if (totalTurnovers == null || totalGames == null || totalGames == 0) {
    return 0;
  }

  return totalTurnovers ~/ totalGames;
}

Color? calculateEFFBackground(
  int? points,
  int? offReb,
  int? defReb,
  int? assist,
  int? steal,
  int? block,
  int? fgAttempt,
  int? fgMade,
  int? ftAttempt,
  int? ftMade,
  int? turnover,
) {
  // Calculate effeciencey. If less than 0 color is #0D0D0D. If 0-2 color is #131313. If 3-5 color is #191919. If 6-8 color is #1F1F1F. If 9-11 color is #242424. If 12-14 color is #2A2A2A. If 15-17 color is #303030. If 18 or more color is #363636.
  // Calculate efficiency based on the provided statistics
  int efficiency = (points ?? 0) +
      (offReb ?? 0) +
      (defReb ?? 0) +
      (assist ?? 0) +
      (steal ?? 0) +
      (block ?? 0) -
      ((turnover ?? 0) +
          ((fgAttempt ?? 0) - (fgMade ?? 0)) +
          ((ftAttempt ?? 0) - (ftMade ?? 0)));

  // Determine the color based on the efficiency value
  if (efficiency < 0) {
    return Color(0x34FF5514);
  } else if (efficiency >= 0 && efficiency <= 2) {
    return Color(0xFF1A1A19);
  } else if (efficiency >= 3 && efficiency <= 5) {
    return Color(0xFF262624);
  } else if (efficiency >= 6 && efficiency <= 8) {
    return Color(0xFF33332E);
  } else if (efficiency >= 9 && efficiency <= 11) {
    return Color(0xFF3F3F38);
  } else if (efficiency >= 12 && efficiency <= 14) {
    return Color(0xFF4C4B43);
  } else if (efficiency >= 15 && efficiency <= 17) {
    return Color(0xFF58564D);
  } else {
    return Color(0xFF595854);
  }
}

String? stat2text(
  int points,
  int offReb,
  int defReb,
  int assist,
  int steal,
  int block,
  int fgAttempt,
  int fgMade,
  int ftAttempt,
  int ftMade,
  int turnover,
  String? insights,
  DateTime gameDate,
  String opponent,
  int threeAttempt,
  int threeMade,
  String playerName,
) {
  // I want to create a text string that can be shared by text message. Lead with playerName then next  line/header for game date "vs." the opponent. Add 2 line breaks. Then paragraph for the insights. Add 2 line breaks. Follow a list for game stats list: PTS, REB (offReb+defReb), AST, FG(fgMade/fgAttempt), 3PT(threeMade/threeAttempt), FT(ftMade/ftAttempt), BLK, STL, TO. Only show stats in the list if it's greater than 0.
  StringBuffer sb = StringBuffer();

  // Player name and game date
  sb.writeln(playerName);
  sb.writeln('${DateFormat('yyyy-MM-dd').format(gameDate)} vs. $opponent');
  sb.writeln(); // Two line breaks

  // Insights
  if (insights != null && insights.isNotEmpty) {
    sb.writeln(insights);
    sb.writeln(); // Two line breaks
  }

  // Game stats
  List<String> stats = [];
  if (points > 0) stats.add('PTS: $points');
  if (offReb + defReb > 0) stats.add('REB: ${offReb + defReb}');
  if (assist > 0) stats.add('AST: $assist');
  if (fgAttempt > 0) stats.add('FG: $fgMade/$fgAttempt');
  if (threeAttempt > 0) stats.add('3PT: $threeMade/$threeAttempt');
  if (ftAttempt > 0) stats.add('FT: $ftMade/$ftAttempt');
  if (block > 0) stats.add('BLK: $block');
  if (steal > 0) stats.add('STL: $steal');
  if (turnover > 0) stats.add('TO: $turnover');

  // Join stats with new lines
  sb.writeln(stats.join('\n'));

  return sb.toString();
}

int? calculatePlayerAVGSteals(
  int? totalSteals,
  int? totalGames,
) {
  // Calculate average points by getting totalPoints divided by total games if it is null return 0
  if (totalSteals == null || totalGames == null || totalGames == 0) {
    return 0;
  }

  return totalSteals ~/ totalGames;
}

int? calculatePlayerAVGAssist(
  int? totalAssist,
  int? totalGames,
) {
  // Calculate average points by getting totalPoints divided by total games if it is null return 0
  if (totalAssist == null || totalGames == null || totalGames == 0) {
    return 0;
  }

  return totalAssist ~/ totalGames;
}

int? calculatePlayerAVGRebounds(
  int? totalOffRebs,
  int? totalDefRebs,
  int? totalGames,
) {
  // I need to add both off rebs and def rebs to get the total rebs. the divide total rebs by games played to get the players average rebs
  // Calculate total rebounds by adding offensive rebounds and defensive rebounds
  int totalRebs = (totalOffRebs ?? 0) + (totalDefRebs ?? 0);

  // Calculate average rebounds by dividing total rebounds by total games
  if (totalGames == null || totalGames == 0) {
    return 0;
  }

  return totalRebs ~/ totalGames;
}

double? calculatePlayerFTPercent(
  int? totalFTMade,
  int? totalFTAttempts,
) {
// Add madeTwos and made threes to get totalMade.
  // Add madeTwos, madeThrees, missedTwos, and missedThrees to get totalAttempt.
  // Devide totalMade by totalAttemt and multiply by 100 to get fieldGoalPercent
  if (totalFTMade == null || totalFTAttempts == null) {
    return 0;
  }

  if (totalFTAttempts == 0) {
    return 0;
  }

  double playerFieldGoalPercent = (totalFTMade / totalFTAttempts) * 100;
  return double.parse(playerFieldGoalPercent.toStringAsFixed(1));
}

double? calculatePlayerThreePointPercent(
  int? totalThreeMade,
  int? totalThreeAttempts,
) {
// Add madeTwos and made threes to get totalMade.
  // Add madeTwos, madeThrees, missedTwos, and missedThrees to get totalAttempt.
  // Devide totalMade by totalAttemt and multiply by 100 to get fieldGoalPercent
  if (totalThreeMade == null || totalThreeAttempts == null) {
    return 0;
  }

  if (totalThreeAttempts == 0) {
    return 0;
  }

  double playerFieldGoalPercent = (totalThreeMade / totalThreeAttempts) * 100;
  return double.parse(playerFieldGoalPercent.toStringAsFixed(1));
}

int? calculatePlayerAVGPoints(
  int? totalPoints,
  int? totalGames,
) {
  // Calculate average points by getting totalPoints divided by total games if it is null return 0
  if (totalPoints == null || totalGames == null || totalGames == 0) {
    return 0;
  }

  return totalPoints ~/ totalGames;
}

int? calculateRebGameList(
  int? offReb,
  int? defReb,
) {
  int totalRebounds = (offReb ?? 0) + (defReb ?? 0);

  return totalRebounds;
}

int? calculateEFF(
  int? points,
  int? offReb,
  int? defReb,
  int? assist,
  int? steal,
  int? block,
  int? fgAttempt,
  int? fgMade,
  int? ftAttempt,
  int? ftMade,
  int? turnover,
) {
  if (points == null ||
      offReb == null ||
      defReb == null ||
      assist == null ||
      steal == null ||
      block == null ||
      fgAttempt == null ||
      fgMade == null ||
      ftAttempt == null ||
      ftMade == null ||
      turnover == null) {
    return null;
  }

  int totalPoints = points;
  int totalRebounds = (offReb ?? 0) + (defReb ?? 0);
  int totalAssists = assist;
  int totalSteals = steal;
  int totalBlocks = block;
  int totalMissedFG = fgAttempt - fgMade;
  int totalMissedFT = ftAttempt - ftMade;

  int efficiencyRating =
      (totalPoints + totalRebounds + totalAssists + totalSteals + totalBlocks) -
          (totalMissedFG + totalMissedFT + turnover);

  return efficiencyRating;
}

String? calculateFGMadeAttemptPercent(
  int? fgMade,
  int? fgAttempt,
) {
  // Calculate fg percent from fg made and fg attempts.  Example return should be similar to 5/10 (50%)
  if (fgMade == null || fgAttempt == null || fgAttempt == 0) {
    return null;
  }

  double percent = (fgMade / fgAttempt) * 100;
  return '${fgMade}/${fgAttempt} (${percent.toStringAsFixed(0)}%)';
}

int? calculatePFGameList(
  int? offFoul,
  int? defFoul,
) {
  int totalFouls = (offFoul ?? 0) + (defFoul ?? 0);

  return totalFouls;
}

Color? adjustColorByPercent(
  Color? primaryBGColor,
  double? percent,
) {
  // get primaryBGColor and adjust transparancy/opacity by percent
  if (primaryBGColor == null || percent == null) {
    return null;
  }

  int alpha = (primaryBGColor.alpha * percent).round().clamp(0, 255).toInt();
  return primaryBGColor.withOpacity(alpha / 255.0);
}

int? setStatBar(int? playerStat) {
  // Set the height of container based on playerStat.  Max playerStat is 10. Container max height is 80. If playerStat is equal to or greater than 10, container height is 80.  Exampl, If playerAvgStat is equal to 5, container height is 40.
  if (playerStat == null) {
    return null;
  }

  if (playerStat >= 10) {
    return 80;
  }

  double height = (playerStat / 10) * 80;
  return height.toInt();
}

int? setPTBar(int? playerPTS) {
  // Set the height of container based on the number points player scores. Only track bar up to 30 points max. and the bar max height is 80px. If player points is 30 or greater set bar height is maxed at 80px. (example. 15pts = 40px bar height.
  if (playerPTS == null) {
    return null;
  }

  if (playerPTS >= 30) {
    return 80;
  }

  double barHeight = (playerPTS / 30) * 80;
  return barHeight.toInt();
}

double? setAvgStatBar(double? playerAvgStat) {
  // Set the height of container based on playerAvgStat.  Container max height is 10 playerAvgStat (100%). If playerAvgStat is equal to or greater than 10, container height is 100%. If playerAvgStat is equal to 5, container height is 50%.
  if (playerAvgStat == null) {
    return null;
  }

  double maxHeight = 100.0;
  double percentage = playerAvgStat / 10.0;

  if (playerAvgStat >= 10) {
    return maxHeight;
  } else {
    return maxHeight * percentage;
  }
}

String? generateUniqueId() {
  // generate a unique identifier string in a standard uuid format
  final String uuid =
      '${DateTime.now().millisecondsSinceEpoch}-${math.Random().nextInt(10000)}';
  return uuid;
}

String? firstLetter(String? name) {
  // Return the first letter capitalized for name. If name is empty or null return a dash (-)
  return name?.isNotEmpty == true ? name![0].toUpperCase() : '-';
}

String? getNameForChoiceChip(
  String? firstName,
  String? lastName,
  String? playerID,
) {
  // Check if firstName and lastName are not null
  if (firstName != null && lastName != null) {
    return '$firstName $lastName';
  } else if (firstName != null) {
    return firstName; // Return only firstName if lastName is null
  } else if (lastName != null) {
    return lastName; // Return only lastName if firstName is null
  }
  return null; // Return null if both are null
}

bool? calculateAVGTrend(
  List<int>? shotsMade,
  List<int>? shotsAttempted,
) {
  if (shotsMade == null ||
      shotsAttempted == null ||
      shotsMade.length < 5 ||
      shotsAttempted.length < 5) {
    // Need at least 5 games to compare two rolling averages
    return null;
  }

  // Helper to calculate a 3-game rolling average at a given index
  double rollingAt(int endIndex) {
    double totalPercent = 0.0;
    for (int i = endIndex - 2; i <= endIndex; i++) {
      if (shotsAttempted[i] > 0) {
        totalPercent += shotsMade[i] / shotsAttempted[i];
      }
    }
    return totalPercent / 3;
  }

  // Compare the last 2 rolling averages
  double previous = rollingAt(shotsMade.length - 2);
  double recent = rollingAt(shotsMade.length - 1);

  return recent > previous;
}

String? getIndexPlusOne(int? indexValue) {
  // Get the item index value from the list and add 1. Return the new value.
  if (indexValue == null) {
    return null; // Return null if indexValue is null
  }
  return (indexValue + 1)
      .toString(); // Add 1 to indexValue and return as string
}

bool? hideAddGame(
  bool premiumStatus,
  int gameTotal,
  int playerCount,
) {
  // First I want to check if premium Status is false and game total is more than two, return false. Second if premium status is false and player count is greater than 1, return false. Else return true.
  if (!premiumStatus && gameTotal > 2) {
    return false;
  }
  if (!premiumStatus && playerCount > 1) {
    return false;
  }
  return true;
}

Color? bgBlur(Color? background) {
  // With the selected background color, add a 4px blur
  if (background == null) return null;
  return background.withOpacity(0.5); // Adjust opacity for blur effect
}

DateTime? convertExpDate(DateTime? dateCreated) {
  // Convert the dateCreated to a date that is 5 days later (m/dd). This will be the expirations date.
  if (dateCreated == null) return null; // Check for null input
  return dateCreated.add(Duration(days: 5)); // Add 5 days to the dateCreated
}

double ppsa(
  int fgAttempted,
  int ftAttempted,
  int? points,
) {
  if (fgAttempted == 0) return 0.0;
  double effectiveFgAttempted = 0.44 * ftAttempted;
  return points != null ? points / (fgAttempted + effectiveFgAttempted) : 0.0;
}

String? ast2tov(
  int? assist,
  int? turnover,
) {
  // Assist-to-turnover ratio + turnovers per game (example: 2-to-1 , 1-to-1, or 1-to-2). Return string based on examples.
  if (assist == null || turnover == null) return null;

  // Check both-zero FIRST (more specific case)
  if (assist == 0 && turnover == 0) return null;

  // Then handle zero turnovers (assist must be > 0 if we get here)
  if (turnover == 0) return '${assist}:0';

  int a = assist.abs();
  int t = turnover.abs();

  int gcd(int x, int y) {
    while (y != 0) {
      final temp = x % y;
      x = y;
      y = temp;
    }
    return x;
  }

  final g = gcd(a, t);
  final simplifiedA = a ~/ g;
  final simplifiedT = t ~/ g;

  return '$simplifiedA:$simplifiedT';
}

bool ast2tovActive(
  int? assist,
  int? turnover,
) {
  if (assist == null || turnover == null || assist < kAstTovMinAssists) {
    return false;
  }
  return true;
}

bool ast2tovGood(
  int? assist,
  int? turnover,
) {
  if (assist == null || turnover == null) return false;
  if (assist == 0) return false;

  if (turnover == 0) {
    return assist >= 1 && assist < kAstTovMinAssists;
  }

  final double ratio = assist / turnover;
  return ratio >= kAstTovGoodMin && ratio < kAstTovEliteMin;
}

bool ast2tovElite(
  int? assist,
  int? turnover,
) {
  if (assist == null || turnover == null) return false;
  if (assist == 0) return false;

  if (turnover == 0) {
    return assist >= kAstTovMinAssists;
  }

  return (assist / turnover) >= kAstTovEliteMin;
}

bool ast2tovSolid(
  int? assist,
  int? turnover,
) {
  if (assist == null || turnover == null) return false;
  if (turnover == 0) return false;
  if (assist == 0) return false;

  final double ratio = assist / turnover;
  return ratio > 0.0 && ratio < kAstTovGoodMin;
}

int? disrupt(
  int? steals,
  int? blocks,
  int? oreb,
  int? dreb,
) {
  if (steals == null || blocks == null || oreb == null || dreb == null) {
    return null;
  }

  return ((oreb * kDisruptWeightOreb) +
          (steals * kDisruptWeightSteals) +
          (blocks * kDisruptWeightBlocks) +
          (dreb * kDisruptWeightDreb))
      .round();
}

bool disruptActive(
  int? steals,
  int? blocks,
  int? oreb,
  int? dreb,
) {
  if (steals == null || blocks == null || oreb == null || dreb == null) {
    return false;
  }

  return ((oreb * kDisruptWeightOreb) +
              (steals * kDisruptWeightSteals) +
              (blocks * kDisruptWeightBlocks) +
              (dreb * kDisruptWeightDreb))
          .round() >=
      kDisruptActiveMin;
}

bool disruptGood(int? disrupt) {
  return disrupt != null &&
      disrupt >= kDisruptGoodMin &&
      disrupt <= kDisruptGoodMax;
}

bool disruptElite(int? disrupt) {
  return disrupt != null && disrupt >= kDisruptEliteMin;
}

bool disruptSolid(int? disrupt) {
  return disrupt != null && disrupt <= kDisruptSolidMax;
}

bool ppsaSolid(double ppsa) {
  return ppsa >= kPpsaSolidMin && ppsa < kPpsaGoodMin;
}

bool ppsaElite(double ppsa) {
  return ppsa >= kPpsaEliteMin;
}

bool ppsaActive(
  double ppsa,
  int? shotAttempts,
) {
  if (shotAttempts == null || shotAttempts < kPpsaMinAttempts) {
    return false;
  }
  return ppsa >= kPpsaSolidMin;
}

bool ppsaGood(double ppsa) {
  return ppsa >= kPpsaGoodMin && ppsa < kPpsaEliteMin;
}

bool? checkDateThreshold(
  DateTime? date,
  int? threshold,
) {
// Check if todays is at least number of days past the threshold. If yes, return true. No, return false.
  if (date == null || threshold == null) return null; // Check for null values
  DateTime today = DateTime.now(); // Get today's date
  Duration difference = today.difference(date); // Calculate the difference
  return difference.inDays >=
      threshold; // Check if the difference is greater than or equal to the threshold
}

int playerTileWidth(int playerNum) {
  // Get current device screen width in pixels (px) and subtract by 48px. Take the remaining total, and subtract (playerNum * 2), then divide by playerNum. If playerNum = 2 subtract 6, or If playerNum = 3 subtract 12. Return a number.
  double screenWidth = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
      .size
      .width; // Get screen width
  double width = screenWidth - 48; // Subtract 48px
  width -= playerNum == 2
      ? 6
      : playerNum == 3
          ? 12
          : 0; // Subtract based on playerNum
  return (width / playerNum)
      .round(); // Divide by playerNum and return as integer
}

List<DateTime>? getUniqueDates(
  List<DateTime>? dates,
  List<String>? playerIds,
  String? selectedPlayer,
) {
  if (dates == null || dates.isEmpty) return [];

  final bool hasPlayerFilter = selectedPlayer != null &&
      selectedPlayer.trim().isNotEmpty &&
      selectedPlayer != 'All Players';

  final seen = <String>{};
  final unique = <DateTime>[];

  for (int i = 0; i < dates.length; i++) {
    if (hasPlayerFilter) {
      if (playerIds == null ||
          i >= playerIds.length ||
          playerIds[i] != selectedPlayer) {
        continue;
      }
    }

    final d = dates[i];
    final key = '${d.year}-${d.month}-${d.day}';
    if (seen.add(key)) {
      unique.add(d);
    }
  }

  return unique;
}

List<VPlayerGameStatsRow>? getGamesList(
  String? selectedPlayer,
  DateTime? selectedDate,
  List<VPlayerGameStatsRow>? games,
) {
  if (games == null || games.isEmpty) return [];

  final bool hasPlayerFilter = selectedPlayer != null &&
      selectedPlayer.trim().isNotEmpty &&
      selectedPlayer != 'All Players';

  final DateTime? filterDate = selectedDate;

  return games.where((g) {
    if (hasPlayerFilter && g.playerId != selectedPlayer) {
      return false;
    }

    if (filterDate != null) {
      final d = g.createdAt;
      if (d == null) return false;
      if (d.year != filterDate.year ||
          d.month != filterDate.month ||
          d.day != filterDate.day) {
        return false;
      }
    }

    return true;
  }).toList();
}
