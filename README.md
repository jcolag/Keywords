Keywords
========

This is a quick project to demonstrate/prototype keyword searches for suspicious texts, with features to be added over time.

Briefly, _Keywords_ will extract the words in a text file above a specified size, filter out common words, and collect the words by stem/root word.

Credits
-------

Rather than try to reinvent the wheel with my own stemming algorithm, I happily use the [stemmify gem](https://github.com/raypereda/stemmify).

The default list of common words is an aggregate of [Basic English](https://en.wikipedia.org/wiki/Basic_English), the typical vocabulary of [Voice of America](https://en.wikipedia.org/wiki/Voice_of_America), and at least one list of [Stop Words](https://en.wikipedia.org/wiki/Stop_words).
