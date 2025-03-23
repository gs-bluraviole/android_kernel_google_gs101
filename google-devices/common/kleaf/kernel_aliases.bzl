# SPDX-License-Identifier: GPL-2.0-only

"""
Defines helper functions for creating kernel aliases.
"""

def kernel_aliases(name, flag, targets, packages):
    for idx, pkg in enumerate(packages):
        native.config_setting(
            name = "{}_{}".format(name, idx),
            flag_values = {
                flag: pkg,
            },
        )

    for target in targets:
        native.alias(
            name = target,
            actual = select({
                ":{}_{}".format(name, idx): "{}:{}".format(pkg, target)
                for idx, pkg in enumerate(packages)
            }),
        )
