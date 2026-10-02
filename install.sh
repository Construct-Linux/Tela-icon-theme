#!/bin/sh
# Installs Tela, Tela-dark and Tela-light. Tela holds every icon; the dark and light variants
# carry only the icons they recolor and link the rest to Tela.
#
# POSIX sh and busybox are enough: the links are written relative by hand, since busybox's ln
# has no -r. No icon cache is built: GTK reads a theme without one, and a distribution bakes
# its own.
set -eu

SRC_DIR=$(cd "$(dirname "$0")" && pwd)
NAME=Tela

if [ "$(id -u)" -eq 0 ]; then
  DEST_DIR=/usr/share/icons
else
  DEST_DIR="${HOME}/.local/share/icons"
fi

usage() {
  cat << EOF
Usage: $0 [OPTION]...

Installs ${NAME}, ${NAME}-dark and ${NAME}-light.

OPTIONS:
  -d DIR    Destination directory (default: ${DEST_DIR})
  -r, -u    Remove the themes instead
  -h        Show this help
EOF
}

# begin VARIANT: an empty theme directory with its index.theme ("Tela dark" for Tela-dark).
begin() {
  dir="${DEST_DIR}/${NAME}${1:+-$1}"
  rm -rf "${dir}"
  mkdir -p "${dir}"
  sed "s/%NAME%/${NAME}${1:+ $1}/g" "${SRC_DIR}/src/index.theme" > "${dir}/index.theme"
  chmod 644 "${dir}/index.theme"
}

# link_rest: links into ${dir} every directory of Tela the variant has no copy of.
link_rest() {
  for top in 16 22 24 32 scalable symbolic; do
    if [ -d "${dir}/${top}" ]; then
      for sub in "${DEST_DIR}/${NAME}/${top}"/*; do
        sub=${sub##*/}
        [ -e "${dir}/${top}/${sub}" ] || ln -s "../../${NAME}/${top}/${sub}" "${dir}/${top}/${sub}"
      done
    else
      ln -s "../${NAME}/${top}" "${dir}/${top}"
    fi
  done
}

hidpi_links() {
  for size in 16 22 24 32 scalable; do
    ln -s "${size}" "${dir}/${size}@2x"
  done
}

install_tela() {
  begin ""
  cp -R "${SRC_DIR}"/src/16 "${SRC_DIR}"/src/22 "${SRC_DIR}"/src/24 "${SRC_DIR}"/src/32 \
    "${SRC_DIR}"/src/scalable "${SRC_DIR}"/src/symbolic "${dir}"
  # links/ is symlinks only; -P keeps them links.
  cp -RP "${SRC_DIR}"/links/* "${dir}"
  hidpi_links
}

install_dark() {
  begin dark
  for size in 16 22 24; do
    mkdir -p "${dir}/${size}"
    cp -R "${SRC_DIR}/src/${size}/actions" "${SRC_DIR}/src/${size}/devices" \
      "${SRC_DIR}/src/${size}/places" "${dir}/${size}"
  done
  cp -R "${SRC_DIR}/src/symbolic" "${dir}"

  # The greys lightened, to read on a dark background. Before the links are copied, so sed
  # rewrites only real files.
  sed -i "s/#565656/#aaaaaa/g" "${dir}"/16/actions/*.svg "${dir}"/22/actions/*.svg \
    "${dir}"/24/actions/*.svg "${dir}"/symbolic/*/*.svg
  sed -i "s/#727272/#aaaaaa/g" "${dir}"/16/places/*.svg "${dir}"/22/places/*.svg \
    "${dir}"/24/places/*.svg "${dir}"/16/devices/*.svg "${dir}"/22/devices/*.svg \
    "${dir}"/24/devices/*.svg

  for size in 16 22 24; do
    cp -RP "${SRC_DIR}/links/${size}/actions" "${SRC_DIR}/links/${size}/devices" \
      "${SRC_DIR}/links/${size}/places" "${dir}/${size}"
  done
  cp -RP "${SRC_DIR}/links/symbolic" "${dir}"

  link_rest
  hidpi_links
}

install_light() {
  begin light
  for size in 16 22 24; do
    mkdir -p "${dir}/${size}"
    cp -R "${SRC_DIR}/src/${size}/panel" "${dir}/${size}"
  done

  # The panel's light grey darkened, to read on a light top bar.
  sed -i "s/#dfdfdf/#505050/g" "${dir}"/16/panel/*.svg "${dir}"/22/panel/*.svg \
    "${dir}"/24/panel/*.svg

  for size in 16 22 24; do
    cp -RP "${SRC_DIR}/links/${size}/panel" "${dir}/${size}"
  done

  link_rest
  hidpi_links
}

uninstall=false
while [ $# -gt 0 ]; do
  case "$1" in
    -d) DEST_DIR="$2"; shift ;;
    -r|-u) uninstall=true ;;
    -h) usage; exit 0 ;;
    *) echo "Unrecognized option '$1'." >&2; usage >&2; exit 1 ;;
  esac
  shift
done

if [ "${uninstall}" = true ]; then
  rm -rf "${DEST_DIR}/${NAME}" "${DEST_DIR}/${NAME}-dark" "${DEST_DIR}/${NAME}-light"
  exit 0
fi

echo "Installing ${NAME}, ${NAME}-dark and ${NAME}-light in ${DEST_DIR}"
install_tela
install_dark
install_light
