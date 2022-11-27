//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

class Info {
  final String? picture;
  final List<dynamic>? greeting;
  final List<dynamic>? career;
  final List<dynamic>? contact;

  const Info({
    this.picture,
    this.greeting,
    this.career,
    this.contact,
  });

  Info copyWith({
    String? picture,
    List<dynamic>? greeting,
    List<dynamic>? career,
    List<dynamic>? contact,
  }) {
    return Info(
      picture: picture ?? this.picture,
      greeting: greeting ?? this.greeting,
      career: career ?? this.career,
      contact: contact ?? this.contact,
    );
  }

  /// Merges the current info([this]) with given [info] model.
  Info mergeWith(Info info) {
    return Info(
      picture: info.picture ?? picture,
      greeting: info.greeting ?? greeting,
      career: info.career ?? career,
      contact: info.contact ?? contact,
    );
  }

  /// Removes the given field from the current([this]) info model.
  Info removeField(String field) {
    switch (field) {
      case 'picture':
        return mergeWith(const Info(picture: ''));
      case 'greeting':
        return mergeWith(const Info(greeting: []));
      case 'career':
        return mergeWith(const Info(career: []));
      case 'contact':
        return mergeWith(const Info(contact: []));
      default:
        return this;
    }
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
  // title is the main domain of [dynamic] structure.
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

  // The sub links of current dynamic.
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
