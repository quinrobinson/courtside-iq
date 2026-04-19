import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'package:ff_commons/api_requests/api_manager.dart';

import 'package:ff_commons/api_requests/api_paging_params.dart';

export 'package:ff_commons/api_requests/api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class GetGameInsightsCall {
  static Future<ApiCallResponse> call({
    int? fgMade,
    int? fgAttempt,
    int? ftMade,
    int? ftAttempt,
    int? threeMade,
    int? threeAttempt,
    int? offReb,
    int? defReb,
    int? assist,
    int? steal,
    int? turnover,
    int? block,
    int? offFoul,
    int? defFoul,
    String? gameId = '',
    String? playerId = '',
    int? points,
  }) async {
    final ffApiRequestBody = '''
{
  "points": ${points},
  "fg_made": ${fgMade},
  "fg_attempt": ${fgAttempt},
  "ft_made": ${ftMade},
  "ft_attempt": ${ftAttempt},
  "three_made": ${threeMade},
  "three_attempt": ${threeAttempt},
  "off_reb": ${offReb},
  "def_reb": ${defReb},
  "assist": ${assist},
  "steal": ${steal},
  "turnover": ${turnover},
  "block": ${block},
  "off_foul": ${offFoul},
  "def_foul": ${defFoul},
  "game_id": "${gameId}",
  "player_id": "${playerId}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetGameInsights',
      apiUrl: 'https://nni3ua.buildship.run/gameinsights',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic points(dynamic response) => getJsonField(
        response,
        r'''$.points''',
      );
  static dynamic fgmade(dynamic response) => getJsonField(
        response,
        r'''$.fg_made''',
      );
  static dynamic fgattempt(dynamic response) => getJsonField(
        response,
        r'''$.fg_attempt''',
      );
  static dynamic ftmade(dynamic response) => getJsonField(
        response,
        r'''$.ft_made''',
      );
  static dynamic ftattempt(dynamic response) => getJsonField(
        response,
        r'''$.ft_attempt''',
      );
  static dynamic threemade(dynamic response) => getJsonField(
        response,
        r'''$.three_made''',
      );
  static dynamic threeattempt(dynamic response) => getJsonField(
        response,
        r'''$.three_attempt''',
      );
  static dynamic offreb(dynamic response) => getJsonField(
        response,
        r'''$.off_reb''',
      );
  static dynamic defreb(dynamic response) => getJsonField(
        response,
        r'''$.def_reb''',
      );
  static dynamic assist(dynamic response) => getJsonField(
        response,
        r'''$.assist''',
      );
  static dynamic steal(dynamic response) => getJsonField(
        response,
        r'''$.steal''',
      );
  static dynamic turnover(dynamic response) => getJsonField(
        response,
        r'''$.turnover''',
      );
  static dynamic block(dynamic response) => getJsonField(
        response,
        r'''$.block''',
      );
  static dynamic offfoul(dynamic response) => getJsonField(
        response,
        r'''$.off_foul''',
      );
  static dynamic deffoul(dynamic response) => getJsonField(
        response,
        r'''$.def_foul''',
      );
  static dynamic gameid(dynamic response) => getJsonField(
        response,
        r'''$.game_id''',
      );
  static dynamic playerid(dynamic response) => getJsonField(
        response,
        r'''$.player_id''',
      );
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}
