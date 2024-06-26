## Building the kernels

This project was started in order to streamline our benchmarking practice for PREEMPT_RT Linux on
the Raspberry Pi 5.

In order to reproduce the experiments yourself, first install Raspberry Pi OS Lite (Debian 12) to an
SD card by following [these instructions](https://www.raspberrypi.com/software/).
With the SD card still inserted and the corresponding file systems mounted, execute:

```bash
./deploykernels.sh <path_mounted_bootfs> <path_mounted_rootfs>
```

This will build the docker image that builds the stock Linux kernel and the kernel patched with
PREEMPT_RT that were used in our benchmarks.
The script will also automatically copy the kernel images to your SD card.

After inserting the SD card back into your Raspberry Pi and booting into the system, you can select
which kernel to use by editing the Raspberry Pi's `/boot/firmware/config.txt` file.
Reboot your system to load the selected kernel.

## Running the benchmarks

The following commands were used in order to benchmark the system.
Mind that running the benchmarks will completely freeze the Raspberry Pi for one hour.

### Installing the tools

Cyclictest is part of the RT-Tests library:

```bash
sudo apt update
sudo apt upgrade -y
sudo rpi-eeprom-update -a
sudo apt install -y build-essential libnuma-dev git
git clone git://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git
cd rt-tests/
git checkout stable/v1.0
make all
sudo make install
```

iperf3 will need to be installed on the Raspberry Pi and on the external computer sending the packets:

```bash
sudo apt install iperf3
```

Upon installing, you will be prompted with a screen asking you if you want to run iperf3 as a daemon.
You can decline this if you want.

### Setting up iperf3

You will need an external computer for running the iperf3 networking stressors.
This computer and the Raspberry Pi will need to be connected to the same network.
Run the following command on your Raspberry Pi to set it up as an iperf3 server:

```bash
iperf3 -s -D > iperf3log
```

### Running the benchmarks

Run the following command on the external computer to start sending packets to the Raspberry Pi,
fill in the IP of your Raspberry Pi:

```bash
iperf3 -c <IP> -w 64K -P 100 -t 3800
```

Notice that these packets will be sent out for a duration of 3800 seconds, so you only have 200
seconds aka 3 minutes to run the following command, after which the benchmarking process begins.
Afterwards, your results can be found in the specified `cyclictest_X.txt` file.

```bash
sudo docker run --rm colinianking/stress-ng --all 1 -t1h 1> /dev/null &
sudo cyclictest -vmn -i100 -p99 -t --duration=1h > cyclictest_X.txt
```
