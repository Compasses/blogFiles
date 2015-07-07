title: "WEB 开发点滴（一）"
date: 2015-07-07 17:41:52
tags: "CSS"
---

WEB开发错综复杂，很多知识点让你抓不到重点，用过了忘记了，下次用还要重头开始。例如CSS，很多class，很多的取值，每个都有很多视觉效果。拿到UX的design，不同的人做出来的效果可以保持一致，但是对应的CSS和JS可能完全不一样。正是这种WEB开发的灵活性，更让人抓不到重点。

最近又在做一些UI的开发工作，集中在前端，需要CSS和JS，事情做完了，仔细想想里面用到的CSS class都理解了吗？发现并没用。如此众多，如何才能掌握这些class呢？突然想到CSS class虽然众多但是用到的不是全集，所以在学习上也要化整为零，化繁为简，各个击破。这次就好好记录下CSS中的overflow和position类。

#POSITION
解释说明：
```
position
    
'position'
Value:  
static | relative | absolute | fixed | inherit
Initial:  
static
Applies to:  
all elements
Inherited:  
no
Percentages:  
N/A
Media:  
visual
Computed value:  
as specified
The values of this property have the following meanings:
static
The box is a normal box, laid out according to the normal flow. The 'top', 'right', 'bottom', and 'left' properties do not apply.
relative
The box's position is calculated according to the normal flow (this is called the position in normal flow). Then the box is offset relative to its normal position. When a box B is relatively positioned, the position of the following box is calculated as though B were not offset. The effect of 'position:relative' on table-row-group, table-header-group, table-footer-group, table-row, table-column-group, table-column, table-cell, and table-caption elements is undefined.
absolute
The box's position (and possibly size) is specified with the 'top', 'right', 'bottom', and 'left' properties. These properties specify offsets with respect to the box's containing block. Absolutely positioned boxes are taken out of the normal flow. This means they have no impact on the layout of later siblings. Also, though absolutely positioned boxes have margins, they do not collapse with any other margins.
fixed
The box's position is calculated according to the 'absolute' model, but in addition, the box is fixed with respect to some reference. As with the 'absolute' model, the box's margins do not collapse with any other margins. In the case of handheld, projection, screen, tty, and tv media types, the box is fixed with respect to the viewport and doesn't move when scrolled. In the case of the print media type, the box is rendered on every page, and is fixed with respect to the page box, even if the page is seen through a viewport (in the case of a print-preview, for example). For other media types, the presentation is undefined. Authors may wish to specify 'fixed' in a media-dependent way. For instance, an author may want a box to remain at the top of the viewport on the screen, but not at the top of each printed page. The two specifications may be separated by using an @media rule, as in:
Example(s):
  
@media screen {
  h1#first { position: fixed }
}
@media print {
  h1#first { position: static }
}
UAs must not paginate the content of fixed boxes. Note that UAs may print invisible content in other ways. See "Content outside the page box" in chapter 13.
User agents may treat position as 'static' on the root element.
```

元素的位置定位影响它的视觉模型，例如：p, h1, div 为块级元素，块级元素在展示的时候是以垂直摆放的，元素之间的垂直距离由垂直间隔决定，即margin。又如：strong、span为inline elements，内联元素。展示为水平摆放，这种元素改变视觉效果只能通过line height、或者水平 border 、padding、margin。

##relative position
相对定位比较简单，就是可以通过属性 top、left、bottom、right来改变它的位置，改变是相对于它的原始位置开始计算的。它于正常的文档流定位类似。跟position的另一个取值static一样，如果不改变它的位置属性值。
##absolute position
类似于relative position，absolute position是相对于其最近的父节点而摆放。如果没有最近的父节点，就绑定在body元素上。absolute position让其父节点必须是relative position。
##fixed position
是absolute position的子类，不同的是它的视口是整个window， 利用它就可以固定一个元素在这个窗口视图上，无论怎么滚动这个元素会固定在这个窗口中。
##floating
floatting也是重要的布局类，经常需要将一个元素靠左或者靠右对齐。靠左或者靠右直到它的外边缘与父节点边缘接壤，或者其他float元素的边缘。float元素并不在正常的文档流中。即只要元素变为float元素了，其所在的body就会将其视为不存在了。在实现那些文字环绕的效果时，都会使用到这个class，因为float元素会脱离正常的文档流，所以在制作这种效果的时候需要用clear配合使用。

#overflow
解释：
<!--more-->

```
overflow
    
'overflow'
Value:  
visible | hidden | scroll | auto | inherit
Initial:  
visible
Applies to:  
non-replaced block-level elements, table cells, and inline-block elements
Inherited:  
no
Percentages:  
N/A
Media:  
visual
Computed value:  
as specified
This property specifies whether content of a block-level element is clipped when it overflows the element's box. It affects the clipping of all of the element's content except any descendant elements (and their respective content and descendants) whose containing block is the viewport or an ancestor of the element. Values have the following meanings:
visible
This value indicates that content is not clipped, i.e., it may be rendered outside the block box.
hidden
This value indicates that the content is clipped and that no scrolling user interface should be provided to view the content outside the clipping region.
scroll
This value indicates that the content is clipped and that if the user agent uses a scrolling mechanism that is visible on the screen (such as a scroll bar or a panner), that mechanism should be displayed for a box whether or not any of its content is clipped. This avoids any problem with scrollbars appearing and disappearing in a dynamic environment. When this value is specified and the target medium is 'print', overflowing content may be printed.
auto
The behavior of the 'auto' value is user agent-dependent, but should cause a scrolling mechanism to be provided for overflowing boxes.
Even if 'overflow' is set to 'visible', content may be clipped to a UA's document window by the native operating environment.
UAs must apply the 'overflow' property set on the root element to the viewport. HTML UAs must instead apply the 'overflow' property from the BODY element to the viewport, if the value on the HTML element is 'visible'. The 'visible' value when used for the viewport must be interpreted as 'auto'. The element from which the value is propagated must have a used value for 'overflow' of 'visible'.
In the case of a scrollbar being placed on an edge of the element's box, it should be inserted between the inner border edge and the outer padding edge. The space taken up by the scrollbars affects the computation of the dimensions in the rendering model.
Example(s):
Consider the following example of a block quotation (<blockquote>) that is too big for its containing block (established by a <div>). Here is the source:
<div>
<blockquote>
<p>I didn't like the play, but then I saw
it under adverse conditions - the curtain was up.</p>
<cite>- Groucho Marx</cite>
</blockquote>
</div>
Here is the style sheet controlling the sizes and style of the generated boxes:
div { width : 100px; height: 100px;
      border: thin solid red;
      }

blockquote   { width : 125px; height : 100px;
      margin-top: 50px; margin-left: 50px;
      border: thin dashed black
      }

cite { display: block;
       text-align : right;
       border: none
       }
The initial value of 'overflow' is 'visible', so the <blockquote> would be formatted without clipping, something like this:
   [D]
Setting 'overflow' to 'hidden' for the <div>, on the other hand, causes the <blockquote> to be clipped by the containing block:
   [D]
A value of 'scroll' would tell UAs that support a visible scrolling mechanism to display one so that users could access the clipped content.
Finally, consider this case where an absolutely positioned element is mixed with an overflow parent.
Style sheet:
  container { position: relative; border: solid; }
  scroller { overflow: scroll; height: 5em; margin: 5em; }
  satellite { position: absolute; top: 0; }
  body { height: 10em; }
Document fragment:
  <container>
   <scroller>
    <satellite/>
    <body/>
   </scroller>
  </container>
In this example, the "scroller" element will not scroll the "satellite" element, because the latter's containing block is outside the element whose overflow is being clipped and scrolled.
11.1. The ‘overflow’, ‘overflow-x’ and ‘overflow-y’ properties
In the preceding sections, several things (such as flow roots) depend on the value of ‘overflow’. We probably need to rewrite them in terms of “overflow-x and/or -y” or similar.
Name:
overflow-x, overflow-y,
Value:
visible | hidden | scroll | auto | no-display | no-content
Initial:
visible
Applies to:
non-replaced block-level elements and non-replaced ‘inline-block’ elements
Inherited:
no
Percentages:
N/A
Media:
visual
Computed value:
as specified, except ‘visible’, see text
Name:
overflow
Value:
[ visible | hidden | scroll | auto | no-display | no-content ]{1,2}
Initial:
see individual properties
Applies to:
non-replaced block-level elements and non-replaced ‘inline-block’ elements
Inherited:
no
Percentages:
N/A
Media:
visual
Computed value:
as specified, except ‘visible’, see text
These properties specify whether content is clipped when it overflows the element's content area. It affects the clipping of all of the element's content except any descendant elements (and their respective content and descendants) whose containing block is the viewport or an ancestor of the element. ‘Overflow-x’ determines clipping at the left and right edges, ‘overflow-y’ at the top and bottom edges.
‘Overflow’ is a shorthand. If it has one keyword, it sets both ‘overflow-x’ and ‘overflow-y’ to that keyword; if it has two, it sets ‘overflow-x’ to the first and ‘overflow-y’ to the second. Keywords have the following meanings:
visible
This value indicates that content is not clipped, i.e., it may be rendered outside the content box.
hidden
This value indicates that the content is clipped and that no scrolling mechanism should be provided to view the content outside the clipping region.
scroll
This value indicates that the content is clipped and that if the user agent uses a scrolling mechanism that is visible on the screen (such as a scroll bar or a panner), that mechanism should be displayed for a box whether or not any of its content is clipped. This avoids any problem with scrollbars appearing and disappearing in a dynamic environment. When this value is specified and the target medium is ‘print’, overflowing content may be printed.
auto
The behavior of the ‘auto’ value is UA-dependent, but should cause a scrolling mechanism to be provided for overflowing boxes.
no-display
When the content doesn't fit in the content box, the whole box is removed, as if ‘display: none’ were specified. [This idea is due to Till Halbach <tillh@opera.com>, July 21, 2005]
no-content
When the content doesn't fit in the content box, the whole content is hidden, as if ‘visibility: hidden’ were specified. [This idea is due to Till Halbach <tillh@opera.com>, July 21, 2005]
Even if ‘overflow’ is set to ‘visible’, content may be clipped to a UA's document window by the native operating environment.
UAs must apply the ‘overflow’ property set on the root element to the viewport. HTML UAs must instead apply the ‘overflow’ property from the BODY element to the viewport, if the value on the HTML element is ‘visible’. The ‘visible’ value when used for the viewport must be interpreted as ‘auto’. The element from which the value is propagated must have a used value for ‘overflow’ of ‘visible’.
The para above is from CSS 2.1. Need to check if the introduction of overflow-x/y changes anything.
In the case of a scrollbar being placed on an edge of the element's box, it should be inserted between the inner border edge and the outer padding edge. The space taken up by the scrollbars affects the computation of the dimensions in the rendering model.
A UA may use multiple scrolling mechanisms at the same time. E.g., if content overflows both to the right and to the bottom, it may use a marquee effect for the overflow to the right and a scrollbar for the overflow to the bottom.
Note that a box with ‘overflow’ other than ‘visible’ is a flow root.
Consider the following example of a block quotation (<blockquote>) that is too big for its containing block (established by a <div>). Here is the source:
<div>
<blockquote>
<p>I didn't like the play, but then I saw
it under adverse conditions - the curtain was up.</p>
<cite>- Groucho Marx</cite>
</blockquote>
</div>
Here is the style sheet controlling the sizes and style of the generated boxes:
div { width : 100px; height: 100px;
      border: thin solid red;
      }

blockquote   { width : 125px; height : 100px;
      margin-top: 50px; margin-left: 50px;
      border: thin dashed black
      }

cite { display: block;
       text-align : right;
       border: none
       }
The initial value of ‘overflow’ is ‘visible’, so the <blockquote> would be formatted without clipping, something like this:

Possible rendering with ‘overflow: visible’
Setting ‘overflow’ to ‘hidden’ for the <div>, on the other hand, causes the <blockquote> to be clipped by the containing block:

Possible rendering with ‘overflow: hidden’
A value of ‘scroll’ would tell UAs that support a visible scrolling mechanism to display one so that users could access the clipped content.
Consider this case where an absolutely positioned element is mixed with an overflow parent. Style sheet:
container { position: relative; border: solid; }
scroller { overflow: scroll; height: 5em; margin: 5em; }
satellite { position: absolute; top: 0; }
body { height: 10em; }
Document fragment:
<container>
<scroller>
  <satellite/>
  <body/>
</scroller>
</container>
In this example, the “scroller” element will not scroll the “satellite” element, because the latter's containing block is outside the element whose overflow is being clipped and scrolled.
The combination of collapsing margins, ‘max-height’ and ‘overflow: auto’ can lead to subtle differences in implementations, unless special care is taken. A UA should assume that an element can be rendered without a scrolling mechanism first, perform all the collapsing of margins, and check that the content height is indeed less than the ‘max-height’. If it is not, the process is repeated under the assumption that a scrolling mechanism is needed.
In the following document fragment, the outer DIV has ‘height: auto’, but ‘max-height: 5em’. The inner DIV has large margins and would normally just fit:
...
    #d1 { overflow: auto; max-height: 5em }
    #d2 { margin: 2em; line-height: 1 }
...
<div id=d1>
  <div id=d2>
    This DIV has big margins.
  </DIV>
</DIV>
If we assume that d1 needs scroll bars, then the height of d1, including the single line of text and twice 2em of margins, adds up to 5em plus a scrollbar. Since that is greater than 5em, the maximum allowed height, it seems we made the right assumption and d1 indeed needs scrollbars.
However, we should have started by assuming that no scrollbars are needed. In that case the content height of d1 is exactly the maximum height of 5em, proving that the assumption was correct and d1 indeed should not have scrollbars.
The computed values of ‘overflow-x’ and ‘overflow-y’ are the same as their specified values, except that some combinations with ‘visible’ are not possible: if one is specified as ‘visible’ and the other is ‘scroll’ or ‘auto’, then ‘visible’ is set to ‘auto’. The computed value of ‘overflow’ is equal to the computed value of ‘overflow-x’ if ‘overflow-y’ is the same; otherwise it is the pair of computed values of ‘overflow-x’ and ‘overflow-y’.
The scrolling mechanism depends on the UA. The most common mechanism is a scrollbar, but panners, hand cursors, page flickers, etc. are also possible. A value of ‘scroll’ would tell UAs that support a visible scrolling mechanism to display one so that users can access the clipped content. The ‘overflow-style’ property lets an author specify one or more preferred scrolling mechanism.
Note that ‘overflow-x’ and ‘overflow-y’ did not exist in CSS2.
Note that ‘text-overflow’ (see [CSS3TEXT] ) can be used to give a visual indication where text has been clipped.
```
overflow，常与定高的元素配合使用，如果元素定高，通过overflow-y: auto, 如果内容高度大于定高元素就会出现滚动条。如果定高元素内部需要出现overflow：visiable的元素，需要重新更改overflow的属性值。因为默认元素的overflow是继承父节点的。
