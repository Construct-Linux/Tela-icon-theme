# Tela icon theme for CONSTRUCT

The icon theme of [CONSTRUCT](https://github.com/Construct-Linux), a GNOME desktop: a fork of
[Tela](https://github.com/vinceliuice/Tela-icon-theme) by Vince Liuice, cut down to what
CONSTRUCT ships.

- One folder color, CONSTRUCT's teal `#0097A7` with white glyphs, drawn into the SVGs
  themselves, in place of upstream's color variants.
- For GNOME 51 and later only: no Plasma colorscheme folders, no elementary/Xfce panel icons.
- Icons CONSTRUCT adds, such as `org.gnome.Decibels`.

## Install

```sh
./install.sh                          # into ~/.local/share/icons, or /usr/share/icons as root
./install.sh -d /usr/share/icons      # into a given directory
./install.sh -r                       # remove
```

It installs three themes: `Tela`, `Tela-dark` (light icons for a dark interface) and
`Tela-light` (dark top bar icons for a light one). It needs only a POSIX shell and busybox.

## License

GPL-3.0 (`COPYING`). The icons are Vince Liuice's Tela, drawn from the sources in `AUTHORS`.
