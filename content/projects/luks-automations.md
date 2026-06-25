---
title: "LUKS Automations"
github: https://github.com/chr0n1x/luks-utils
tags: ["openssl", "bash", "security", "disk-encryption", "redundancy"]
date: 2026-04-14
---

I don't trust big tech anymore. Neither should you! This project documents how
I set up & automate rsyncs to my LUKS drives.

<!--more-->

The setup in the blog is simple - zero out your drives, set a passphrase,
rsync things over, close drive.

The reason why I set up this repository and its scripts though is because I
found the semantics around initializing and _then_ mounting the devices to be
cumbersome.

With this repo, assuming that the scripts are in `$PATH` - all I have to do
now is something like:

```bash
luks-mount sda cold-store
full-sync
luks-close sda cold-store
```

The idea being that I as a human know that I have a drive `sda` that's listed
in `lsblk` and I call it "cold-store" - I don't want to have to keep in mind
that `luksUtils` will place it in `/dev/mapper` or whatnot.

I use this particular setup to back up the most crucial portions of my homelab
with storage on my NAS. I use
[the SMB CSI operator](https://github.com/kubernetes-csi/csi-driver-smb)
for applications running on my K8s cluster that do not need crazy high
throughput, so this setup also lets me safely dump application data into my
LUKS drives too. For example, I run an instance of
[Immich](https://immich.app/) because I don't want Google to train its
automations/AI on the faces of my family. With this setup applications running
on k8s are covered; I have backups _and_ they're encrypted! Yay for data
sovereignty!
