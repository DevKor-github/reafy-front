import 'package:dio/dio.dart';
import 'package:reafy_front/src/models/memo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class MemoResDto {
  final int totalItems;
  final int currentItems;
  final int totalPages;
  final int currentPage;
  final List<Memo> items;

  MemoResDto({
    required this.totalItems,
    required this.currentItems,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory MemoResDto.fromJson(Map<String, dynamic> json) {
    return MemoResDto(
      totalItems: json['totalItems'],
      currentItems: json['currentItems'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      items: List<Memo>.from(json['item'].map((item) => Memo.fromJson(item))),
    );
  }
  factory MemoResDto.empty() {
    return MemoResDto(
      totalItems: 0,
      currentItems: 0,
      totalPages: 0,
      currentPage: 0,
      items: [],
    );
  }
}

//모든 메모 가져오기
Future<MemoResDto> getMemoList(int page) async {
  final dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userToken = prefs.getString('token');

  try {
    final response = await dio.get('https://reafydevkor.xyz/memo?page=$page',
        options: Options(headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json'
        }));

    if (response.statusCode == 200) {
      /*final List<dynamic> memoList = response.data;
      print(response.data);
      return memoList;*/
      var memoResults = MemoResDto.fromJson(response.data);
      return memoResults;
    } else {
      throw Exception('Failed to load memo list');
    }
  } catch (e) {
    throw e;
  }
}

//해시태그 메모 가져오기
Future<List<dynamic>> getMemoListByHashtag(String hashtag, int page) async {
  final dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userToken = prefs.getString('token');

  try {
    final response = await dio.get('https://reafydevkor.xyz/memo/hashtag',
        queryParameters: {
          'hashtag': hashtag,
          'page': page,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        }));

    if (response.statusCode == 200) {
      final List<dynamic> memoList = response.data;
      return memoList;
    } else {
      throw Exception('Failed to load memo list');
    }
  } catch (e) {
    throw e;
  }
}

// 해당 책에 쓰인 모든 메모 가져오기
Future<MemoResDto> getMemoListByBookId(int bookshelfBookId, int page) async {
  final dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userToken = prefs.getString('token');

  try {
    final response = await dio.get('https://reafydevkor.xyz/memo/bookshelfbook',
        queryParameters: {
          'bookshelfBookId': bookshelfBookId,
          'page': page,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            // 404때 throw 하지 않도록
            return status! < 500;
          },
        ));

    if (response.statusCode == 200) {
      /*final List<dynamic> memoList = (response.data['memoList'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      return memoList;*/

      var memoResults = MemoResDto.fromJson(response.data);
      return memoResults;
    } else if (response.statusCode == 404) {
      return MemoResDto.empty();
    } else {
      throw Exception('Failed to load bookshelf books');
    }
  } catch (e) {
    throw e;
  }
}

// 특정 메모의 정보 받아오기
Future<Map<String, dynamic>> getMemoDetails(int memoId) async {
  final dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userToken = prefs.getString('token');

  try {
    final response = await dio.get('https://reafydevkor.xyz/memo/$memoId',
        options: Options(headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        }));

    if (response.statusCode == 200) {
      final Map<String, dynamic> memoDetails = response.data;
      return memoDetails;
    } else {
      throw Exception('Failed to load memo details');
    }
  } catch (e) {
    throw e;
  }
}

// 메모 작성
Future<void> createMemo(int bookshelfBookId, String content, int page,
    String hashtag, String? file) async {
  final dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userToken = prefs.getString('token');

  //String fileName = path.basename(file);

  Map<String, dynamic> formDataMap = {
    'bookshelfBookId': bookshelfBookId,
    'content': content,
    'page': page,
    'hashtag': hashtag,
  };

  if (file != null) {
    String fileName = path.basename(file);
    formDataMap['file'] =
        await MultipartFile.fromFile(file, filename: fileName);
  }

  try {
    final formData = FormData.fromMap(formDataMap);
    formData.fields.forEach((element) {
      print('${element.key}: ${element.value}');
    });
    if (file != null) {
      formData.files.forEach((element) {
        print('${element.key}: ${element.value.filename}');
      });
    }

    final response = await dio.post('https://reafydevkor.xyz/memo',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
          },
        ));

    if (response.statusCode != 201) {
      throw Exception('Failed to create memo');
    }
  } catch (e) {
    throw e;
  }
}

// 메모 수정
Future<void> updateMemo(
    int memoid, String content, int page, String hashtag, String file) async {
  final dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userToken = prefs.getString('token');

  try {
    final formData = FormData.fromMap({
      'content': content,
      'page': page,
      'hashtag': hashtag,
      'file': await MultipartFile.fromFile(file, filename: 'memo_image.png'),
    });

    final response = await dio.post('https://reafydevkor.xyz/memo/$memoid',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $userToken',
          },
        ));

    if (response.statusCode != 204) {
      throw Exception('Failed to update memo');
    }
  } catch (e) {
    throw e;
  }
}

// 메모 삭제
Future<void> deleteMemoById(int memoid) async {
  final dio = Dio();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userToken = prefs.getString('token');

  try {
    final response = await dio.delete('https://reafydevkor.xyz/memo/$memoid',
        options: Options(headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        }));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete memo');
    }
  } catch (e) {
    throw e;
  }
}
