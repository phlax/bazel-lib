"""This module provides the macros for performing a release.
"""

load("@io_bazel_rules_go//go:def.bzl", "go_binary")
load(":hashes.bzl", "hashes")
load("//lib:write_source_files.bzl", "write_source_files")
load("//lib:expand_template.bzl", "expand_template")
load("//lib:utils.bzl", "to_label")

PLATFORMS = [
    struct(os = "darwin", arch = "amd64", ext = "", gc_linkopts = ["-s", "-w"]),
    struct(os = "darwin", arch = "arm64", ext = "", gc_linkopts = ["-s", "-w"]),
    struct(os = "freebsd", arch = "amd64", ext = "", gc_linkopts = ["-s", "-w"]),
    struct(os = "linux", arch = "amd64", ext = "", gc_linkopts = ["-s", "-w"]),
    struct(os = "linux", arch = "arm64", ext = "", gc_linkopts = ["-s", "-w"]),
    struct(os = "windows", arch = "amd64", ext = ".exe", gc_linkopts = []),
]

def multi_platform_go_binaries(name, embed, prefix = "", **kwargs):
    """The multi_platform_go_binaries macro creates a go_binary for each platform.

    Args:
        name: the name of the filegroup containing all go_binary targets produced
            by this macro.
        embed: the list of targets passed to each go_binary target in this
            macro.
        prefix: an optional prefix added to the output Go binary file name.
        **kwargs: extra arguments.
    """
    targets = []
    for platform in PLATFORMS:
        target_name = "{}-{}-{}".format(name, platform.os, platform.arch)
        target_label = Label("//{}:{}".format(native.package_name(), target_name))
        go_binary(
            name = target_name,
            out = "{}{}-{}_{}{}".format(prefix, name, platform.os, platform.arch, platform.ext),
            embed = embed,
            gc_linkopts = platform.gc_linkopts,
            goarch = platform.arch,
            goos = platform.os,
            pure = "on",
            visibility = ["//visibility:public"],
            **kwargs
        )
        hashes_name = "{}_hashes".format(target_name)
        hashes_label = Label("//{}:{}".format(native.package_name(), hashes_name))
        hashes(
            name = hashes_name,
            src = target_label,
            **kwargs
        )
        targets.extend([target_label, hashes_label])

    native.filegroup(
        name = name,
        srcs = targets,
        **kwargs
    )

def release(name, targets, **kwargs):
    """The release macro creates the artifact copier script.

    It's an executable script that copies all artifacts produced by the given
    targets into the provided destination. See .github/workflows/release.yml.

    Args:
        name: the name of the genrule.
        targets: a list of filegroups passed to the artifact copier.
        **kwargs: extra arguments.
    """

    expand_template(
        name = "{}_versions_stamped".format(name),
        out = "create_versions_stamped.sh",
        is_executable = True,
        substitutions = {
            "{{VERSION}}": "{{STABLE_BUILD_SCM_TAG}}",
            "{{HAS_LOCAL_CHANGES}}": "{{STABLE_BUILD_SCM_LOCAL_CHANGES}}",
        },
        template = "//tools:create_versions.sh",
        stamp = 1,
        **kwargs
    )

    native.genrule(
        name = "{}_versions".format(name),
        srcs = targets,
        outs = ["versions_generated.bzl"],
        executable = True,
        cmd = " && ".join([
            """echo '"AUTO GENERATED. DO NOT EDIT"\n' >> $@""",
        ] + [
            "./$(location :create_versions_stamped.sh) {} $(locations {}) >> $@".format(to_label(target).name, target)
            for target in targets
        ]),
        tools = [":create_versions_stamped.sh"],
        **kwargs
    )

    write_source_files(
        name = "{}_versions_checkin".format(name),
        files = {
            "versions.bzl": ":versions_generated.bzl",
        },
        **kwargs
    )

    native.genrule(
        name = name,
        srcs = targets,
        outs = ["release.sh"],
        executable = True,
        cmd = "./$(location //tools:create_release.sh) {locations} > \"$@\"".format(
            locations = " ".join(["$(locations {})".format(target) for target in targets]),
        ),
        tools = ["//tools:create_release.sh"],
        **kwargs
    )
