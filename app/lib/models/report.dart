enum ReportStatus { sent, received, resolved }

class Report {
  final String id;
  final String title;
  final String category;
  final String date;
  final ReportStatus status;
  final String? description;
  final String? location;
  final bool hasAttachments;
  final String? userId; // Owner of the report

  const Report({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.status,
    this.description,
    this.location,
    this.hasAttachments = false,
    this.userId,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? json['description'] ?? 'No Title',
      category: json['category'] ?? json['aiCategory'] ?? 'General',
      date: json['date'] ?? json['createdAt'] ?? DateTime.now().toString(),
      status: json['status'] is String 
        ? ReportStatus.values.firstWhere(
            (e) => e.name == json['status'],
            orElse: () => ReportStatus.sent,
          )
        : ReportStatus.sent,
      description: json['description'],
      location: json['location'] is Map ? 'Location Set' : json['location']?.toString(), // Handle GeoJSON
      hasAttachments: json['hasAttachments'] ?? (json['imageUrl'] != null),
      userId: json['userId'] ?? (json['createdBy'] is Map ? json['createdBy']['_id'] : json['createdBy']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date,
      'status': status.name,
      'description': description,
      'location': location,
      'hasAttachments': hasAttachments,
      'userId': userId,
    };
  }
}
