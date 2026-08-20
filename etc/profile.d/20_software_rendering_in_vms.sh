#!/bin/sh

## Copyright (C) 2020 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## style-ok: no-strict
## Sourced-only login-shell fragment: enabling strict-mode here would leak
## 'set -o errexit'/'nounset' into (and could kill) the sourcing shell.

## Automatic fallback to softwarecontext renderer
## https://www.kicksecure.com/wiki/Tuning#Renderer
##
## Useful for:
## - Monero
##   https://github.com/monero-project/monero-gui/issues/2878
##   https://github.com/monero-project/monero-gui/pull/4419
## - signal-desktop
## - maybe also wire-desktop?
##
## https://forums.whonix.org/t/video-editing-software-fails-to-launch-on-whonix-virtualbox-kvm/17241
## Causes issues for:
## - shotcut
## - kdenlive

## If 'OpenGL core profile renderer' is 'llvmpipe' according to 'eglinfo',
## then set environment variable: QMLSCENE_DEVICE=softwarecontext
## (Only if not already set to anything else.)
## Otherwise, do nothing.
##
## This means in case hardware acceleration is
## * Unavailable: Set the environment variable.
## * Available: Do nothing.

## Package 'mesa-utils' provides 'eglinfo'.

#eglinfo | grep -- "OpenGL core profile renderer" | grep -- llvmpipe
## example output:
## OpenGL core profile renderer: llvmpipe (LLVM 19.1.7, 256 bits)

if ! command -v eglinfo >/dev/null 2>/dev/null ; then
   true "${0} ERROR: eglinfo not found. Stop."
   return 0
fi

## 'eglinfo' can hang indefinitely when EGL/DRM probing never returns. Seen in
## headless VMs and Qubes AppVMs with no accelerated GL (no '/dev/dri'): the GBM
## platform fails fast but a later platform init blocks forever. This file is
## sourced by every login shell, so an unbounded 'eglinfo' wedges every shell.
## Bound it with 'timeout': on timeout the output is empty, which falls through
## to the software-rendering path below -- the correct result in that case anyway.
## 'timeout' is from coreutils (Essential: yes); guard in case it is ever absent.
if command -v timeout >/dev/null 2>/dev/null ; then
   eglinfo_output_temp="$(timeout 5 eglinfo -B 2>/dev/null)" || true
else
   eglinfo_output_temp="$(eglinfo -B 2>/dev/null)" || true
fi

## Manual test.
#eglinfo_output_temp="OpenGL core profile renderer: NVIDIA"

opengl_core_profile_renderer_temp="$(printf '%s\n' "${eglinfo_output_temp}" | grep -- "OpenGL core profile renderer:")" || true

if printf '%s\n' "${opengl_core_profile_renderer_temp}" | grep --fixed-strings \
   -e "AMD" \
   -e "NVIDIA" \
   -e "Intel" \
   -e "Apple" \
   -e "Adreno" \
   -e "Radeon" \
   -e "ATI" \
   -e "Mali" \
   -e "Panfrost" \
   -e "V3D" \
   -e "VC4" \
   -e "PowerVR" \
   -e "Vivante" \
   -e "etnaviv" \
   -e "Lima" \
   -e "virgl" \
   -e "SVGA3D" \
   -e "D3D12" \
   >/dev/null 2>/dev/null; then
   true "${0} INFO: accelerated graphics renderer detected. Stop."
   return 0
fi

if printf '%s\n' "${opengl_core_profile_renderer_temp}" | grep -- "llvmpipe" >/dev/null 2>/dev/null; then
   software_rendering_use=true
fi

if [ ! "${software_rendering_use}" = "true" ]; then
   true "${0} INFO: software_rendering_use is not set to true. Stop."
   return 0
fi

if [ ! "${QMLSCENE_DEVICE}" = "" ]; then
   true "${0} INFO: QMLSCENE_DEVICE is already set to '${QMLSCENE_DEVICE}'. Not changing. Stop."
   return 0
fi

export QMLSCENE_DEVICE=softwarecontext
