#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154,SC2220

# @Author: goregath
# @Date:   2023-08-04 20:19:34
# @Last Modified by:   goregath
# @Last Modified time: 2023-08-17 00:36:50

# Map alphabet from base64 to 64#<d> (builtin bash arithmetic notation).
#         0   26  52  62 63
#  FROM   A–Z a–z 0–9 +  /
#    TO   0–9 a–z A–Z @  _
#         0   10  36  62 63
k2b() {
    printf -v a1 '%s%n' "${a0//'='}" an
    (( d0 = 64#$a1 << 6 * (4-an),
    k0 = d0 & 0x3f,
    k1 = d0 >> 6 & 0x3f,
    k2 = d0 >> 12 & 0x3f,
    k3 = d0 >> 18,
    k0 += k0>9 ? k0>35 ? k0>61 ? 0 : -36 : 16 : 52,
    k1 += k1>9 ? k1>35 ? k1>61 ? 0 : -36 : 16 : 52,
    k2 += k2>9 ? k2>35 ? k2>61 ? 0 : -36 : 16 : 52,
    k3 += k3>9 ? k3>35 ? k3>61 ? 0 : -36 : 16 : 52,
    d0 = k0 | k1 << 6 | k2 << 12 | k3 << 18,
    b[j++] = d0 >> 16,
    an > 2  && (b[j++] = d0 >> 8 & 0xff),
    an == 4 && (b[j++] = d0 & 0xff),
    1 ))
}

base64() {
    usage() {
        printf 'USAGE: base64 -d [FILE]\n'
    }
    # shellcheck disable=SC2120
    decode() {
        # Read base64 string from stdin and write decoded data to stdout.
        local IFS=$'\n' LC_CTYPE=C LC_COLLATE=C a{0..2} s{0..2}
        local -i i j n=76 an d0 k{0..3}
        local -ia b=()
        # Fill the buffer `a0` with up to 76 characters, a common line length
        # when storing base64 encoded strings. The real buffer size may be
        # less if `read` hits a delimiter (`\n`) but should always be a
        # multiple of 4 - a limitation of this algorithm.
        while read -er s0 && (( j=0, sn=${#s0} )) && [[ "$s0" == *([[:alnum:]/+=]) ]]; do
            # s0 can be empty if a delmiter has been hit
            s1="${s0//\//_}"
            s2="${s1//+/@}"
            eval eval set -- '\${s2:'"{0..$sn..4}"':4}'
            # shellcheck disable=SC2048
            for a0 in $*; do
                i='d0=64#'"$a0"',
                k0 = d0 & 0x3f,
                k1 = d0 >> 6 & 0x3f,
                k2 = d0 >> 12 & 0x3f,
                k3 = d0 >> 18,
                k0 += k0>9 ? k0>35 ? k0>61 ? 0 : -36 : 16 : 52,
                k1 += k1>9 ? k1>35 ? k1>61 ? 0 : -36 : 16 : 52,
                k2 += k2>9 ? k2>35 ? k2>61 ? 0 : -36 : 16 : 52,
                k3 += k3>9 ? k3>35 ? k3>61 ? 0 : -36 : 16 : 52,
                d0 = k0 | k1 << 6 | k2 << 12 | k3 << 18,
                b[j++] = d0 >> 16,
                b[j++] = d0 >> 8 & 0xff,
                b[j++] = d0 & 0xff' || break
            done
            printf -v a2 '\\x%x' "${b[@]:0:$j}"
            echo -ne "$a2"
        done
        if read -ern1 _; then
            printf 'error: invalid input\n' >&2
            return 1
        fi
    }
    local OPTARG OPTIND OPTERR=1 opt
    local -i dflag=0
    while getopts "dh" opt; do
        case "$opt" in
            d) dflag=1 ;;
            h) usage; return ;;
            *) usage >&2; return 1 ;;
        esac
    done
    shift $((OPTIND-1))
    if (( dflag && $# )); then
        if ! exec 0<"$1"; then
            return 1
        fi
    fi
    if (( dflag )); then
        decode
    else
        usage >&2
        return 1
    fi
}

if ! return 2>/dev/null; then
    # only executed if not sourced
    base64 "$@"
fi