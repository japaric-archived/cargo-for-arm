FROM ubuntu:15.10

COPY prepare-arm-chroot.sh build-cargo.sh /

CMD /bin/bash /prepare-arm-chroot.sh
