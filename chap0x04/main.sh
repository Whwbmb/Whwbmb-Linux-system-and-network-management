#!/usr/bin/env bash

# 获取当前 Linux 操作系统 CPU 信息
cat /proc/cpuinfo

# 获取当前 Linux 发行版信息
cat /etc/issue
cat /etc/*-release
lsb_release -a

# 获取当前 Linux 内核信息
cat /proc/version
uname -a

# 获取当前系统的磁盘使用情况
df -h

# 查看当前系统的在线用户
w

# 查看当前系统的 IP 地址
ip a

# 查看当前系统的进程信息
ps aux

