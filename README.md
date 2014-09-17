Keywords
========

This is a quick project to demonstrate/prototype keyword searches for suspicious texts, with features to be added over time.

Briefly, _Keywords_ will extract the words in a text file above a specified size, filter out common words, and collect the words by stem/root word.

For the sake of looking productive, it then uses [DuckDuckGo](https://duckduckgo.com) to search [Snopes](http://snopes.com) and quickly parses it to see if the contents (a recirculated e-mail, for example) represent a known scam.

Warnings
--------

**Please** don't use this for any sort of production work.

I mean, seriously, for the sake of expedience, I'm using a search engine *as* a search engine and (to use the term a bit liberally) spidering another site.  I'm also assuming that neither site layout will ever change.  I even take a very naive view of HTML structure, just for the sake of it.

The number of things that can go wrong and the number of people you might offend is astronomical.  So, just don't actually use the thing for anything more than a quick test or a learning experience.

Credits
-------

Rather than try to reinvent the wheel with my own stemming algorithm, I happily use the [stemmify gem](https://github.com/raypereda/stemmify) to collect words by (likely) common root.

The default list of common words is an aggregate of [Basic English](https://en.wikipedia.org/wiki/Basic_English), the typical vocabulary of [Voice of America](https://en.wikipedia.org/wiki/Voice_of_America), and at least one list of [Stop Words](https://en.wikipedia.org/wiki/Stop_words).

As mentioned, the search uses both [DuckDuckGo](https://duckduckgo.com) and [Snopes](http://snopes.com).

