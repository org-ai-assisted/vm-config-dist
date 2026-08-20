#!/bin/sh

## Copyright (C) 2020 - 2026 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## style-ok: no-strict
## Sourced-only login-shell fragment: enabling strict-mode here would leak
## 'set -o errexit'/'nounset' into (and could kill) the sourcing shell.

## Fall back to the 'softwarecontext' QML renderer when GL is software-rendered:
## it avoids GL crashes in e.g. Monero and signal-desktop (and hurts shotcut,
## kdenlive).
## https://www.kicksecure.com/wiki/Tuning#Renderer
## https://github.com/monero-project/monero-gui/issues/2878
## https://forums.whonix.org/t/video-editing-software-fails-to-launch-on-whonix-virtualbox-kvm/17241
##
## The renderer detection lives in helper-scripts 'detect-software-rendering'
## (vm-config-dist depends on it); it prints 'software', 'accelerated' or
## 'unknown'. How it decides is documented there -- not restated here.
##
## Policy of THIS consumer: set QMLSCENE_DEVICE only when it is unset (an explicit
## user choice wins) and only on a confident 'software'. 'accelerated' and
## 'unknown' err toward acceleration-available and leave it unset -- forcing
## software rendering where hardware acceleration exists is the worse mistake.

if command -v detect-software-rendering >/dev/null 2>/dev/null \
   && [ -z "${QMLSCENE_DEVICE+x}" ] \
   && [ "$(detect-software-rendering 2>/dev/null)" = "software" ]; then
   export QMLSCENE_DEVICE=softwarecontext
fi
