$CONST_INDENT_NUM = 2
$CONST_INDENT_CHAR = " "
$base_indent = $CONST_INDENT_CHAR * $CONST_INDENT_NUM

$files = get-childitem -recurse -file -exclude "*.ps1"

foreach ($f in $files) {
    # convert json to 1 line
    $content = $f | get-content -encoding utf8 | convertfrom-json -depth 100 | convertto-json -depth 100 -compress

    # pretty json
    $prettified = ""
    $indent = ""
    for ($i=0; $i -lt $content.length; $i++) {
        if ("}]".contains($content[$i])) {
            $indent = $indent -replace "$($base_indent)$", ""
            $prettified += "`n" + $indent
        }
        if (($prettified[-1] -eq ",") -and ("[{`"".contains($content[$i]))) {
            $prettified += "`n" + $indent
        }

        $prettified += $content[$i]

        if ("[{".contains($content[$i])) {
            $indent += $base_indent
            $prettified += "`n" + $indent
        }
        if ("`"}".contains($prettified[-2]) -and ($content[$i] -eq ",")) {
            $prettified += "`n" + $indent
        }
    }
    $prettified | out-file -filepath $f.fullname -encoding default -force
}