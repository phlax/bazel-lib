"""Our "development" dependencies

Users should *not* need to install these. If users see a load()
statement from these, that's a bug in our distribution.
"""

load("//lib:repositories.bzl", "register_coreutils_toolchains", "register_jq_toolchains", "register_yq_toolchains")
load("//lib:utils.bzl", http_archive = "maybe_http_archive")

# buildifier: disable=unnamed-macro
def bazel_lib_internal_deps():
    "Fetch deps needed for local development"
    http_archive(
        name = "io_bazel_rules_go",
        sha256 = "278b7ff5a826f3dc10f04feaf0b70d48b68748ccd512d7f98bf442077f043fe3",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.41.0/rules_go-v0.41.0.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.41.0/rules_go-v0.41.0.zip",
        ],
    )

    http_archive(
        name = "bazel_gazelle",
        sha256 = "d3fa66a39028e97d76f9e2db8f1b0c11c099e8e01bf363a923074784e451f809",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.33.0/bazel-gazelle-v0.33.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.33.0/bazel-gazelle-v0.33.0.tar.gz",
        ],
    )

    http_archive(
        name = "bazel_skylib",
        sha256 = "66ffd9315665bfaafc96b52278f57c7e2dd09f5ede279ea6d39b2be471e7e3aa",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
        ],
    )

    http_archive(
        name = "bazel_skylib_gazelle_plugin",
        sha256 = "3327005dbc9e49cc39602fb46572525984f7119a9c6ffe5ed69fbe23db7c1560",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-gazelle-plugin-1.4.2.tar.gz",
        ],
    )

    http_archive(
        name = "io_bazel_stardoc",
        sha256 = "aa814dae0ac400bbab2e8881f9915c6f47c49664bf087c409a15f90438d2c23e",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.1/stardoc-0.5.1.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.5.1/stardoc-0.5.1.tar.gz",
        ],
    )

    http_archive(
        name = "buildifier_prebuilt",
        sha256 = "e46c16180bc49487bfd0f1ffa7345364718c57334fa0b5b67cb5f27eba10f309",
        strip_prefix = "buildifier-prebuilt-6.1.0",
        urls = [
            "https://github.com/keith/buildifier-prebuilt/archive/6.1.0.tar.gz",
        ],
    )

    # Register toolchains for tests
    register_jq_toolchains()
    register_yq_toolchains()
    register_coreutils_toolchains()
