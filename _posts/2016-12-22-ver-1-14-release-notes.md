---
layout: post
title: "Rust 1.14 release notes"
author: Giang Nguyen
url: /2016/12/22/ver-1-14-release-notes.html
description: "Hỗ trợ thêm nhiều nền tảng, và WebAssembly, ..."
---
The Rust team is happy to announce the latest version of Rust, 1.14.0. Rust is a
systems programming language focused on safety, speed, and concurrency.

As always, you can [install Rust 1.14.0][install] from the appropriate page on our
website, and check out the [detailed release notes for 1.14.0][notes] on GitHub.
1230 patches were landed in this release.

[install]: https://www.rust-lang.org/install.html
[notes]: https://github.com/rust-lang/rust/blob/master/RELEASES.md#version-1140-2016-12-22

### What's in 1.14.0 stable

One of the biggest features in Rust 1.14 isn't actually in Rust 1.14: the
[rustup tool has reached a 1.0 release][rustup], and is now the recomended way
to install Rust from the project directly. Rustup does a bit more than just
install Rust:

> rustup installs The Rust Programming Language from the official release
> channels, enabling you to easily switch between stable, beta, and nightly
> compilers and keep them updated. It makes cross-compiling simpler with binary
> builds of the standard library for common platforms. And it runs on all
> platforms Rust supports, including Windows.

[rustup]: https://internals.rust-lang.org/t/beta-testing-rustup-rs/3316/203

We had [a previous post about Rustup][prev] back in May. You can learn more
about it there, or by checking it out [on
GitHub](https://github.com/rust-lang-nursery/rustup.rs)

[prev]: https://blog.rust-lang.org/2016/05/13/rustup.html

Another exciting feature is [experimental support for WebAssembly][wasm] as a
target, `wasm32-unknown-emscripten`. It is still early days, and there's a lot
of bugs to shake out, so please give it a try and report them! To give you a
small taste of how it works, one you have [emscripten] installed, compiling
some Rust code to WebAssembly is as easy as:

```bash
$ rustup target add wasm32-unknown-emscripten
$ echo 'fn main() { println!("Hello, Emscripten!"); }' > hello.rs
$ rustc --target=wasm32-unknown-emscripten hello.rs
$ node hello.js
```

[wasm]: https://users.rust-lang.org/t/compiling-to-the-web-with-rust-and-emscripten/7627
[emscripten]: http://kripken.github.io/emscripten-site/docs/getting_started/downloads.html

The community has been doing intertesting, experimental work in this area: see
[Jan-Erik's slides] for the workshop he ran at [Rust Belt Rust] for some
examples, or check out [Tim's example of the classic TodoMVC project][todomvc].
This implementation builds off of his [webplatform
crate](https://crates.io/crates/webplatform), which exposes the DOM to Rust.

[Jan-Erik's slides]: http://www.hellorust.com/emscripten/
[Rust Belt Rust]: http://www.rust-belt-rust.com/sessions/
[todomvc]: http://timryan.org/rust-todomvc/

Speaking of platforms, a large number of platforms have gained additional
support:

For `rustc`:

* `mips-unknown-linux-gnu`
* `mipsel-unknown-linux-gnu`
* `mips64-unknown-linux-gnuabi64`
* `mips64el-unknown-linux-gnuabi64`
* `powerpc-unknown-linux-gnu`
* `powerpc64-unknown-linux-gnu`
* `powerpc64le-unknown-linux-gnu`
* `s390x-unknown-linux-gnu`

And for `std`:

* `arm-unknown-linux-musleabi`
* `arm-unknown-linux-musleabihf`
* `armv7-unknown-linux-musleabihf`

If you're using one of these platforms, follow the instructions on the website
to install, or add the targets to an existing installation with
`rustup target add`.

These platforms are all 'tier 2', please see our page on [platform support] for
more details.

[platform support]: https://forge.rust-lang.org/platform-support.html

The landing of MIR over the last few releases means that a [number of
improvements to compile times] have landed, with more coming in the future.
Exact numbers are hard, as they depend on what code you're compiling, but
broadly speaking, compile times should be the same or faster.

[numer of improvements to compile times]: https://github.com/rust-lang/rust/blob/master/RELEASES.md#compile-time-optimizations

In the language, one small improvement has landed: support for [RFC 1492]. This small
additional lets you use `..` in more places. Previously, say you had a struct like this:

```rust
struct Point {
    x: i32,
    y: i32,
    z: i32,
}
```

In any context where you're doing a pattern match, you could use `..` to ignore the
parts you don't care about. For example:


```rust
let p = Point { x: 0, y: 1, z: 2 };

match p {
    Point { x, .. } => println!("x is {}", x),
}
```

The `..` ignores `y` and `z`.

Consider a similar `Point`, but as a tuple struct:

```rust
struct Point(i32, i32, i32);
```

Previously, you could use `..` to ignore all three elements:

```rust
let p = Point(0, 1, 2);

match p {
    Point(..) => println!("found a point"),
}
```

But you could not use it to only ignore parts of the tuple:

```rust
let p = Point(0, 1, 2);

match p {
    Point(x, ..) => println!("x is {}", x),
}
```

This was a inconsistency, and so with RFC 1492 stabilized, compiles fine as of
this release. This applies to more situations than tuples; please see [the
RFC][RFC 1492] for more details.

[RFC 1492]: https://github.com/rust-lang/rfcs/blob/master/text/1492-dotdot-in-patterns.md


Language
--------

* [`..` matches multiple tuple fields in enum variants, structs
  and tuples][36843]. [RFC 1492].
* [Safe `fn` items can be coerced to `unsafe fn` pointers][37389]
* [`use *` and `use ::*` both glob-import from the crate root][37367]
* [It's now possible to call a `Vec<Box<Fn()>>` without explicit
  dereferencing][36822]

Compiler
--------

* [Mark enums with non-zero discriminant as non-zero][37224]
* [Lower-case `static mut` names are linted like other
  statics and consts][37162]
* [Fix ICE on some macros in const integer positions
   (e.g. `[u8; m!()]`)][36819]
* [Improve error message and snippet for "did you mean `x`"][36798]
* [Add a panic-strategy field to the target specification][36794]
* [Include LLVM version in `--version --verbose`][37200]

Compile-time Optimizations
--------------------------

* [Improve macro expansion performance][37569]
* [Shrink `Expr_::ExprInlineAsm`][37445]
* [Replace all uses of SHA-256 with BLAKE2b][37439]
* [Reduce the number of bytes hashed by `IchHasher`][37427]
* [Avoid more allocations when compiling html5ever][37373]
* [Use `SmallVector` in `CombineFields::instantiate`][37322]
* [Avoid some allocations in the macro parser][37318]
* [Use a faster deflate setting][37298]
* [Add `ArrayVec` and `AccumulateVec` to reduce heap allocations
  during interning of slices][37270]
* [Optimize `write_metadata`][37267]
* [Don't process obligation forest cycles when stalled][37231]
* [Avoid many `CrateConfig` clones][37161]
* [Optimize `Substs::super_fold_with`][37108]
* [Optimize `ObligationForest`'s `NodeState` handling][36993]
* [Speed up `plug_leaks`][36917]

Libraries
---------

* [`println!()`, with no arguments, prints newline][36825].
  Previously, an empty string was required to achieve the same.
* [`Wrapping` impls standard binary and unary operators, as well as
   the `Sum` and `Product` iterators][37356]
* [Implement `From<Cow<str>> for String` and `From<Cow<[T]>> for
  Vec<T>`][37326]
* [Improve `fold` performance for `chain`, `cloned`, `map`, and
  `VecDeque` iterators][37315]
* [Improve `SipHasher` performance on small values][37312]
* [Add Iterator trait TrustedLen to enable better FromIterator /
  Extend][37306]
* [Expand `.zip()` specialization to `.map()` and `.cloned()`][37230]
* [`ReadDir` implements `Debug`][37221]
* [Implement `RefUnwindSafe` for atomic types][37178]
* [Specialize `Vec::extend` to `Vec::extend_from_slice`][37094]
* [Avoid allocations in `Decoder::read_str`][37064]
* [`io::Error` implements `From<io::ErrorKind>`][37037]
* [Impl `Debug` for raw pointers to unsized data][36880]
* [Don't reuse `HashMap` random seeds][37470]
* [The internal memory layout of `HashMap` is more cache-friendly, for
  significant improvements in some operations][36692]
* [`HashMap` uses less memory on 32-bit architectures][36595]
* [Impl `Add<{str, Cow<str>}>` for `Cow<str>`][36430]

Cargo
-----

* [Expose rustc cfg values to build scripts][cargo/3243]
* [Allow cargo to work with read-only `CARGO_HOME`][cargo/3259]
* [Fix passing --features when testing multiple packages][cargo/3280]
* [Use a single profile set per workspace][cargo/3249]
* [Load `replace` sections from lock files][cargo/3220]
* [Ignore `panic` configuration for test/bench profiles][cargo/3175]

Tooling
-------

* [rustup is the recommended Rust installation method][1.14rustup]
* This release includes host (rustc) builds for Linux on MIPS, PowerPC, and
  S390x. These are [tier 2] platforms and may have major defects. Follow the
  instructions on the website to install, or add the targets to an existing
  installation with `rustup target add`. The new target triples are:
  - `mips-unknown-linux-gnu`
  - `mipsel-unknown-linux-gnu`
  - `mips64-unknown-linux-gnuabi64`
  - `mips64el-unknown-linux-gnuabi64 `
  - `powerpc-unknown-linux-gnu`
  - `powerpc64-unknown-linux-gnu`
  - `powerpc64le-unknown-linux-gnu`
  - `s390x-unknown-linux-gnu `
* This release includes target (std) builds for ARM Linux running MUSL
  libc. These are [tier 2] platforms and may have major defects. Add the
  following triples to an existing rustup installation with `rustup target add`:
  - `arm-unknown-linux-musleabi`
  - `arm-unknown-linux-musleabihf`
  - `armv7-unknown-linux-musleabihf`
* This release includes [experimental support for WebAssembly][1.14wasm], via
  the `wasm32-unknown-emscripten` target. This target is known to have major
  defects. Please test, report, and fix.
* rustup no longer installs documentation by default. Run `rustup
  component add rust-docs` to install.
* [Fix line stepping in debugger][37310]
* [Enable line number debuginfo in releases][37280]

Misc
----

* [Disable jemalloc on aarch64/powerpc/mips][37392]
* [Add support for Fuchsia OS][37313]
* [Detect local-rebuild by only MAJOR.MINOR version][37273]

Compatibility Notes
-------------------

* [A number of forward-compatibility lints used by the compiler
  to gradually introduce language changes have been converted
  to deny by default][36894]:
  - ["use of inaccessible extern crate erroneously allowed"][36886]
  - ["type parameter default erroneously allowed in invalid location"][36887]
  - ["detects super or self keywords at the beginning of global path"][36888]
  - ["two overlapping inherent impls define an item with the same name
    were erroneously allowed"][36889]
  - ["floating-point constants cannot be used in patterns"][36890]
  - ["constants of struct or enum type can only be used in a pattern if
     the struct or enum has `#[derive(PartialEq, Eq)]`"][36891]
  - ["lifetimes or labels named `'_` were erroneously allowed"][36892]
* [Prohibit patterns in trait methods without bodies][37378]
* [The atomic `Ordering` enum may not be matched exhaustively][37351]
* [Future-proofing `#[no_link]` breaks some obscure cases][37247]
* [The `$crate` macro variable is accepted in fewer locations][37213]
* [Impls specifying extra region requirements beyond the trait
  they implement are rejected][37167]
* [Enums may not be unsized][37111]. Unsized enums are intended to
  work but never have. For now they are forbidden.
* [Enforce the shadowing restrictions from RFC 1560 for today's macros][36767]

[tier 2]: https://forge.rust-lang.org/platform-support.html
[1.14rustup]: https://internals.rust-lang.org/t/beta-testing-rustup-rs/3316/204
[1.14wasm]: https://users.rust-lang.org/t/compiling-to-the-web-with-rust-and-emscripten/7627
[36430]: https://github.com/rust-lang/rust/pull/36430
[36595]: https://github.com/rust-lang/rust/pull/36595
[36595]: https://github.com/rust-lang/rust/pull/36595
[36692]: https://github.com/rust-lang/rust/pull/36692
[36767]: https://github.com/rust-lang/rust/pull/36767
[36794]: https://github.com/rust-lang/rust/pull/36794
[36798]: https://github.com/rust-lang/rust/pull/36798
[36819]: https://github.com/rust-lang/rust/pull/36819
[36822]: https://github.com/rust-lang/rust/pull/36822
[36825]: https://github.com/rust-lang/rust/pull/36825
[36843]: https://github.com/rust-lang/rust/pull/36843
[36880]: https://github.com/rust-lang/rust/pull/36880
[36886]: https://github.com/rust-lang/rust/issues/36886
[36887]: https://github.com/rust-lang/rust/issues/36887
[36888]: https://github.com/rust-lang/rust/issues/36888
[36889]: https://github.com/rust-lang/rust/issues/36889
[36890]: https://github.com/rust-lang/rust/issues/36890
[36891]: https://github.com/rust-lang/rust/issues/36891
[36892]: https://github.com/rust-lang/rust/issues/36892
[36894]: https://github.com/rust-lang/rust/pull/36894
[36917]: https://github.com/rust-lang/rust/pull/36917
[36993]: https://github.com/rust-lang/rust/pull/36993
[37037]: https://github.com/rust-lang/rust/pull/37037
[37064]: https://github.com/rust-lang/rust/pull/37064
[37094]: https://github.com/rust-lang/rust/pull/37094
[37108]: https://github.com/rust-lang/rust/pull/37108
[37111]: https://github.com/rust-lang/rust/pull/37111
[37161]: https://github.com/rust-lang/rust/pull/37161
[37162]: https://github.com/rust-lang/rust/pull/37162
[37167]: https://github.com/rust-lang/rust/pull/37167
[37178]: https://github.com/rust-lang/rust/pull/37178
[37200]: https://github.com/rust-lang/rust/pull/37200
[37213]: https://github.com/rust-lang/rust/pull/37213
[37221]: https://github.com/rust-lang/rust/pull/37221
[37224]: https://github.com/rust-lang/rust/pull/37224
[37230]: https://github.com/rust-lang/rust/pull/37230
[37231]: https://github.com/rust-lang/rust/pull/37231
[37247]: https://github.com/rust-lang/rust/pull/37247
[37267]: https://github.com/rust-lang/rust/pull/37267
[37270]: https://github.com/rust-lang/rust/pull/37270
[37273]: https://github.com/rust-lang/rust/pull/37273
[37280]: https://github.com/rust-lang/rust/pull/37280
[37298]: https://github.com/rust-lang/rust/pull/37298
[37306]: https://github.com/rust-lang/rust/pull/37306
[37310]: https://github.com/rust-lang/rust/pull/37310
[37312]: https://github.com/rust-lang/rust/pull/37312
[37313]: https://github.com/rust-lang/rust/pull/37313
[37315]: https://github.com/rust-lang/rust/pull/37315
[37318]: https://github.com/rust-lang/rust/pull/37318
[37322]: https://github.com/rust-lang/rust/pull/37322
[37326]: https://github.com/rust-lang/rust/pull/37326
[37351]: https://github.com/rust-lang/rust/pull/37351
[37356]: https://github.com/rust-lang/rust/pull/37356
[37367]: https://github.com/rust-lang/rust/pull/37367
[37373]: https://github.com/rust-lang/rust/pull/37373
[37378]: https://github.com/rust-lang/rust/pull/37378
[37389]: https://github.com/rust-lang/rust/pull/37389
[37392]: https://github.com/rust-lang/rust/pull/37392
[37427]: https://github.com/rust-lang/rust/pull/37427
[37439]: https://github.com/rust-lang/rust/pull/37439
[37445]: https://github.com/rust-lang/rust/pull/37445
[37470]: https://github.com/rust-lang/rust/pull/37470
[37569]: https://github.com/rust-lang/rust/pull/37569
[RFC 1492]: https://github.com/rust-lang/rfcs/blob/master/text/1492-dotdot-in-patterns.md
[cargo/3175]: https://github.com/rust-lang/cargo/pull/3175
[cargo/3220]: https://github.com/rust-lang/cargo/pull/3220
[cargo/3243]: https://github.com/rust-lang/cargo/pull/3243
[cargo/3249]: https://github.com/rust-lang/cargo/pull/3249
[cargo/3259]: https://github.com/rust-lang/cargo/pull/3259
[cargo/3280]: https://github.com/rust-lang/cargo/pull/3280
