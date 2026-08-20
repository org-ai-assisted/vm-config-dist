#!/bin/sh

## Copyright (C) 2020 - 2026 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## style-ok: no-strict
## Sourced-only login-shell fragment: enabling strict-mode here would leak
## 'set -o errexit'/'nounset' into (and could kill) the sourcing shell.

## Force the softwarecontext QML renderer when GL is software-rendered
## (avoids GL crashes: Monero, signal-desktop; hurts shotcut, kdenlive).
## https://www.kicksecure.com/wiki/Tuning#Renderer
##
## helper-scripts detect-software-rendering (a Depends) prints
## software/accelerated/unknown. Set QMLSCENE_DEVICE only if unset (user choice
## wins) and only on 'software'; accelerated/unknown -> leave unset (err toward
## acceleration available).

if command -v detect-software-rendering >/dev/null 2>/dev/null \
   && [ -z "${QMLSCENE_DEVICE+x}" ] \
   && [ "$(detect-software-rendering 2>/dev/null)" = "software" ]; then
   export QMLSCENE_DEVICE=softwarecontext
fi
