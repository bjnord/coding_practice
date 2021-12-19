# Personal Puzzle Ideas

## "Actor which does X action"

I got thinking about this today:

1. Something that transforms is a "transformer".

1. Something that correlates is a "correlator".

  > The "-er" vs "-or" spelling apparently depends on whether the verb ends in "e" or not?

1. Something that hits is a "hitter".

  > Sometimes you have to double the consonant... something to do with long and short vowels maybe?

There are probably other rules.

Can we derive a function that will correctly transform the actor back to the action? And then one that goes in the other direction?

### Tasks

- Get a database of English words that includes the type (n., v., etc.).
- Get a list of all English nouns that end in "-er" and "-or".
  - probably need to build an exclude list for edge cases (nouns that aren't actors)
- Apply transform and see if the corresponding English verb is in the list.
