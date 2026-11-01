# httpcamels

An HTTP codes API as an OCaml unikernel.

```shell
mirage configure -t unix
make depends
dune build
./dist/httpcamels
```

Use `-t hvt` instead of `-t unix` on Linux for Solo5 unikernels

Optionally (to delete generated files) :

```shell
mirage clean
```
