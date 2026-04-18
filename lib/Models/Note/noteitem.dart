class NotesResponse {
  final bool success;
  final int status;
  final String message;
  final NotesData data;

  NotesResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory NotesResponse.fromJson(Map<String, dynamic> json) {
    return NotesResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: NotesData.fromJson(json['response']['data']),
    );
  }
}

class NotesData {
  final List<NoteModel> docs;
  final int totalDocs;
  final int limit;
  final int page;
  final int totalPages;

  NotesData({
    required this.docs,
    required this.totalDocs,
    required this.limit,
    required this.page,
    required this.totalPages,
  });

  factory NotesData.fromJson(Map<String, dynamic> json) {
    return NotesData(
      docs: (json['docs'] as List<dynamic>)
          .map((e) => NoteModel.fromJson(e))
          .toList(),
      totalDocs: json['totalDocs'] ?? 0,
      limit: json['limit'] ?? 0,
      page: json['page'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}


class NoteModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['createdBy'] ?? '',
    );
  }
}



