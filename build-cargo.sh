set -ex

user=rust

as_user() {
  su -c 'bash -c "'"${@}"'"' $rust
}

install_deps() {
  apt-get update

  # multirust
  apt-get install -y --force-yes --no-install-recommends ca-certificates curl file git

  # cargo
  # TODO we want link to ssl statically not dynamically
  apt-get install -y --force-yes --no-install-recommends \
    cmake gcc libcurl4-openssl-dev libssl-dev pkg-config
}

mk_user() {
  useradd -m $user
}

install_multirust() {
  local temp_dir=$(mktemp -d)

  chown $user:$user $temp_dir

  as_user "
    git config --global pack.threads 1
    git clone --depth 1 https://github.com/brson/multirust $temp_dir
    cd $temp_dir && ./build.sh
  "

  pushd $temp_dir
  ./install.sh
  popd

  rm -rf $temp_dir
}

# Unofficial binaries
install_rust_and_cargo() {
  local rust="https://www.dropbox.com/s/j0jkiptbtyiwnv4/rust-1.8.0-nightly-2016-02-24-f6f050d-arm-unknown-linux-gnueabihf-ea7ee6a8eb65016961507d20c5ed3b5c2b1ea4fe.tar.gz?dl=1"
  local cargo="https://www.dropbox.com/s/epxkuaokyw2db04/cargo-0.9.0-nightly-2016-02-25-e721289-arm-unknown-linux-gnueabihf-5a68cf71a55f4eb4c5e8fd077f5b33498b0062aa.tar.gz?dl=1"
  local out_dir="~/unofficial-nightly"
  local channel=unofficial-nightly

  as_user "
    mkdir $out_dir
    curl -sL $rust | tar -C $out_dir -xz
    curl -sL $cargo | tar -C $out_dir -xz
    multirust update $channel --link-local $out_dir
    multirust default $channel
    rustc -V
    cargo -V
  "
}

build_cargo() {
  as_user "
    git clone --depth 1 https://github.com/rust-lang/cargo ~/cargo
    cd ~/cargo
    cargo build -j1
  "
}

main() {
  mk_user
  install_deps
  install_multirust
  install_rust_and_cargo
  build_cargo
}

main
