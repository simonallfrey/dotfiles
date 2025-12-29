filter_fields() {
    local specs="$1"

    # --- 1. Help Section ---
    if [[ "$specs" == "-h" || "$specs" == "--help" ]]; then
        echo "Usage: output | filter_fields \"SPEC_LIST\""
        echo ""
        echo "Description:"
        echo "  Filters columns (fields) from piped input based on a list of rules."
        echo "  Default separator is whitespace."
        echo ""
        echo "Specs:"
        echo "  N      : Include field N"
        echo "  N-M    : Include range from N to M"
        echo "  -N     : Exclude field N (Exclusion overrides inclusion)"
        echo "  * : Include ALL fields (Useful when you only want to subtract)"
        echo ""
        echo "WARNING regarding *: You MUST quote the argument if using *"
        echo "  GOOD:  | filter_fields \"*,-1\""
        echo "  BAD:   | filter_fields *,-1    (Shell will expand * to filenames)"
        echo ""
        echo "Examples:"
        echo "  echo '1 2 3 4' | filter_fields \"2,4\"      -> Output: 2 4"
        echo "  echo '1 2 3 4' | filter_fields \"*,-1\"     -> Output: 2 3 4 (All except 1st)"
        echo "  echo '1 2 3 4' | filter_fields \"1,3-4\"    -> Output: 1 3 4"
        return 0
    fi

    # --- 2. Safety Checks ---
    
    # Check A: Did shell globbing split the input into multiple args? 
    # (e.g. user typed `filter_fields *` and it expanded to `file1 file2 file3`)
    if [[ $# -gt 1 ]]; then
        echo "Error: Received $# arguments. You likely used a wildcard (*) without quotes." >&2
        echo "Try quoting the argument: filter_fields \"$*\"" >&2
        return 1
    fi

    # Check B: Does the argument look like a local filename?
    # (e.g. user typed `filter_fields *` in a folder with only 1 file, or typed a filename by mistake)
    # We skip this warning if the argument is purely numbers/commas/dashes (e.g. if you have a file named '1')
    if [[ -e "$specs" && ! "$specs" =~ ^[0-9,\-]+$ ]]; then
        echo "Warning: The argument '$specs' exists as a file on disk." >&2
        echo "If you used a wildcard (*), please quote it: filter_fields \"...\"" >&2
        # We sleep briefly so the user sees the warning before awk potentially swallows it
        sleep 1
    fi

    # --- 3. The Awk Logic ---
    awk -v specs="$specs" '
    BEGIN {
        OFS=" "
        n = split(specs, items, ",")
        include_all = 0
        
        for (i = 1; i <= n; i++) {
            item = items[i]
            if (item == "*") {
                include_all = 1
            } else if (item ~ /^-/) {
                val = substr(item, 2) + 0
                exclude[val] = 1
            } else if (item ~ /^[0-9]+-[0-9]+$/) {
                split(item, range, "-")
                for (j = range[1]; j <= range[2]; j++) include[j] = 1
            } else {
                include[item + 0] = 1
            }
        }
    }
    {
        line_out = ""
        sep = ""
        for (i = 1; i <= NF; i++) {
            # Logic: (Include All OR In Include List) AND (Not in Exclude List)
            if ((include_all || (i in include)) && !(i in exclude)) {
                line_out = line_out sep $i
                sep = OFS
            }
        }
        print line_out
    }
    '
}
