#!/usr/bin/env python3

from pythainer.builders import UbuntuDockerBuilder
from pythainer.examples.builders import get_user_builder
from pythainer.examples.runners import personal_runner
from pythainer.runners import ConcreteDockerRunner


def get_rtlinux_builder(
    image_name: str,
    base_image: str = "ubuntu:22.04",
) -> UbuntuDockerBuilder:
    user_name = "user"
    work_dir = "/home/${USER_NAME}/workspace"
    lib_dir = f"{work_dir}/libraries"

    docker_builder = get_user_builder(
        image_name=image_name,
        base_ubuntu_image=base_image,
        user_name=user_name,
        lib_dir=lib_dir,
        packages=[
            "sed",
            "make",
            "binutils",
            "gcc",
            "g++",
            "bash",
            "patch",
            "gzip",
            "bzip2",
            "perl",
            "tar",
            "cpio",
            "python3",
            "unzip",
            "rsync",
            "wget",
            "libncurses-dev",
        ],
    )
    docker_builder.space()

    docker_builder.user("root")
    docker_builder.add_packages(
        packages=[
            "git",
            "bc",
            "bison",
            "flex",
            "libssl-dev",
            "make",
            "libc6-dev",
            "libncurses5-dev",
            "crossbuild-essential-arm64",
        ]
    )
    docker_builder.user("${USER_NAME}")
    docker_builder.space()

    docker_builder.workdir(path=work_dir)

    docker_builder.run(command="git clone --depth=1 https://github.com/raspberrypi/linux")
    docker_builder.workdir("linux")
    docker_builder.env(name="KERNEL", value="kernel_2712")
    # docker_builder.env(name="ARCH", value="arm64")
    # docker_builder.env(name="CROSS_COMPILE", value="aarch64-linux-gnu-")
    # docker_builder.env(name="KERNEL", value="kernel_2712")
    # docker_builder.run(command="make bcm2712_defconfig")
    docker_builder.run(command="make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig")
    docker_builder.run(
        command="make -j $(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs"
    )

    return docker_builder


def buildrun():
    image_name = "pi5rtlinux"
    docker_builder = get_rtlinux_builder(
        image_name=image_name,
    )
    docker_builder.build()

    docker_builder.generate_build_script()

    docker_runner = ConcreteDockerRunner(
        image=image_name,
        name=image_name,
        environment_variables={},
        volumes={},
        devices=[],
        network="host",
    )
    docker_runner |= personal_runner()

    cmd = docker_runner.get_command()
    print(" ".join(cmd))

    docker_runner.generate_script()
    docker_runner.run()


def main():
    buildrun()


if __name__ == "__main__":
    main()
