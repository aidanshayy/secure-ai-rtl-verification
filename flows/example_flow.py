#!/usr/bin/env python3
"""Minimal SiliconCompiler ASIC flow for the tiny_counter example."""

from pathlib import Path

from siliconcompiler import ASIC, Design
from siliconcompiler.targets import freepdk45_demo


ROOT = Path(__file__).resolve().parents[1]


def build_project() -> ASIC:
    design = Design("tiny_counter")
    design.set_dataroot("repo", str(ROOT))

    with design.active_dataroot("repo"), design.active_fileset("rtl"):
        design.set_topmodule("tiny_counter")
        design.add_file("designs/example/tiny_counter.v")

    with design.active_dataroot("repo"), design.active_fileset("sdc"):
        design.add_file("designs/example/tiny_counter.sdc")

    project = ASIC(design)
    project.add_fileset("rtl")
    project.add_fileset("sdc")
    project.option.set_builddir(str(ROOT / "build"))
    project.option.set_nodashboard(True)

    # FreePDK45/Nangate45 is bundled through lambdapdk and is useful for local
    # baseline learning. It is not intended as a signoff manufacturing PDK.
    freepdk45_demo(project)
    return project


def main() -> None:
    project = build_project()
    project.run()
    project.summary()
    project.snapshot()


if __name__ == "__main__":
    main()
