---
title: Test
---

* [Internal, relative link that should work][link].
* [Link to the site root]({{ site.url }}).
* [Absolute URL to page]({{ page.url | absolute_url }}).
* [Relative URL to CSS file]({{ "/test.css" | relative_url }}).

[link]: link
