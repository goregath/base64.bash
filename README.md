[![CI](https://github.com/goregath/base64.bash/actions/workflows/tests.yml/badge.svg)](https://github.com/goregath/base64.bash/actions/workflows/tests.yml)


# base64.bash

A *"fast"* base64 decoder written entirely in pure bash.

This implementation is fully self-contained and does not rely on any external programs.

Tested with _GNU Bash 5.1_, _4.4_ and _4.3_, striving for full support from _4.3+_.

## Usage

The command line interface follows [base64(1)](http://www.kernel.org/doc/man-pages/online/pages/man1/base64.1.html "Manpage of base64(1)"), but only decoding mode `-d` is supported.

```plain
USAGE: base64 -d [FILE]
```

## Example

```bash
#!/usr/bin/env bash
set -euE -o pipefail
source base64.bash

base64 -d <<<"aGVsbG8gd29ybGQhCg=="
```
```plain
hello world!
```

## Requirements

Only _GNU Bash 4.3+_ is required.