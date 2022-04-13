---
title: Test
description: The index page
---

Text can be **bold**, _italic_, or ~~strikethrough~~.

* [Internal, relative reference link that should work][link].
* [Link to the site root]({{ site.url }}).
* [Absolute URL to page]({{ page.url | absolute_url }}).
* [Relative URL to CSS file]({{ "/test.css" | relative_url }}).
* [External absolute full link](https://www.wikipedia.org)
* [External protocol relative link](//www.wikipedia.org)
* [Internal absolute full link]({{ site.url }})
* [Internal explicit relative link](./page1)
* [Internal implicit relative link](page1)
* [Internal absolute link](/page1)

There should be whitespace between paragraphs.

There should be whitespace between paragraphs. We recommend including a README, or a file with information about your project.

## Header 2

This is a normal paragraph following a header. GitHub is a code hosting platform for version control and collaboration. It lets you and others work together on projects from anywhere.

> This is a blockquote following a header.
>
> When something is important enough, you do it even if the odds are not in your favor.

### Header 3

{:.code-header}
**JavaScript code with syntax highlighting.**

```js
var fun = function lang(l) {
  dateformat.i18n = require('./lang/' + l)
  return true;
}
```

Here's some `<inline>`{:.language-html .highlight}
`{ "code": true }`{:.language-js .highlight}
that should `.be { highlighted: according; }`{:.language-css .highlight} to their
language.

#### Header 4

* This is an unordered list following a header.
* This is an unordered list following a header.
* This is an unordered list following a header.

##### Header 5

1. This is an ordered list following a header.
2. This is an ordered list following a header.
3. This is an ordered list following a header.

###### Header 6

Here's a nice, striped table.

{:.table .table-striped}
| head1        | head two          | three |
| :----------- | :---------------- | :---- |
| ok           | good swedish fish | nice  |
| out of stock | good and plenty   | nice  |
| ok           | good `oreos`      | hmm   |
| ok           | good `zoute` drop | yumm  |

## Mermaid

```mermaid
sequenceDiagram
    participant Merchant
    participant SwedbankPay

    activate SwedbankPay
        SwedbankPay->>Merchant: POST <callbackUrl>
        activate Merchant
            note right of SwedbankPay: Callback POST by SwedbankPay
            Merchant->>SwedbankPay: Callback response
        deactivate Merchant
    deactivate SwedbankPay

    activate Merchant
        Merchant->>SwedbankPay: GET <payment instrument> payment
        note left of Merchant: First API request
        activate SwedbankPay
            SwedbankPay-->>Merchant: payment resource
        deactivate SwedbankPay
    deactivate Merchant
```

## There's a horizontal rule below this

* * *

## Here is an unordered list

* Item foo
* Item bar
* Item baz
* Item zip

## And an ordered list

1. Item one
1. Item two
1. Item three
1. Item four

## And a nested list

* level 1 item
  * level 2 item
  * level 2 item
    * level 3 item
    * level 3 item
* level 1 item
  * level 2 item
  * level 2 item
  * level 2 item
* level 1 item
  * level 2 item
  * level 2 item
* level 1 item

## Small image

![Octocat](https://user-images.githubusercontent.com/12283/163170886-bb90a4fe-99e2-4f6f-8f52-810a4c2237de.png)

## Large image

![Branching](https://user-images.githubusercontent.com/12283/163170807-511d1085-2d53-46c3-981b-653f6173f7c2.png)

## Definition lists can be used with HTML syntax

<dl>
    <dt>Name</dt>
    <dd>Godzilla</dd>
    <dt>Born</dt>
    <dd>1952</dd>
    <dt>Birthplace</dt>
    <dd>Japan</dd>
    <dt>Color</dt>
    <dd>Green</dd>
</dl>

```
Long, single-line code blocks should not wrap. They should horizontally scroll if they are too long. This line should be long enough to demonstrate this.
```

```
The final element.
```

## Emoji support

:+1: :heavy_check_mark: :fire: 💡 :unicorn:

## Material design icons

{% icon check %} {% icon line_weight %} {% icon gavel %} {% icon visibility %}
{% icon work %}

## PlantUML

```plantuml
@startuml
actor client
node app
database db
db -> app
app -> client
@enduml
```

[link]: link
