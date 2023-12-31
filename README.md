[![CI](https://github.com/goregath/base64.bash/actions/workflows/tests.yml/badge.svg)](https://github.com/goregath/base64.bash/actions/workflows/tests.yml)


# base64.bash

One of the *fastest*&#x2A; pure bash base64 decoder out there.

This implementation is fully self-contained and does not rely on any external programs.

Tested with _GNU Bash 5.1_ down to _4.1_, striving for full support from _4.1+_.

<sub>&#x2A; *Compared to alternative implementations*</sub>

## Usage

The command line interface follows [base64(1)] from [coreutils], but only decoding mode `-d` is supported.

```plain
USAGE: base64 -d [FILE]
```

## Library Mode

The library is meant to be sourced without prerequisites, it does not alter shell options or flags.

```bash
#!/usr/bin/env bash
set -euE -o pipefail
source base64.bash

base64 -d <<<"aGVsbG8gd29ybGQhCg=="
```
```plain
hello world!
```

## Standalone Mode

There is also support for a standalone mode, where the library can act as an executable.

```plain
$ bash base64.bash -d <<<"aGVsbG8gd29ybGQhCg=="
```
Alternatively the file can be installed to *PATH*.
```
$ install -m u+w,a+rx base64.bash ~/.local/bin/base64
$ base64 -d <<<"aGVsbG8gd29ybGQhCg=="
```

## Why it is "fast"

This implementation makes use of the [`base#n`][bash(1)] notation, an arithmetic feature common to bash, zsh or ash (busybox).

The base can be set as high as 64, using a consistent order of symbols up to base 62 starting with the digits `0-9`, followed by lower case letters `a-z`, then upper case letters `A-Z`. A base of 64 adds two more characters, `@` (at-sign) and `_` (underscore), representing values of 62 and 63, respectively. That is, both encodings share the same symbols for the values of 0 to 61, there are only two symbols left that need to be translated in order to satisfy the bash encoding. Once a symbol has been read, the decoding work greatly reduces to remapping the obtained value from one enconding to another.

|         | base64 | 64#n  |         |
|--------:|:------:|:-----:|:--------|
| `0-25`  | `A–Z`  | `0-9` | `0-9`   |
| `26-51` | `a–z`  | `a-z` | `10-35` |
| `52-61` | `0–9`  | `A-Z` | `36-61` |
| `62`    | `+`    | `@`   | `62`    |
| `62`    | `/`    | `_`   | `63`    |

There is a dual use to this approach: Input data can, with subtle modification, be *directly converted to numbers* - and it can be fed in using a proper *word size*. As base64 encodes three bytes (*3×8 bit*) of data into four symbols (*4×6 bit*) and vice versa, the input *word size* should be four symbols wide. The decoder can be tuned to read four characters in a row, remap `+` and `/` and convert it to a *24 bit* integer to do some math.

## Requirements

Only _GNU Bash 4.1+_ is required with array support enabled at compile time.

[bash(1)]: http://www.kernel.org/doc/man-pages/online/pages/man1/bash.1.html#ARITHMETIC_EVALUATION "bash(1) Arithmetic Evaluation"
[base64(1)]: http://www.kernel.org/doc/man-pages/online/pages/man1/base64.1.html "Manpage of base64(1)"
[coreutils]: https://www.gnu.org/software/coreutils/manual/coreutils.html "GNU Coreutils Manual"