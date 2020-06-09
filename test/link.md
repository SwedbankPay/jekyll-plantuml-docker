---
title: Index page of test site
description: For testing HTML
---

* This file is linked from [index][index].
* This is not [rendered][index3].
* [This is an absolute URL to this page][absolute].
* [And here's a relative URL to this page][relative]

[index]: /
[absolute]: {{ page.url | absolute_url }}
[relative]: {{ "/link" | relative_url }}
