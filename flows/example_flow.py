#!/usr/bin/env python3
"""Minimal SiliconCompiler ASIC flow for the tiny_counter example."""

import argparse
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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--scheduler",
        choices=["local", "docker"],
        default="local",
        help="Run tasks locally or through SiliconCompiler's Docker scheduler.")
    parser.add_argument(
        "--docker-image",
        default=None,
        help="Optional Docker image override, for example ghcr.io/siliconcompiler/sc_runner:v0.38.2.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = build_project()
    if args.scheduler == "docker":
        project.option.scheduler.set_name("docker")
        if args.docker_image:
            project.option.scheduler.set_queue(args.docker_image)
    project.run()
    project.summary()
    project.snapshot()


if __name__ == "__main__":
    main()
