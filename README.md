# httpcamels

An HTTP codes API as an OCaml unikernel.

<p align="center">
  <img src="./static/assets/app/logo.png" width="170">
</p>

## Usage

### Requirements

Install opam dependencies (needed by [client/](./client/)) with:

```shell
opam install brr js_of_ocaml-compiler
```

### Build and run the unikernel

```shell
make                # Uses the Unix target by default
./dist/httpcamels
```

> [!NOTE]
> In Unix target, if there is no **tap** device (`tap0` specifically), or the unikernel can't open one, it won't start. You can use the host's sockets with ([checkout MirageOS docs](https://mirage.io/docs/hello-world)):
>
> ```shell
> make CONFIGURE_FLAGS="--net host"
> ```

When targeting *Solo5* use:

```shell
make TARGET=hvt
```

(*That's what I'm personally using for deployment*)

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.