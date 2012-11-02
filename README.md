# Linnaeus [![Build Status](https://secure.travis-ci.org/djcp/linnaeus.png?branch=master)](http://travis-ci.org/djcp/linnaeus)

![Carl Linnaeus](https://raw.github.com/djcp/linnaeus/master/images/linnaeus.jpg)

Linnaeus is a redis-backed naive Bayesian classification system. Please see the [rdoc](http://rubydoc.info/gems/linnaeus/) for more information. Ruby 1.9 is required.

Examples
--------

    lt = Linnaeus::Trainer.new      # Used to train documents
    lc = Linnaeus::Classifier.new   # Used to classify documents

    lt.train 'language', 'Ruby is a dynamic, reflective, general-purpose object-oriented programming language that combines syntax inspired by Perl with Smalltalk-like features.'
    lt.train 'database', 'PostgreSQL, often simply Postgres, is an object-relational database management system (ORDBMS) available for many platforms including Linux, FreeBSD, Solaris, Microsoft Windows and Mac OS X.'

    lc.classify 'Perl is a high-level, general-purpose, interpreted, dynamic programming language.' # returns "language"


Contributing to linnaeus
------------------------

* Submit bugs to the github issue tracker: https://github.com/djcp/linnaeus/issues
* If you'd like to add a feature, please submit a description of it to the issue tracker so we can discuss.
* If the feature makes sense, fork the github repository. Write rspec tests and issue a pull request when your change is done.

The Future
----------

* Create additional storage backends - sqlite, postgresql, mongodb, etc.
* Allow for weighting tweaks.

Copyright
---------

Copyright (c) 2012 Dan Collis-Puro. See LICENSE.txt for further details.

Credits
-------

* Image courtesy wikipedia. About Carl Linnaeus: http://en.wikipedia.org/wiki/Linnaeus
