//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

class Info {
  final String? picture;
  final List<Link>? greeting;
  final List<Link>? career;
  final List<Link>? contact;

  const Info({
    this.picture,
    this.greeting,
    this.career,
    this.contact,
  });

  Info copyWith({
    String? picture,
    List<Link>? greeting,
    List<Link>? career,
    List<Link>? contact,
  }) {
    return Info(
      picture: picture ?? this.picture,
      greeting: greeting ?? this.greeting,
      career: career ?? this.career,
      contact: contact ?? this.contact,
    );
  }

  Info.fromJson(Map<String, dynamic> data)
      : picture = data['picture'],
        greeting = data['greeting'],
        career = data['career'],
        contact = data['contact'];

  Map<String, dynamic> toJson() => {
        'picture': picture,
        'greeting': greeting,
        'career': career,
        'contact': contact,
      };
}

// Link is a additional URL passing structure for the info.
// If the [URL] is empty, link represents non-linkable simple text element.
// And, if title is empty, link represents empty line.
class Link {
  // title is the main domain of [Link] structure.
  final String? title;

  // The reference URL provider for [title].
  // same approach of `<a href="http://">{Title}</a>`
  // but in dart class model.
  final String? url;

  // style is a font-style identifier of [title] field.
  // Could be:
  //  - bold
  //  - italic
  //  - strong
  //  - p -> <p>{}</p>
  final String? style;

  // The sub links of current link.
  final List<Link>? children;

  const Link({this.title, this.url, this.style, this.children});

  Link copyWith({
    String? title,
    String? url,
    String? style,
    List<Link>? children,
  }) {
    return Link(
      title: title ?? this.title,
      url: url ?? this.url,
      style: style ?? this.style,
      children: children ?? this.children,
    );
  }

  Link.fromJson(Map<String, dynamic> data)
      : title = data['title'],
        url = data['url'],
        style = data['style'],
        children = data['children'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'style': style,
        'children': children,
      };
}
