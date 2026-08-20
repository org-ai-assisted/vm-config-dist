#!/bin/sh

## Copyright (C) 2020 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## style-ok: no-strict
## Sourced-only login-shell fragment: enabling strict-mode here would leak
## 'set -o errexit'/'nounset' into (and could kill) the sourcing shell.

## Automatic fallback to the 'softwarecontext' QML renderer when the OpenGL
## renderer is (best guess) mesa's llvmpipe CPU renderer.
## https://www.kicksecure.com/wiki/Tuning#Renderer
##
## Useful for (softwarecontext avoids GL crashes):
## - Monero          https://github.com/monero-project/monero-gui/issues/2878
## - signal-desktop
## Causes issues for: shotcut, kdenlive.
## https://forums.whonix.org/t/video-editing-software-fails-to-launch-on-whonix-virtualbox-kvm/17241

## The renderer detection (a bounded, best-effort 'eglinfo' probe) lives in
## helper-scripts as 'detect-software-rendering'; vm-config-dist depends on it.
## Only set QMLSCENE_DEVICE when unset, so an explicit user choice always wins.

if command -v detect-software-rendering >/dev/null 2>/dev/null \
   && [ -z "${QMLSCENE_DEVICE:-}" ] \
   && [ "$(detect-software-rendering)" = "software" ]; then
   export QMLSCENE_DEVICE=softwarecontext
fi
