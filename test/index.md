---
title: Test
---

* [Internal, relative link that should work][link].
* [Link to the site root][root].
* [Absolute URL to page][absolute-page].
* [Relative URL to CSS file][relative-css].

[link]: link
[root]: {{ site.url }}
[absolute-page]: {{ page.url | absolute_url }}
[relative-css]: {{ "/test.css" | relative_url }}
