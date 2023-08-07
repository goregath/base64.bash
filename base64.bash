#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154,SC2220

# @Author: goregath
# @Date:   2023-08-04 20:19:34
# @Last Modified by:   goregath
# @Last Modified time: 2023-08-08 00:51:15

base64() {
    usage() {
        printf 'USAGE: base64 -d [FILE]\n'
    }
    decode() {
        # Read base64 string from stdin and write decoded data to stdout.
        local IFS=$'\n' LC_CTYPE=C LC_COLLATE=C a a0
        local -i n=512 len pad i d0 k{0..3}
        local -ia b=()
        # Read four characters from stdin and set to `a`. The `read` command
        # may return less or zero characters if it hit an delimiter (`\n`).
        while read -ern4 a; do
            # Map alphabet from base64 to 64#<d> (builtin bash arithmetic notation).
            #        0   26  52  62 63
            # FROM:  A–Z a–z 0–9 +  /
            #   TO:  0–9 a–z A–Z @  _
            #        0   10  36  62 63
            if [[ "$a" == ???? && "$a" == [[:alnum:]/+]+([[:alnum:]/+])*(=) ]]; then
                printf -v a0 '%s%n' "${a//'='}" len
                a0="${a0//'/'/'_'}" a0="${a0//'+'/'@'}"
                (( pad = 4-len,
                d0 = 64#"$a0" << 6 * pad,
                k0 = d0 & 0x3f,
                k1 = d0 >> 6 & 0x3f,
                k2 = d0 >> 12 & 0x3f,
                k3 = d0 >> 18 & 0x3f,
                k0 += k0>9 ? k0>35 ? k0>61 ? 0 : -36 : 16 : 52,
                k1 += k1>9 ? k1>35 ? k1>61 ? 0 : -36 : 16 : 52,
                k2 += k2>9 ? k2>35 ? k2>61 ? 0 : -36 : 16 : 52,
                k3 += k3>9 ? k3>35 ? k3>61 ? 0 : -36 : 16 : 52,
                d0 = k0 | k1 << 6 | k2 << 12 | k3 << 18,
                b[i++] = d0 >> 16 & 0xff,
                pad < 2 && (b[i++] = d0 >> 8 & 0xff),
                pad < 1 && (b[i++] = d0 & 0xff),
                1 )) 2>/dev/null
                if (( i > n )); then
                    printf -v a '\\x%02x' "${b[@]:0:$i}"
                    echo -ne "$a"
                    i=0
                fi
            elif [[ "$a" != "" ]]; then
                printf "error: %q: invalid input\n" "$a" >&2
                return 1
            fi
        done
        printf -v a '\\x%02x' "${b[@]:0:$i}"
        echo -ne "$a"
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