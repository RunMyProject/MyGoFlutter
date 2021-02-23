class Article {

  final String Id;
  final String Title;
  final String Desc;
  final String Content;

  Article({this.Id, this.Title, this.Desc, this.Content});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
        Id: json['Id'],
        Title: json['Title'],
        Desc: json['Desc'],
        Content: json['Content']
    );
  }

}