import 'package:dio/dio.dart';
import 'package:reafy_front/src/dto/memo_dto.dart';
import 'package:reafy_front/src/dto/memo_dto.dart';
import 'package:reafy_front/src/utils/api.dart';
import 'package:path/path.dart' as path;

final Dio authdio = authDio().getDio();

//모든 메모 가져오기
Future<MemoResDto> getMemoList(int page) async {
  try {
    final response = await authdio.get('${baseUrl}/memo?page=$page');

    if (response.statusCode == 200) {
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
  try {
    final response = await authdio.get(
      '${baseUrl}/memo/hashtag',
      queryParameters: {
        'hashtag': hashtag,
        'page': page,
      },
    );

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
  try {
    final response =
        await authdio.get('${baseUrl}/memo/bookshelfbook', queryParameters: {
      'bookshelfBookId': bookshelfBookId,
      'page': page,
    }, options: Options(
      validateStatus: (status) {
        // 404때 throw 하지 않도록
        return status! < 500;
      },
    ));

    if (response.statusCode == 200) {
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
  try {
    final response = await authdio.get(
      '${baseUrl}/memo/$memoId',
    );

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
Future<Memo> createMemo(int bookshelfBookId, String content, int page,
    String hashtag, String? file) async {
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

    final response = await authdio.post(
      '${baseUrl}/memo',
      data: formData,
    );

    if (response.statusCode == 201) {
      final Memo newMemo = Memo.fromJson(response.data);
      return newMemo;
    } else {
      throw Exception('Failed to create memo');
    }
  } catch (e) {
    throw e;
  }
}

// 메모 수정
Future<Memo> updateMemo(
    int memoId, String content, int page, String hashtag, String? file) async {
  Map<String, dynamic> formDataMap = {
    'memoId': memoId,
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

    final response = await authdio.put(
      '${baseUrl}/memo/$memoId',
      data: formData,
    );
    if (response.statusCode == 200) {
      final Memo updatedMemo = Memo.fromJson(response.data);
      return updatedMemo;
    } else {
      throw Exception('Failed to update memo');
    }
  } catch (e) {
    throw e;
  }
}

// 메모 삭제
Future<void> deleteMemoById(int memoid) async {
  try {
    final response = await authdio.delete(
      '${baseUrl}/memo/$memoid',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete memo');
    }
  } catch (e) {
    throw e;
  }
}
