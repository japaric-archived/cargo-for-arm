set -ex

install_qemu() {
  # Needed for the post-install hooks of qemu-user-static to work correctly
  # Note: needs the Docker container to be run in "privileged" mode, i.e. `docker run --privileged`
  mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

  apt-get update
  apt-get install -y --force-yes --no-install-recommends curl qemu-user-static
}

# and register binfmt
mk_arm_chroot() {
  local binfmt=/proc/sys/fs/binfmt_misc/

  mkdir /trusty
  curl -s http://cdimage.ubuntu.com/ubuntu-core/releases/trusty/release/ubuntu-core-14.04.4-core-armhf.tar.gz | tar -C /trusty -xz
  cp /usr/bin/qemu-arm-static /trusty/usr/bin

  # if already registered, unregister first
  if [ -f $binfmt/arm ]; then
    echo -1 > $binfmt/arm
  fi

  echo ':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:' > $binfmt/register
}

prepare_for_chroot() {
  mount -t proc /proc /trusty/proc
  mount -o bind /dev /trusty/dev
  mount -o bind /dev/pts /trusty/dev/pts
  mount -o bind /sys /trusty/sys
  cp /etc/resolv.conf /trusty/etc
}

mk_cargo() {
  cp build-cargo.sh /trusty
  chroot /trusty /bin/bash build-cargo.sh
}

main() {
  install_qemu
  mk_arm_chroot
  prepare_for_chroot
  mk_cargo
}

main
