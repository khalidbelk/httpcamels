FROM ocaml/opam:debian-12-ocaml-5.4 AS builder
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
  pkg-config m4 build-essential libgmp-dev libseccomp-dev \
  && rm -rf /var/lib/apt/lists/*

USER opam

RUN opam update
RUN opam install -y brr js_of_ocaml-compiler
RUN opam install -y mirage.4.11.2 opam-monorepo.0.4.3
RUN opam install -y solo5.0.12.1 ocaml-solo5

RUN git clone https://github.com/khalidbelk/httpcamels httpcamels
WORKDIR /home/opam/httpcamels
RUN opam exec -- make TARGET=hvt

FROM scratch
COPY --from=builder /home/opam/httpcamels/dist/httpcamels.hvt /httpcamels.hvt
COPY --from=builder /home/opam/httpcamels/solo5.json /solo5.json

ENTRYPOINT ["/httpcamels.hvt"]
