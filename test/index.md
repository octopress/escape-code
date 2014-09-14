---
escape_code: true
---

Some text

```
Some kind of example:
    {% some tag that should break %}
Stuff!
```
guys!

Testing the ``dobule ` type`` of code thing.

So here's a `{% nonexistant tag %}` that should be escaped.

{% highlight html %}
Some kind of example:
{% some tag that should break %}
Stuff!
{% endhighlight %}


{% codeblock html %}
Some kind of example:
    stuff
{% some tag that should break %}
Stuff!
{% endcodeblock %}
    stuff
    {% foo %}
some text
