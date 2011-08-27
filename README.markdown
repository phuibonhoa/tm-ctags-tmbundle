TM Ctags
========

##Description

CTag support originally by [sbenhaim/tm-ctags-tmbundle](http://github.com/sbenhaim/tm-ctags-tmbundle).

My additions to this bundle include:

* Ability to backtrack.  When you jump to a method / class your current position is saved.  ⌘⇧+B will take you back to your previous location.
* Support for background indexing
* Rubymine keybindings
* Indexing of Factory_Girl Factories (by [Dan Luchi](http://github.com/danluchi))
* Indexing of Shared Shoulds, Setups and Contexts (by [Michael G Pearce](http://github.com/michaelgpearce))

### Ctags code completion and navigation for TextMate.

Update Project Tags
-------------------

### ⌥⌘P

Builds or updates the tag index in the root directory of your project. This is a prerequisite to running any of the other commands in this bundle and should be run as your project changes.

I have a non-polling solution that indexes projects in the background (see below for more info)

Jump to Method Definition (Select from a list of methods if multiple matches)
-------------------

### ⌃] or ⌘+B

Jumps to the file and line where the tag under the cursor is defined.

Autocomplete Method (Select from a list of method(args) if multiple matches)
------------

### ⌘< or ⌃+Space

Provides completions for the current word&mdash;including method/function arguments&mdash;pulling from the functions, methods, and classes defined in your project.

Jump to Method Definition
--------------

### ⌘⇧P or ⌘⌃+Space

Prompts for a tag (or the start of a tag) and jumps to the file and line where that tag is defined.

Shell Variables (advanced)
--------------------------

**TM\_CTAGS\_EXT\_LIB**

You can now exploit tags in another project by pointing the TM\_CTAGS\_EXT\_LIB project variable at another project root with a .tmtags file. Thanks to [seanfarley](http://github.com/seanfarley "seanfarley") for this contribution.

**TM\_CTAGS\_EXCLUDES**

Space-delimited list of files or directories you don't want tagged. Shell wildcards work. (.git, .svn, and .cvs are already excluded.) For example:

<pre>.hg *.js</pre>

**TM\_CTAGS\_INCLUDES**

Space-delimited list of files you <u>do</u> want tagged. TM\_CTAGS\_EXCLUDES is ignored if you use TM\_CTAGS\_INCLUDES. 

**Update:** These now use the same format as TM\_CTAGS\_EXCLUDES, not extended regexp format. Shell wildcards work.

**TM\_CTAGS\_OPTIONS**

Have your own ctags configuration? Save it to a file and point this shell variable at it. (Maps to --options.) Excludes and includes are ignored if you specify your own options.

(There are a few options required for proper functionality of this bundle which will be added to the argument list you provide.)

**TM\_CTAGS\_RESULT\_LIMIT**

Only 300 matching results are displayed by default. Use this setting to override this value.


##Background Indexing
I've come up with a solution that indexes my projects on change (rather than polling).  Only works on mac.  If you are interesting in setting this up, let me know and I can lend a hand when I get some free time.  I haven't yet devised a way to make this solution easily configurable / sharable.


##Credits


![BookRenter.com Logo](http://assets0.bookrenter.com/images/header/bookrenter_logo.gif "BookRenter.com")

Additions by [Philippe Huibonhoa](http://github.com/phuibonhoa), [Dan Luchi](http://github.com/danluchi) and [Michael G Pearce](http://github.com/michaelgpearce). Funded by [BookRenter.com](http://www.bookrenter.com "BookRenter.com").


Original bundle and it's contributors can be found [here](http://github.com/sbenhaim/tm-ctags-tmbundle)
