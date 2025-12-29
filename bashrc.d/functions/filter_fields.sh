filter_fields() {
    case "$1" in
      ""|help|-h|--help)
        echo "usage: filter_fields FIELDSPEC [files...] (FIELDSPEC is a comma-separated list of valid Perl array slice expressions for @F)" >&2
        return 2
        ;;
    esac
    local fieldspec=$1
    shift
    perl -lane "print join ' ', @F[$fieldspec]" "$@"
}

