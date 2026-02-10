---
title: Highlighting HTML in Flutter
date: 2026-02-11
description: Cross-element text highlighting over arbitrary HTML using DOM tree manipulation, bidirectional text mapping, and fuzzy anchor resolution.
---

Highlighting text in HTML sounds trivial until you actually try it. The naive approach is to take the HTML string, find the substring you want to highlight, and wrap it in a `<span>` with a background color. This works for about five minutes — specifically until your HTML contains anything more complex than a single `<p>` tag. Consider a user who selects text starting in the middle of a `<strong>` element and ending outside of it. If you try to wrap that selection in a `<span>`, you produce something like `<strong>some <span class="hl">bold</strong> and normal</span>` text, which has overlapping tags. This is illegal HTML. Browsers and rendering engines will silently rearrange the DOM to fix it, producing a result that looks nothing like what you intended. The highlight ends up in the wrong place, or covers the wrong text, or breaks the formatting entirely. And that is the simplest failure case. Real article HTML contains nested blockquotes, ordered and unordered lists, tables, code blocks inside `<pre>` tags, links with `<a>` tags, and deeply nested inline formatting. A highlight that starts in one `<li>` and ends in another cannot be represented by a single wrapper element at all, because those list items are siblings and no single element can legally span across both of their contents.

The root of the problem is that most approaches treat HTML as a string when it is actually a tree. The HTML you see in source form — `<p>Hello <strong>world</strong></p>` — is a serialization of a tree structure where the `<p>` element is a parent node containing a text node "Hello ", a `<strong>` element child, and that child in turn contains its own text node "world". To highlight safely you need to parse the HTML into this tree form, find the right text nodes, split them at the right positions, wrap the highlighted portions in new elements, and then serialize the modified tree back to a string. Sounds straightforward, but the engineering challenge lies in two places: first, building a reliable bidirectional mapping between the flat plain text a user sees (and selects from) and the tree-structured DOM where those characters actually live, and second, making the highlights persistent so they can be stored in a database, restored days later, and correctly re-applied even if the article content has changed slightly.

Let us start with the first problem: bridging the gap between plain text positions and DOM nodes. When a user selects text in a rendered article, you get character offsets in the visible plain text. But that plain text is scattered across many text nodes in the DOM tree. The word "world" might live inside `/body/p[0]/strong[0]/text()[0]` while the word "Hello" lives in `/body/p[0]/text()[0]`. To map between these two worlds, you need to walk the entire DOM tree depth-first, collect every text node, record its content, and track where each node's text starts and ends in the concatenated plain text. Each collected node gets stored as a record that looks like this:

```dart
class TextNodeInfo {
  const TextNodeInfo({
    required this.node,
    required this.path,
    required this.plainTextStart,
    required this.plainTextEnd,
    required this.text,
  });

  final dom.Text node;
  final NodePath path;
  final int plainTextStart;
  final int plainTextEnd;
  final String text;

  bool containsPosition(int position) {
    return position >= plainTextStart && position < plainTextEnd;
  }

  bool overlapsRange(int start, int end) {
    return plainTextEnd > start && plainTextStart < end;
  }
}
```

The `containsPosition` check uses a half-open range (inclusive start, exclusive end) so that a position exactly at a node boundary belongs to the node that starts there, not the one that ended. The `overlapsRange` check is the standard interval overlap test. These two methods are the workhorses of every subsequent lookup. The complete collection of these records, alongside the concatenated plain text string, forms what we can call a text map — the bidirectional bridge between the flat text world and the DOM tree.

Building this map requires care around block-level elements. The traversal itself is a recursive walk that handles text nodes and element nodes differently:

```dart
void _traverse(dom.Node node, List<TextNodeInfo> textNodes, StringBuffer plainText) {
  if (node is dom.Text) {
    final text = node.text;
    if (text.trim().isNotEmpty) {
      final path = NodePath.fromNode(node);
      textNodes.add(TextNodeInfo(
        node: node,
        path: path,
        plainTextStart: plainText.length,
        plainTextEnd: plainText.length + text.length,
        text: text,
      ));
      plainText.write(text);
    }
  } else if (node is dom.Element) {
    final tagName = node.localName?.toLowerCase();
    if (_skipElements.contains(tagName)) return;

    final isBlock = _blockElements.contains(tagName);
    if (isBlock && plainText.isNotEmpty && !plainText.toString().endsWith('\n')) {
      plainText.write('\n');
    }

    for (final child in node.nodes) {
      _traverse(child, textNodes, plainText);
    }

    if (isBlock && plainText.isNotEmpty && !plainText.toString().endsWith('\n')) {
      plainText.write('\n');
    }
  }
}
```

When the traversal moves from one block element to another — say from one `<p>` to the next, or from a `<blockquote>` into a `<ul>` — a newline character is inserted in the plain text buffer both before and after the block's children. Without this, the last word of one paragraph would be concatenated directly with the first word of the next paragraph in the plain text, which would produce false positive matches when searching for text. The set of elements treated as block-level includes all the usual suspects: `p`, `div`, `h1` through `h6`, `ul`, `ol`, `li`, `blockquote`, `pre`, `hr`, `br`, `table` and its children `thead`, `tbody`, `tr`, `td`, `th`, plus semantic elements like `article`, `section`, `header`, `footer`, `nav`, `aside`, `figure`, `figcaption`, `address`, `dd`, `dt`, and `dl`. Elements that should be completely ignored during text extraction — `script`, `style`, and the custom highlight wrapper tag itself — are skipped along with their entire subtrees.

The text map enables bidirectional conversion. The map class itself stores the plain text, the ordered node list, and a hash map for O(1) path lookups:

```dart
class DomTextMap {
  DomTextMap({
    required this.plainText,
    required this.textNodes,
  }) : _nodeByPath = {for (final n in textNodes) n.path.toString(): n};

  final String plainText;
  final List<TextNodeInfo> textNodes;
  final Map<String, TextNodeInfo> _nodeByPath;

  TextNodeInfo? getNodeByPath(String path) => _nodeByPath[path];

  List<TextNodeInfo> getNodesInRange(int start, int end) {
    return textNodes.where((node) => node.overlapsRange(start, end)).toList();
  }

  ({TextNodeInfo node, int offset})? plainTextToDom(int position) {
    final node = findNodeAtPosition(position);
    if (node == null) return null;
    return (node: node, offset: position - node.plainTextStart);
  }

  int? domToPlainText(String path, int offset) {
    final node = _nodeByPath[path];
    if (node == null) return null;
    return node.plainTextStart + offset;
  }
}
```

Given a plain text position, `plainTextToDom` finds which DOM text node contains it and computes the local offset within that node by subtracting the node's start position from the absolute position. Given a DOM path and a local offset, `domToPlainText` does the reverse by looking up the node and adding its start position to the offset. The `getNodesInRange` method returns all text nodes whose ranges overlap a given span, which is the foundation for applying highlights, because a single highlight might span across several text nodes that live in completely different parts of the DOM tree.

The path system itself needs to be deterministic and stable. Each text node gets addressed by an XPath-like path built by walking upward from the node through its ancestors to the `<body>` element. At each level, the node's position among its same-type siblings is recorded. The upward traversal that builds a path from any DOM node looks like this:

```dart
factory NodePath.fromNode(dom.Node node) {
  final segments = <PathSegment>[];
  var current = node;

  while (current.parent != null) {
    final parent = current.parent!;
    if (parent is dom.Document) break;
    if (parent is dom.Element && parent.localName?.toLowerCase() == 'html') break;

    if (current is dom.Text) {
      final index = _textNodeIndex(current, parent);
      segments.insert(0, PathSegment.text(index));
    } else if (current is dom.Element) {
      final tag = current.localName!.toLowerCase();
      final index = _elementIndex(current, parent);
      segments.insert(0, PathSegment.element(tag, index));
    }

    current = parent;
  }

  return NodePath(segments);
}
```

For an element node, `_elementIndex` counts how many siblings with the same tag name appear before it — so the second `<p>` child of a `<div>` gets index 1. For a text node, `_textNodeIndex` counts how many non-empty text node siblings appear before it:

```dart
static int _textNodeIndex(dom.Text node, dom.Node parent) {
  var index = 0;
  for (final sibling in parent.nodes) {
    if (sibling == node) return index;
    if (sibling is dom.Text && sibling.text.trim().isNotEmpty) {
      index++;
    }
  }
  return index;
}
```

The "non-empty" qualification in that loop is important: whitespace-only text nodes created by source code formatting (indentation, line breaks between tags) are excluded from the count, which means the path stays stable regardless of how the HTML source is formatted. The resulting path looks like `/body/article[0]/p[2]/text()[0]`, which reads as "the first text node inside the third `<p>` inside the first `<article>` inside the body." These paths can be serialized as strings for storage and later parsed back into structured segments using regex to extract tag names and indices.

Now for the second and harder problem: making highlights persistent and resilient to content changes. When a user highlights text in an article, you need to store enough information to find that same text again later. The simplest approach is to store the start and end offsets in the plain text, but this breaks immediately if even a single character is added or removed before the highlight. A better approach is to store the exact text that was highlighted along with a window of surrounding context — the text immediately before and after the highlighted span. This gives you multiple anchoring signals to disambiguate the highlight's location even if the document has been edited.

The most robust approach combines all of the above. The anchor data model captures every layer of positioning information in a single immutable structure:

```dart
class HighlightAnchor {
  const HighlightAnchor({
    required this.id,
    required this.articleId,
    required this.startOffset,
    required this.endOffset,
    required this.exactText,
    required this.prefixContext,
    required this.suffixContext,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.noteContent,
    this.startNodePath,      // V2: XPath-like path to start text node
    this.startNodeOffset,    // V2: character offset within start node
    this.endNodePath,        // V2: XPath-like path to end text node
    this.endNodeOffset,      // V2: character offset within end node
    this.textFingerprint,
    this.schemaVersion = 1,
  });

  bool get hasV2Data =>
      startNodePath != null &&
      endNodePath != null &&
      startNodeOffset != null &&
      endNodeOffset != null;
}
```

The plain text offsets serve as a rough guide, the `exactText` with `prefixContext` and `suffixContext` give text-level anchoring for disambiguation, and the optional V2 fields provide the precise DOM paths to the start and end text nodes along with character offsets within those nodes. This produces a multi-layered anchor: the DOM paths provide millimeter-precision positioning when the document structure is unchanged, the text-with-context approach handles the case where the structure changed but the text content is the same, and the offsets provide a positional hint for when there are multiple occurrences of the same text.

Resolving a highlight from this stored data then becomes a three-strategy cascade. The resolution method tries each strategy in sequence, gated by confidence thresholds:

```dart
ResolvedHighlight _resolveHighlight(HighlightAnchor highlight, DomTextMap textMap) {
  if (highlight.startNodePath != null && highlight.endNodePath != null) {
    final result = _resolveByDomPath(highlight, textMap);
    if (result != null && result.confidence >= 0.9) return result;
  }

  final textResult = _resolveByTextPosition(highlight, textMap);
  if (textResult != null && textResult.confidence >= 0.7) return textResult;

  final contextResult = _resolveByContext(highlight, textMap);
  if (contextResult != null && contextResult.confidence >= 0.5) return contextResult;

  return ResolvedHighlight.failed(highlight.id);
}
```

The first strategy, and the most precise, is DOM path resolution. If the anchor carries stored DOM paths, the resolver looks up those paths in the text map, computes the absolute plain text positions from the node-local offsets, extracts the text at those positions, and compares it to the stored exact text using a string similarity function. If the similarity is 0.9 or above — meaning the text at the stored DOM path is nearly identical to what was originally highlighted — the resolution is accepted with the similarity score as the confidence value. If the similarity drops below 0.7, the DOM path is rejected entirely even though it resolved to valid nodes, because the content has changed too much for the path to be trustworthy. Between 0.7 and 0.9 the path is also rejected in favor of the text-based fallbacks, because at that confidence level the text matching strategies are more reliable.

The second strategy is text position resolution, which tries four progressively looser matching approaches against the plain text. The tightest match searches for the complete string formed by concatenating the prefix context, the exact text, and the suffix context. If this full string is found verbatim in the plain text, the confidence is 1.0, because you have found the exact text with both surrounding contexts matching perfectly. If that fails, the resolver tries the prefix context concatenated with the exact text alone (confidence 0.9 on match), then the exact text with the suffix context (also 0.9), then the exact text by itself. When searching for the exact text alone, if there is exactly one occurrence in the document, confidence is 0.8. If there are multiple occurrences, the resolver picks the one whose position is closest to the stored start offset using absolute distance and assigns confidence 0.7. The minimum accepted confidence for this strategy is 0.7.

The third and final strategy is a fuzzy context search. This is the last resort for when the document has changed enough that exact string matching fails. It implements a sliding window that iterates through every possible position in the plain text, extracts a candidate substring of the same length as the search text, and computes a similarity score. The similarity function is the Dice coefficient based on the Longest Common Subsequence: specifically, the formula is `(2 * LCS_length) / (length_a + length_b)`, producing a value between 0.0 and 1.0. The LCS itself is computed using the classic dynamic programming algorithm with a space-optimized two-row implementation:

```dart
int _longestCommonSubsequence(String a, String b) {
  final m = a.length;
  final n = b.length;

  var prev = List<int>.filled(n + 1, 0);
  var curr = List<int>.filled(n + 1, 0);

  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      if (a[i - 1] == b[j - 1]) {
        curr[j] = prev[j - 1] + 1;
      } else {
        curr[j] = curr[j - 1] > prev[j] ? curr[j - 1] : prev[j];
      }
    }
    final temp = prev;
    prev = curr;
    curr = temp;
    curr.fillRange(0, n + 1, 0);
  }

  return prev[n];
}

double _calculateSimilarity(String a, String b) {
  if (a == b) return 1.0;
  if (a.isEmpty || b.isEmpty) return 0.0;
  final lcsLength = _longestCommonSubsequence(a, b);
  return (2.0 * lcsLength) / (a.length + b.length);
}
```

Instead of allocating a full `m * n` matrix, only two arrays of length `n + 1` are maintained and swapped after each row, reducing memory from O(m*n) to O(n). The row swap is done by pointer exchange rather than copying, and the "current" array is zeroed out by `fillRange` after each swap to prepare for the next row. Candidates with text similarity below 0.7 are skipped immediately. For those that pass, a context score is also computed by comparing the text surrounding the candidate position to the stored prefix and suffix contexts using the same similarity function. The final score is a weighted blend: 60% text similarity plus 40% context similarity. The best-scoring position is kept, and if its total score meets or exceeds 0.5 the resolution is accepted. If the first pass finds nothing and the whitespace-normalized form of the search text differs from the original (because whitespace has been reformatted in the document), a second pass is run using normalized comparisons. If all three strategies fail, the highlight is marked as orphaned — it could not be located in the document.

After all highlights have been resolved, overlapping regions need to be eliminated. Two highlights cannot occupy the same text range because nested wrapper elements would produce unpredictable rendering and make it impossible to determine which highlight a user tapped. The overlap removal uses a greedy algorithm: it sorts the resolved highlights by start position ascending, then does a linear scan accepting each highlight only if its start position is at or after the end position of the previously accepted one. Earlier-positioned highlights always win in case of conflict. The algorithm does not attempt to maximize total coverage, instead trading optimality for simplicity and determinism.

The surviving highlights are then sorted in descending order by start position. This reverse ordering is critical for the application phase. When you modify the DOM by splitting text nodes and inserting wrapper elements, the structure of the tree changes. If you process highlights from the beginning of the document forward, each modification shifts the positions of everything after it, invalidating the text map entries for all subsequent highlights. By processing from the end of the document backward, each modification only affects regions that have already been processed, and all remaining highlights still have valid position data.

For each highlight, the applicator queries the text map for all text nodes overlapping the highlight's character range. If the highlight falls entirely within a single text node, the node's text is split into three parts and the original node is replaced in the DOM:

```dart
void _applySingleNode(TextNodeInfo nodeInfo, ResolvedHighlight resolution, HighlightAnchor anchor) {
  final node = nodeInfo.node;
  final localStart = resolution.startPosition - nodeInfo.plainTextStart;
  final localEnd = resolution.endPosition - nodeInfo.plainTextStart;

  final safeStart = localStart.clamp(0, nodeInfo.text.length);
  final safeEnd = localEnd.clamp(safeStart, nodeInfo.text.length);
  if (safeStart >= safeEnd) return;

  final parts = _splitText(node.text, safeStart, safeEnd);

  final insideAnchor = _isInsideAnchorTag(node);
  final insideCode = _isInsideCodeBlock(node);
  final wrapper = _createHighlightElement(anchor, insideAnchor, insideCode);
  wrapper.append(dom.Text(parts.middle));

  final parent = node.parent!;
  final index = parent.nodes.indexOf(node);
  node.remove();

  var insertIndex = index;
  if (parts.before.isNotEmpty) {
    parent.nodes.insert(insertIndex, dom.Text(parts.before));
    insertIndex++;
  }
  parent.nodes.insert(insertIndex, wrapper);
  insertIndex++;
  if (parts.after.isNotEmpty) {
    parent.nodes.insert(insertIndex, dom.Text(parts.after));
  }
}
```

The global plain text positions are converted to node-local offsets by subtracting `plainTextStart`, then clamped to valid bounds to prevent index-out-of-range errors. The split produces three substrings (before, middle, after), and the original text node is replaced with up to three new nodes — the before text if non-empty, the wrapper element containing the highlighted text, and the after text if non-empty. The insertion index is tracked carefully: each insert shifts subsequent positions by one, so `insertIndex` is incremented after each insertion. The wrapper element is a custom HTML tag (defaulting to `<html-hl>`) with a `data-hl-id` attribute set to the highlight's unique identifier and an inline style setting the background color. The color is derived from the highlight's stored color value through a hex-to-RGBA conversion chain:

```dart
({int r, int g, int b}) toRgb() {
  final r = int.parse(hex.substring(0, 2), radix: 16);
  final g = int.parse(hex.substring(2, 4), radix: 16);
  final b = int.parse(hex.substring(4, 6), radix: 16);
  return (r: r, g: g, b: b);
}

String toRgba(double alpha) {
  final rgb = toRgb();
  return 'rgba(${rgb.r},${rgb.g},${rgb.b},$alpha)';
}
```

A six-character hex string like `FFF176` for yellow is split into three two-character substrings, each parsed with radix 16 into integer RGB components, then formatted into a CSS `rgba()` value with alpha 0.4 for semi-transparent background coloring. The style also adds `border-radius:2px` and `padding:0 2px` to give the highlight a subtle pill shape.

When the highlight spans multiple text nodes — the cross-element case discussed earlier — each affected node is wrapped individually. The first node gets wrapped from the highlight's start offset to the end of the node's text. The last node gets wrapped from the beginning of the node's text to the highlight's end offset. Any nodes in between get their entire content wrapped. Each separate wrapper element shares the same `data-hl-id` value so downstream code can identify all fragments as belonging to the same logical highlight.

Two special cases require different treatment, and both are handled in the element construction method:

```dart
dom.Element _createHighlightElement(HighlightAnchor anchor, bool insideAnchor, bool insideCode) {
  final tagName = insideAnchor ? 'span' : highlightTag;
  final element = dom.Element.tag(tagName);

  element.attributes['data-hl-id'] = anchor.id;

  final rgb = anchor.color.toRgb();

  String style;
  if (insideCode) {
    style = 'background-color:rgba(${rgb.r},${rgb.g},${rgb.b},$codeOpacity);';
  } else {
    style = 'background-color:rgba(${rgb.r},${rgb.g},${rgb.b},$normalOpacity);'
        'border-radius:2px;'
        'padding:0 2px;';
  }

  element.attributes['style'] = style;
  return element;
}
```

When a text node is a descendant of an `<a>` (anchor/link) element, the wrapper uses `<span>` instead of the custom `<html-hl>` tag. This is because the HTML specification constrains which elements can legally nest inside anchor elements, and custom elements can cause rendering engines to silently restructure the DOM. The `<span>` receives the same `data-hl-id` attribute and inline styles, so it is functionally identical. When a text node is inside a `<pre>` or `<code>` element, the `codeOpacity` of 0.3 replaces the `normalOpacity` of 0.4, and the border-radius and padding are omitted because padding would disrupt monospace character alignment. Both context flags (`insideAnchor`, `insideCode`) are determined before this method is called by walking up the ancestor chain from the text node, inspecting each parent element's tag name until either a matching ancestor is found or the root is reached.

The entire pipeline must be idempotent — applying the same highlights to already-highlighted HTML must produce the same result as applying them to clean HTML. This is achieved by always stripping existing highlights before reapplying. The removal process has two phases: unwrapping and normalization.

```dart
void removeHighlights(dom.Element root) {
  final highlights = <dom.Element>[];
  _findHighlightElements(root, highlights);

  for (final hl in highlights) {
    _unwrapElement(hl);
  }

  _normalizeTextNodes(root);
}

void _unwrapElement(dom.Element element) {
  final parent = element.parent;
  if (parent == null) return;
  final index = parent.nodes.indexOf(element);
  if (index == -1) return;

  final children = element.nodes.toList();
  for (var i = 0; i < children.length; i++) {
    final child = children[i];
    element.nodes.remove(child);
    parent.nodes.insert(index + i, child);
  }
  element.remove();
}

void _normalizeTextNodes(dom.Node node) {
  if (node is dom.Element) {
    final children = node.nodes.toList();
    for (var i = children.length - 1; i > 0; i--) {
      if (children[i] is dom.Text && children[i - 1] is dom.Text) {
        final combined =
            (children[i - 1] as dom.Text).text + (children[i] as dom.Text).text;
        (children[i - 1] as dom.Text).replaceWith(dom.Text(combined));
        children[i].remove();
      }
    }
    for (final child in node.nodes) {
      _normalizeTextNodes(child);
    }
  }
}
```

The unwrapping takes each highlight element's children, inserts them into the parent at the wrapper's original position (offset by `i` so multiple children fan out in order), and removes the now-empty wrapper. The normalization pass then walks the tree in reverse child order, merging any adjacent text nodes that were split by a previous highlighting pass — if children `i-1` and `i` are both text nodes, their content is concatenated and the second node is removed. This merge is essential: without it, the text map built from previously-highlighted HTML would have different node boundaries than the map built from clean HTML, and the resolution logic would compute different positions. With the merge, the DOM after removal is structurally identical to the original, and the full pipeline produces identical output regardless of how many times it has been run.

The anchoring data for each highlight is designed to be serializable to JSON for database storage. The `toJson` method produces a map with snake_case keys, serializing colors by name and timestamps as ISO 8601:

```dart
Map<String, dynamic> toJson() => {
      'id': id,
      'article_id': articleId,
      'start_offset': startOffset,
      'end_offset': endOffset,
      'exact_text': exactText,
      'prefix_context': prefixContext,
      'suffix_context': suffixContext,
      'note_content': noteContent,
      'color': color.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'start_node_path': startNodePath,
      'start_node_offset': startNodeOffset,
      'end_node_path': endNodePath,
      'end_node_offset': endNodeOffset,
      'text_fingerprint': textFingerprint,
      'schema_version': schemaVersion,
    };
```

The color is persisted as its name string ("yellow", "blue", "pink", and so on) rather than the full hex object, with eight predefined options available plus support for custom hex values. The `fromJson` factory reverses this, defaulting `schemaVersion` to 1 when absent from the stored JSON so that data created before the DOM path feature was added loads without migration. Two anchors are considered equal if their `id` fields match, regardless of other fields. The model also provides a `copyWith` method for immutable updates where any subset of fields can be overridden while the rest are preserved from the original instance.

The text map construction is expensive for large articles because it requires parsing the HTML, traversing every node, computing NodePath instances that involve walking up the ancestor chain at each text node, and concatenating all text. To avoid repeating this work, a static in-memory cache keyed by article identifier stores computed text maps across calls. The cache holds a maximum of twenty entries. When it fills up, the oldest half of entries (by insertion order, since Dart's LinkedHashMap preserves insertion order) are evicted to make room. This is not a true LRU cache in the strict sense because Dart's map tracks insertion rather than access order, but it provides reasonable memory management for the typical case where a user reads through articles sequentially. The cache must be cleared manually when article content changes, because the engine has no way to detect stale data — if you update an article's HTML without clearing its cache entry, the engine will use the old text map and highlights may resolve to wrong positions.

For Flutter integration, the rendered HTML output contains custom `<html-hl>` elements with inline styles and `data-hl-id` attributes. When using the `flutter_html` package, these need to be registered as a `TagExtension` that maps the custom tag to a Flutter widget, reading the `data-hl-id` from the element's attributes to wire up tap handlers or context menus. The inline styles handle the visual rendering directly, so no external CSS or theme configuration is needed. The core engine itself has no dependency on Flutter's widget system or rendering layer — it is pure Dart string and DOM manipulation using the `html` package (version 0.15.4+) for parsing, which means it could equally be used in server-side Dart code, CLI tools, or build pipelines.

Everything described in this document — the DOM-based parsing pipeline, the bidirectional text mapping, the three-strategy resolution cascade with LCS-based fuzzy matching, the cross-element highlight splitting, the idempotent removal and normalization, the anchor serialization with dual schema versioning, and the text map caching — is implemented and published as a ready-to-use Flutter/Dart package called [html_highlight](https://github.com/theiskaa/html_highlight). It is available on [pub.dev](https://pub.dev/packages/html_highlight) under the MIT License.
