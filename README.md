# NAME

List::AllUtils - Combines List::Util and List::SomeUtils in one bite-sized package

# VERSION

version 0.10

# SYNOPSIS

    use List::AllUtils qw( first any );

    # _Everything_ from List::Util and List::SomeUtils
    use List::AllUtils qw( :all );

    my @numbers = ( 1, 2, 3, 5, 7 );
    # or don't import anything
    return List::AllUtils::first { $_ > 5 } @numbers;

# DESCRIPTION

Are you sick of trying to remember whether a particular helper is
defined in [List::Util](https://metacpan.org/pod/List::Util) or [List::SomeUtils](https://metacpan.org/pod/List::SomeUtils)? I sure am. Now you
don't have to remember. This module will export all of the functions
that either of those two modules defines.

Note that all function documentation has been shamelessly copied from
[List::Util](https://metacpan.org/pod/List::Util) and [List::SomeUtils](https://metacpan.org/pod/List::SomeUtils).

## Which One Wins?

Recently, [List::Util](https://metacpan.org/pod/List::Util) has started including some of the subs that used to
only be in [List::SomeUtils](https://metacpan.org/pod/List::SomeUtils). This module always exports the version provided
by [List::Util](https://metacpan.org/pod/List::Util).

The docs below come from [List::Util](https://metacpan.org/pod/List::Util) 1.31 and [List::SomeUtils](https://metacpan.org/pod/List::SomeUtils) 0.50.

# LIST-REDUCTION FUNCTIONS

The following set of functions all reduce a list down to a single value.

## reduce BLOCK LIST

Reduces LIST by calling BLOCK, in a scalar context, multiple times,
setting `$a` and `$b` each time. The first call will be with `$a`
and `$b` set to the first two elements of the list, subsequent
calls will be done by setting `$a` to the result of the previous
call and `$b` to the next element in the list.

Returns the result of the last call to BLOCK. If LIST is empty then
`undef` is returned. If LIST only contains one element then that
element is returned and BLOCK is not executed.

    $foo = reduce { $a < $b ? $a : $b } 1..10       # min
    $foo = reduce { $a lt $b ? $a : $b } 'aa'..'zz' # minstr
    $foo = reduce { $a + $b } 1 .. 10               # sum
    $foo = reduce { $a . $b } @bar                  # concat

If your algorithm requires that `reduce` produce an identity value, then
make sure that you always pass that identity value as the first argument to prevent
`undef` being returned

    $foo = reduce { $a + $b } 0, @values;             # sum with 0 identity value

The remaining list-reduction functions are all specialisations of this
generic idea.

## first BLOCK LIST

Similar to `grep` in that it evaluates BLOCK setting `$_` to each element
of LIST in turn. `first` returns the first element where the result from
BLOCK is a true value. If BLOCK never returns true or LIST was empty then
`undef` is returned.

    $foo = first { defined($_) } @list    # first defined value in @list
    $foo = first { $_ > $value } @list    # first value in @list which
                                          # is greater than $value

This function could be implemented using `reduce` like this

    $foo = reduce { defined($a) ? $a : wanted($b) ? $b : undef } undef, @list

for example wanted() could be defined() which would return the first
defined value in @list

## max LIST

Returns the entry in the list with the highest numerical value. If the
list is empty then `undef` is returned.

    $foo = max 1..10                # 10
    $foo = max 3,9,12               # 12
    $foo = max @bar, @baz           # whatever

This function could be implemented using `reduce` like this

    $foo = reduce { $a > $b ? $a : $b } 1..10

## maxstr LIST

Similar to `max`, but treats all the entries in the list as strings
and returns the highest string as defined by the `gt` operator.
If the list is empty then `undef` is returned.

    $foo = maxstr 'A'..'Z'          # 'Z'
    $foo = maxstr "hello","world"   # "world"
    $foo = maxstr @bar, @baz        # whatever

This function could be implemented using `reduce` like this

    $foo = reduce { $a gt $b ? $a : $b } 'A'..'Z'

## min LIST

Similar to `max` but returns the entry in the list with the lowest
numerical value. If the list is empty then `undef` is returned.

    $foo = min 1..10                # 1
    $foo = min 3,9,12               # 3
    $foo = min @bar, @baz           # whatever

This function could be implemented using `reduce` like this

    $foo = reduce { $a < $b ? $a : $b } 1..10

## minstr LIST

Similar to `min`, but treats all the entries in the list as strings
and returns the lowest string as defined by the `lt` operator.
If the list is empty then `undef` is returned.

    $foo = minstr 'A'..'Z'          # 'A'
    $foo = minstr "hello","world"   # "hello"
    $foo = minstr @bar, @baz        # whatever

This function could be implemented using `reduce` like this

    $foo = reduce { $a lt $b ? $a : $b } 'A'..'Z'

## sum LIST

Returns the sum of all the elements in LIST. If LIST is empty then
`undef` is returned.

    $foo = sum 1..10                # 55
    $foo = sum 3,9,12               # 24
    $foo = sum @bar, @baz           # whatever

This function could be implemented using `reduce` like this

    $foo = reduce { $a + $b } 1..10

## sum0 LIST

Similar to `sum`, except this returns 0 when given an empty list, rather
than `undef`.

# KEY/VALUE PAIR LIST FUNCTIONS

The following set of functions, all inspired by [List::Pairwise](https://metacpan.org/pod/List::Pairwise), consume
an even-sized list of pairs. The pairs may be key/value associations from a
hash, or just a list of values. The functions will all preserve the original
ordering of the pairs, and will not be confused by multiple pairs having the
same "key" value - nor even do they require that the first of each pair be a
plain string.

## pairgrep BLOCK KVLIST

Similar to perl's `grep` keyword, but interprets the given list as an
even-sized list of pairs. It invokes the BLOCK multiple times, in scalar
context, with `$a` and `$b` set to successive pairs of values from the
KVLIST.

Returns an even-sized list of those pairs for which the BLOCK returned true
in list context, or the count of the **number of pairs** in scalar context.
(Note, therefore, in scalar context that it returns a number half the size
of the count of items it would have returned in list context).

    @subset = pairgrep { $a =~ m/^[[:upper:]]+$/ } @kvlist

Similar to `grep`, `pairgrep` aliases `$a` and `$b` to elements of the
given list. Any modifications of it by the code block will be visible to
the caller.

## pairfirst BLOCK KVLIST

Similar to the `first` function, but interprets the given list as an
even-sized list of pairs. It invokes the BLOCK multiple times, in scalar
context, with `$a` and `$b` set to successive pairs of values from the
KVLIST.

Returns the first pair of values from the list for which the BLOCK returned
true in list context, or an empty list of no such pair was found. In scalar
context it returns a simple boolean value, rather than either the key or the
value found.

    ( $key, $value ) = pairfirst { $a =~ m/^[[:upper:]]+$/ } @kvlist

Similar to `grep`, `pairfirst` aliases `$a` and `$b` to elements of the
given list. Any modifications of it by the code block will be visible to
the caller.

## pairmap BLOCK KVLIST

Similar to perl's `map` keyword, but interprets the given list as an
even-sized list of pairs. It invokes the BLOCK multiple times, in list
context, with `$a` and `$b` set to successive pairs of values from the
KVLIST.

Returns the concatenation of all the values returned by the BLOCK in list
context, or the count of the number of items that would have been returned
in scalar context.

    @result = pairmap { "The key $a has value $b" } @kvlist

Similar to `map`, `pairmap` aliases `$a` and `$b` to elements of the
given list. Any modifications of it by the code block will be visible to
the caller.

## pairs KVLIST

A convenient shortcut to operating on even-sized lists of pairs, this
function returns a list of ARRAY references, each containing two items from
the given list. It is a more efficient version of

    pairmap { [ $a, $b ] } KVLIST

It is most convenient to use in a `foreach` loop, for example:

    foreach ( pairs @KVLIST ) {
       my ( $key, $value ) = @$_;
       ...
    }

## pairkeys KVLIST

A convenient shortcut to operating on even-sized lists of pairs, this
function returns a list of the the first values of each of the pairs in
the given list. It is a more efficient version of

    pairmap { $a } KVLIST

## pairvalues KVLIST

A convenient shortcut to operating on even-sized lists of pairs, this
function returns a list of the the second values of each of the pairs in
the given list. It is a more efficient version of

    pairmap { $b } KVLIST

# OTHER FUNCTIONS

## shuffle LIST

Returns the elements of LIST in a random order

    @cards = shuffle 0..51      # 0..51 in a random order

# List::SomeUtils FUNCTIONS

## Junctions

### _Treatment of an empty list_

There are two schools of thought for how to evaluate a junction on an
empty list:

- Reduction to an identity (boolean)
- Result is undefined (three-valued)

In the first case, the result of the junction applied to the empty list is
determined by a mathematical reduction to an identity depending on whether
the underlying comparison is "or" or "and". Conceptually:

                    "any are true"      "all are true"
                    --------------      --------------
    2 elements:     A || B || 0         A && B && 1
    1 element:      A || 0              A && 1
    0 elements:     0                   1

In the second case, three-value logic is desired, in which a junction applied
to an empty list returns `undef` rather than true or false.

Junctions with a `_u` suffix implement three-valued logic. Those
without are boolean.

### all BLOCK LIST

### all\_u BLOCK LIST

Returns a true value if all items in LIST meet the criterion given through
BLOCK. Sets `$_` for each item in LIST in turn:

    print "All values are non-negative"
      if all { $_ >= 0 } ($x, $y, $z);

For an empty LIST, `all` returns true (i.e. no values failed the condition)
and `all_u` returns `undef`.

Thus, `all_u(@list)` is equivalent to `@list ? all(@list) : undef`.

**Note**: because Perl treats `undef` as false, you must check the return value
of `all_u` with `defined` or you will get the opposite result of what you
expect.

### any BLOCK LIST

### any\_u BLOCK LIST

Returns a true value if any item in LIST meets the criterion given through
BLOCK. Sets `$_` for each item in LIST in turn:

    print "At least one non-negative value"
      if any { $_ >= 0 } ($x, $y, $z);

For an empty LIST, `any` returns false and `any_u` returns `undef`.

Thus, `any_u(@list)` is equivalent to `@list ? any(@list) : undef`.

### none BLOCK LIST

### none\_u BLOCK LIST

Logically the negation of `any`. Returns a true value if no item in LIST meets
the criterion given through BLOCK. Sets `$_` for each item in LIST in turn:

    print "No non-negative values"
      if none { $_ >= 0 } ($x, $y, $z);

For an empty LIST, `none` returns true (i.e. no values failed the condition)
and `none_u` returns `undef`.

Thus, `none_u(@list)` is equivalent to `@list ? none(@list) : undef`.

**Note**: because Perl treats `undef` as false, you must check the return value
of `none_u` with `defined` or you will get the opposite result of what you
expect.

### notall BLOCK LIST

### notall\_u BLOCK LIST

Logically the negation of `all`. Returns a true value if not all items in LIST
meet the criterion given through BLOCK. Sets `$_` for each item in LIST in
turn:

    print "Not all values are non-negative"
      if notall { $_ >= 0 } ($x, $y, $z);

For an empty LIST, `notall` returns false and `notall_u` returns `undef`.

Thus, `notall_u(@list)` is equivalent to `@list ? notall(@list) : undef`.

### one BLOCK LIST

### one\_u BLOCK LIST

Returns a true value if precisely one item in LIST meets the criterion
given through BLOCK. Sets `$_` for each item in LIST in turn:

    print "Precisely one value defined"
        if one { defined($_) } @list;

Returns false otherwise.

For an empty LIST, `one` returns false and `one_u` returns `undef`.

The expression `one BLOCK LIST` is almost equivalent to
`1 == true BLOCK LIST`, except for short-cutting.
Evaluation of BLOCK will immediately stop at the second true value.

## Transformation

### apply BLOCK LIST

Applies BLOCK to each item in LIST and returns a list of the values after BLOCK
has been applied. In scalar context, the last element is returned. This
function is similar to `map` but will not modify the elements of the input
list:

    my @list = (1 .. 4);
    my @mult = apply { $_ *= 2 } @list;
    print "\@list = @list\n";
    print "\@mult = @mult\n";
    __END__
    @list = 1 2 3 4
    @mult = 2 4 6 8

Think of it as syntactic sugar for

    for (my @mult = @list) { $_ *= 2 }

### insert\_after BLOCK VALUE LIST

Inserts VALUE after the first item in LIST for which the criterion in BLOCK is
true. Sets `$_` for each item in LIST in turn.

    my @list = qw/This is a list/;
    insert_after { $_ eq "a" } "longer" => @list;
    print "@list";
    __END__
    This is a longer list

### insert\_after\_string STRING VALUE LIST

Inserts VALUE after the first item in LIST which is equal to STRING.

    my @list = qw/This is a list/;
    insert_after_string "a", "longer" => @list;
    print "@list";
    __END__
    This is a longer list

### pairwise BLOCK ARRAY1 ARRAY2

Evaluates BLOCK for each pair of elements in ARRAY1 and ARRAY2 and returns a
new list consisting of BLOCK's return values. The two elements are set to `$a`
and `$b`. Note that those two are aliases to the original value so changing
them will modify the input arrays.

    @a = (1 .. 5);
    @b = (11 .. 15);
    @x = pairwise { $a + $b } @a, @b;     # returns 12, 14, 16, 18, 20

    # mesh with pairwise
    @a = qw/a b c/;
    @b = qw/1 2 3/;
    @x = pairwise { ($a, $b) } @a, @b;    # returns a, 1, b, 2, c, 3

### mesh ARRAY1 ARRAY2 \[ ARRAY3 ... \]

### zip ARRAY1 ARRAY2 \[ ARRAY3 ... \]

Returns a list consisting of the first elements of each array, then
the second, then the third, etc, until all arrays are exhausted.

Examples:

    @x = qw/a b c d/;
    @y = qw/1 2 3 4/;
    @z = mesh @x, @y;         # returns a, 1, b, 2, c, 3, d, 4

    @a = ('x');
    @b = ('1', '2');
    @c = qw/zip zap zot/;
    @d = mesh @a, @b, @c;   # x, 1, zip, undef, 2, zap, undef, undef, zot

`zip` is an alias for `mesh`.

### uniq LIST

### distinct LIST

Returns a new list by stripping duplicate values in LIST by comparing
the values as hash keys, except that undef is considered separate from ''.
The order of elements in the returned list is the same as in LIST. In
scalar context, returns the number of unique elements in LIST.

    my @x = uniq 1, 1, 2, 2, 3, 5, 3, 4; # returns 1 2 3 5 4
    my $x = uniq 1, 1, 2, 2, 3, 5, 3, 4; # returns 5
    # returns "Mike", "Michael", "Richard", "Rick"
    my @n = distinct "Mike", "Michael", "Richard", "Rick", "Michael", "Rick"
    # returns '', 'S1', A5' and complains about "Use of uninitialized value"
    my @s = distinct '', undef, 'S1', 'A5'
    # returns undef, 'S1', A5' and complains about "Use of uninitialized value"
    my @w = uniq undef, '', 'S1', 'A5'

`distinct` is an alias for `uniq`.

**RT#49800** can be used to give feedback about this behavior.

### singleton

Returns a new list by stripping values in LIST occurring more than once by
comparing the values as hash keys, except that undef is considered separate
from ''. The order of elements in the returned list is the same as in LIST.
In scalar context, returns the number of elements occurring only once in LIST.

    my @x = singleton 1,1,2,2,3,4,5 # returns 3 4 5

## Partitioning

### after BLOCK LIST

Returns a list of the values of LIST after (and not including) the point
where BLOCK returns a true value. Sets `$_` for each element in LIST in turn.

    @x = after { $_ % 5 == 0 } (1..9);    # returns 6, 7, 8, 9

### after\_incl BLOCK LIST

Same as `after` but also includes the element for which BLOCK is true.

### before BLOCK LIST

Returns a list of values of LIST up to (and not including) the point where BLOCK
returns a true value. Sets `$_` for each element in LIST in turn.

### before\_incl BLOCK LIST

Same as `before` but also includes the element for which BLOCK is true.

### part BLOCK LIST

Partitions LIST based on the return value of BLOCK which denotes into which
partition the current value is put.

Returns a list of the partitions thusly created. Each partition created is a
reference to an array.

    my $i = 0;
    my @part = part { $i++ % 2 } 1 .. 8;   # returns [1, 3, 5, 7], [2, 4, 6, 8]

You can have a sparse list of partitions as well where non-set partitions will
be undef:

    my @part = part { 2 } 1 .. 10;            # returns undef, undef, [ 1 .. 10 ]

Be careful with negative values, though:

    my @part = part { -1 } 1 .. 10;
    __END__
    Modification of non-creatable array value attempted, subscript -1 ...

Negative values are only ok when they refer to a partition previously created:

    my @idx  = ( 0, 1, -1 );
    my $i    = 0;
    my @part = part { $idx[$++ % 3] } 1 .. 8; # [1, 4, 7], [2, 3, 5, 6, 8]

## Iteration

### each\_array ARRAY1 ARRAY2 ...

Creates an array iterator to return the elements of the list of arrays ARRAY1,
ARRAY2 throughout ARRAYn in turn. That is, the first time it is called, it
returns the first element of each array. The next time, it returns the second
elements. And so on, until all elements are exhausted.

This is useful for looping over more than one array at once:

    my $ea = each_array(@a, @b, @c);
    while ( my ($a, $b, $c) = $ea->() )   { .... }

The iterator returns the empty list when it reached the end of all arrays.

If the iterator is passed an argument of '`index`', then it returns
the index of the last fetched set of values, as a scalar.

### each\_arrayref LIST

Like each\_array, but the arguments are references to arrays, not the
plain arrays.

### natatime EXPR, LIST

Creates an array iterator, for looping over an array in chunks of
`$n` items at a time. (n at a time, get it?). An example is
probably a better explanation than I could give in words.

Example:

    my @x = ('a' .. 'g');
    my $it = natatime 3, @x;
    while (my @vals = $it->())
    {
      print "@vals\n";
    }

This prints

    a b c
    d e f
    g

## Searching

### bsearch BLOCK LIST

Performs a binary search on LIST which must be a sorted list of values. BLOCK
must return a negative value if the current element (stored in `$_`) is smaller,
a positive value if it is bigger and zero if it matches.

Returns a boolean value in scalar context. In list context, it returns the element
if it was found, otherwise the empty list.

### bsearchidx BLOCK LIST

### bsearch\_index BLOCK LIST

Performs a binary search on LIST which must be a sorted list of values. BLOCK
must return a negative value if the current element (stored in `$_`) is smaller,
a positive value if it is bigger and zero if it matches.

Returns the index of found element, otherwise `-1`.

`bsearch_index` is an alias for `bsearchidx`.

### firstval BLOCK LIST

### first\_value BLOCK LIST

Returns the first element in LIST for which BLOCK evaluates to true. Each
element of LIST is set to `$_` in turn. Returns `undef` if no such element
has been found.

`first_value` is an alias for `firstval`.

### onlyval BLOCK LIST

### only\_value BLOCK LIST

Returns the only element in LIST for which BLOCK evaluates to true. Sets
`$_` for each item in LIST in turn. Returns `undef` if no such element
has been found.

`only_value` is an alias for `onlyval`.

### lastval BLOCK LIST

### last\_value BLOCK LIST

Returns the last value in LIST for which BLOCK evaluates to true. Each element
of LIST is set to `$_` in turn. Returns `undef` if no such element has been
found.

`last_value` is an alias for `lastval`.

### firstres BLOCK LIST

### first\_result BLOCK LIST

Returns the result of BLOCK for the first element in LIST for which BLOCK
evaluates to true. Each element of LIST is set to `$_` in turn. Returns
`undef` if no such element has been found.

`first_result` is an alias for `firstres`.

### onlyres BLOCK LIST

### only\_result BLOCK LIST

Returns the result of BLOCK for the first element in LIST for which BLOCK
evaluates to true. Sets `$_` for each item in LIST in turn. Returns
`undef` if no such element has been found.

`only_result` is an alias for `onlyres`.

### lastres BLOCK LIST

### last\_result BLOCK LIST

Returns the result of BLOCK for the last element in LIST for which BLOCK
evaluates to true. Each element of LIST is set to `$_` in turn. Returns
`undef` if no such element has been found.

`last_result` is an alias for `lastres`.

### indexes BLOCK LIST

Evaluates BLOCK for each element in LIST (assigned to `$_`) and returns a list
of the indices of those elements for which BLOCK returned a true value. This is
just like `grep` only that it returns indices instead of values:

    @x = indexes { $_ % 2 == 0 } (1..10);   # returns 1, 3, 5, 7, 9

### firstidx BLOCK LIST

### first\_index BLOCK LIST

Returns the index of the first element in LIST for which the criterion in BLOCK
is true. Sets `$_` for each item in LIST in turn:

    my @list = (1, 4, 3, 2, 4, 6);
    printf "item with index %i in list is 4", firstidx { $_ == 4 } @list;
    __END__
    item with index 1 in list is 4

Returns `-1` if no such item could be found.

`first_index` is an alias for `firstidx`.

### onlyidx BLOCK LIST

### only\_index BLOCK LIST

Returns the index of the only element in LIST for which the criterion
in BLOCK is true. Sets `$_` for each item in LIST in turn:

    my @list = (1, 3, 4, 3, 2, 4);
    printf "uniqe index of item 2 in list is %i", onlyidx { $_ == 2 } @list;
    __END__
    unique index of item 2 in list is 4

Returns `-1` if either no such item or more than one of these
has been found.

`only_index` is an alias for `onlyidx`.

### lastidx BLOCK LIST

### last\_index BLOCK LIST

Returns the index of the last element in LIST for which the criterion in BLOCK
is true. Sets `$_` for each item in LIST in turn:

    my @list = (1, 4, 3, 2, 4, 6);
    printf "item with index %i in list is 4", lastidx { $_ == 4 } @list;
    __END__
    item with index 4 in list is 4

Returns `-1` if no such item could be found.

`last_index` is an alias for `lastidx`.

## Sorting

### sort\_by BLOCK LIST

Returns the list of values sorted according to the string values returned by the
KEYFUNC block or function. A typical use of this may be to sort objects according
to the string value of some accessor, such as

    sort_by { $_->name } @people

The key function is called in scalar context, being passed each value in turn as
both $\_ and the only argument in the parameters, @\_. The values are then sorted
according to string comparisons on the values returned.
This is equivalent to

    sort { $a->name cmp $b->name } @people

except that it guarantees the name accessor will be executed only once per value.
One interesting use-case is to sort strings which may have numbers embedded in them
"naturally", rather than lexically.

    sort_by { s/(\d+)/sprintf "%09d", $1/eg; $_ } @strings

This sorts strings by generating sort keys which zero-pad the embedded numbers to
some level (9 digits in this case), helping to ensure the lexical sort puts them
in the correct order.

### nsort\_by BLOCK LIST

Similar to sort\_by but compares its key values numerically.

## Counting and calculation

### true BLOCK LIST

Counts the number of elements in LIST for which the criterion in BLOCK is true.
Sets `$_` for  each item in LIST in turn:

    printf "%i item(s) are defined", true { defined($_) } @list;

### false BLOCK LIST

Counts the number of elements in LIST for which the criterion in BLOCK is false.
Sets `$_` for each item in LIST in turn:

    printf "%i item(s) are not defined", false { defined($_) } @list;

### minmax LIST

Calculates the minimum and maximum of LIST and returns a two element list with
the first element being the minimum and the second the maximum. Returns the
empty list if LIST was empty.

The `minmax` algorithm differs from a naive iteration over the list where each
element is compared to two values being the so far calculated min and max value
in that it only requires 3n/2 - 2 comparisons. Thus it is the most efficient
possible algorithm.

However, the Perl implementation of it has some overhead simply due to the fact
that there are more lines of Perl code involved. Therefore, LIST needs to be
fairly big in order for `minmax` to win over a naive implementation. This
limitation does not apply to the XS version.

# EXPORTS

This module exports nothing by default. You can import functions by
name, or get everything with the `:all` tag.

# SEE ALSO

`List::Util` and `List::SomeUtils`, obviously.

Also see `Util::Any`, which unifies many more util modules, and also
lets you rename functions as part of the import.

# BUGS

Please report any bugs or feature requests to
`bug-list-allutils@rt.cpan.org`, or through the web interface at
[http://rt.cpan.org](http://rt.cpan.org).  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

Bugs may be submitted through [the RT bug tracker](http://rt.cpan.org/Public/Dist/Display.html?Name=List-AllUtils)
(or [bug-list-allutils@rt.cpan.org](mailto:bug-list-allutils@rt.cpan.org)).

I am also usually active on IRC as 'drolsky' on `irc://irc.perl.org`.

# DONATIONS

If you'd like to thank me for the work I've done on this module, please
consider making a "donation" to me via PayPal. I spend a lot of free time
creating free software, and would appreciate any support you'd care to offer.

Please note that **I am not suggesting that you must do this** in order for me
to continue working on this particular software. I will continue to do so,
inasmuch as I have in the past, for as long as it interests me.

Similarly, a donation made in this way will probably not make me work on this
software much more, unless I get so many donations that I can consider working
on free software full time (let's all have a chuckle at that together).

To donate, log into PayPal and send money to autarch@urth.org, or use the
button at [http://www.urth.org/~autarch/fs-donation.html](http://www.urth.org/~autarch/fs-donation.html).

# AUTHOR

Dave Rolsky &lt;autarch@urth.org>

# CONTRIBUTOR

Ricardo Signes &lt;rjbs@cpan.org>

# COPYRIGHT AND LICENCE

This software is Copyright (c) 2016 by Dave Rolsky.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)
