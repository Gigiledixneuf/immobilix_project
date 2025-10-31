// create model class for article with toJson and fromJson methods

class Article {
  final int? id;
  final String? title;
  final String? content;

  Article({this.id, this.title, this.content});

  factory Article.fromJson(json) => Article(
        id: json['id'],
        title: json['title'],
        content: json['content'],
      );

  Map toJson() => {
        'id': id,
        'title': title,
        'content': content,
      };
}
