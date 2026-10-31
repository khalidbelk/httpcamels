# mirage-hello

Minimalist hello-world skeleton for MirageOS.

```shell
mirage configure -t unix
make depends
dune build
./dist/hello
```

Use `-t hvt` instead of `-t unix` on Linux for Solo5 unikernels

Optionally (to delete generated files) :

```shell
mirage clean
```
