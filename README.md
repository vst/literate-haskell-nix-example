# Nix-Backed Literate Haskell with Markdown

This repository contains a simple example of how to render literate Haskell
programs written in Markdown using Nix.

This very `README` file is a literate Haskell program written in Markdown. All
`haskell` code blocks are rendered as Haskell source code which can be compiled
using `ghc`, loaded into a GHCi session, executed using `runhaskell`, tested via
`doctest`, etc.

We are using the [markdown-unlit](https://github.com/sol/markdown-unlit) tool to
extract the Haskell code blocks from Markdown files and feed them to GHC and
other tools. Its documentation is quite good and worth reading.

Everything we need to work on this literate Haskell program is provided by the
Nix shell. It is quite simple and straightforward:

```nix
{ pkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05") { }
, ...
}:

let
  ## Our ghc with all necessary dependencies and tools:
  ghc = pkgs.haskellPackages.ghcWithPackages (pkgs: [
    pkgs.doctest
    pkgs.markdown-unlit
    pkgs.unordered-containers
  ]);
in
## Build and export the shell:
pkgs.mkShell {
  ## Our build inputs:
  buildInputs = [
    ## Haskell input:
    ghc

    ## Further development dependencies (optional):
    pkgs.marksman
    pkgs.nil
    pkgs.nixpkgs-fmt
    pkgs.nodePackages.prettier
  ];

  ## Our environment variables which are used by the Haskell
  ## build tools, especially `doctest` in our case:
  NIX_GHC = "${ghc}/bin/ghc";
  NIX_GHCPKG = "${ghc}/bin/ghc-pkg";
  NIX_GHC_DOCDIR = "${ghc}/share/doc/ghc/html";
  NIX_GHC_LIBDIR = "${ghc}/lib/ghc-9.6.5/lib";
}
```

## Quickstart

Given following codeblock:

```haskell
main :: IO ()
main = putStrLn "Greetings from Literate Haskell!"
```

... we can run it using `runhaskell`:

```console
$ runhaskell -pgmLmarkdown-unlit README.lhs
Greetings from Literate Haskell!
```

... or load it into GHCi:

```console
$ ghci -v0 -pgmLmarkdown-unlit README.lhs
λ> main
Greetings from Literate Haskell!
```

... or compile it using `ghc`:

```console
$ ghc -pgmLmarkdown-unlit README.lhs
[1 of 2] Compiling Main             ( README.lhs, README.o )
[2 of 2] Linking README
```

... and run it:

```console
$ ./README
Greetings from Literate Haskell!
```

## Extensions and Dependencies

How about some language extensions and a third party library?

Let's put a `{-# LANGUAGE OverloadedLists #-}` pragma at the top of the file:

```haskell top
{-# LANGUAGE OverloadedLists #-}
```

And use the `unordered-containers` package:

```haskell top
import qualified Data.HashSet as S
```

The `unordered-containers` package should be available to our GHC environment.
This is achieved by adding it to our `ghc` inside the Nix shell.

Now, let's use them. Note the use of `OverloadedLists` extension to create a
`HashSet`:

```haskell
-- | Demonstrate the use of overloaded lists to create a hash-map:
--
-- >>> :t mySet
-- mySet :: S.HashSet Int
-- >>> mySet
-- fromList [1,2,3,7,42]
mySet :: S.HashSet Int
mySet = [1, 2, 3, 7, 42]
```

## Running doctests

`doctest` is a very handy tool for testing Haskell code snippets. And it works
here, too. First the function annotated with `doctest`s:

```haskell
-- | A sad function that attempts to divide a given integer
-- by another one.
--
-- >>> sadDivide 42 7
-- 6
-- >>> sadDivide 0 42
-- 0
-- >>> sadDivide 42 0
-- *** Exception: divide by zero
sadDivide :: Int -> Int -> Int
sadDivide x y = x `div` y
```

Now, let's run all these using `doctest`:

```console
$ doctest -pgmLmarkdown-unlit README.lhs
Examples: 5  Tried: 5  Errors: 0  Failures: 0
```

## Wrap-Up

You can study the `shell.nix` file to see how the Nix shell is set up. I marked
this repository as a GitHub template repository, so you can use it as a starting
point for your own literate Haskell projects. Just click the "Use this
template".

## License

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
software, either in source code form or as a compiled binary, for any purpose,
commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
