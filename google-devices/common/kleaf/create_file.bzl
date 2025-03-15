# SPDX-License-Identifier: GPL-2.0-only

"""
Create a file by concatenating source files and appending contents.
"""

load("//build/kernel/kleaf:hermetic_tools.bzl", "hermetic_toolchain")

def _create_file_impl(ctx):
    hermetic_tools = hermetic_toolchain.get(ctx)
    srcs = list(ctx.files.srcs)
    out = ctx.outputs.out

    if ctx.attr.content:
        content_file = ctx.actions.declare_file(ctx.attr.name + "/content")
        ctx.actions.write(
            output = content_file,
            content = "\n".join(ctx.attr.content) + "\n",
        )
        srcs.append(content_file)

    add_newline = """
        echo >> "{out}"
    """.format(out = out.path)

    ctx.actions.run_shell(
        inputs = srcs,
        tools = hermetic_tools.deps,
        outputs = [out],
        command = hermetic_tools.setup + add_newline.join([
            """
            cat "{src}" >> "{out}"
            """.format(src = src.path, out = out.path)
            for src in srcs
        ]),
    )

    return [DefaultInfo(files = depset([out]))]

create_file = rule(
    implementation = _create_file_impl,
    doc = "Create a file by concatenating source files and appending contents",
    attrs = {
        "out": attr.output(
            doc = "Path of the output file, relative to this package.",
            mandatory = True,
        ),
        "srcs": attr.label_list(
            doc = "List of source files which will be concatenated to the output file.",
            allow_files = True,
        ),
        "content": attr.string_list(
            doc = "List of strings which will be appended to the output file after `srcs`.",
        ),
    },
    toolchains = [hermetic_toolchain.type],
)
