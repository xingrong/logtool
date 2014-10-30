#logtool
Tool help you analyze log file.

##Usage
```shell
usage: ./logtool.sh [ OPTIONS ] OBJECT { COMMAND }

OPTIONS := { -v | -h }

OBJECT := { keyword | count | dnscount }
```

###keyword tool usage
```shell
usage: ./logtool.sh  keyword [ OPTIONS ]

OPTIONS:

-f, --file              log file name
-k, --keyword           matching PATTERN
-C, --context           Print NUM lines of output context.
-w, --word-regexp       Select only those lines containing matches that form whole words.
-q, --quiet             Quiet;  do  not write anything to standard output.
-i, --ignore-case       Ignore case distinctions in both the PATTERN and the input files.
-c, --count             count matching lines.
-n, --line-number       Prefix each line of output with the 1-based line number within its input file.
-v, --invert-match      Invert the sense of matching, to select non-matching lines.
-V, --version           Version of logtool
-h, --help              help

example:
$ ./logtool.sh keyword -f 'test.log' -k 'error'
```

###count tool usage
```shell
usage: ./logtool.sh count  [ OPTIONS ]

OPTIONS:

-f, --file              log file name
-k, --keyword           matching PATTERN
-c, --column            column need for couting
-d, --delimiter         delimiter
-t, --timestamp-column  line of timestamp
-s, --start             start of timestamp
-e, --end               end of timestamp
-w, --word-regexp       Select only those lines containing matches that form whole words.
-i, --ignore-case       Ignore case distinctions in both the PATTERN and the input files.
-v, --invert-match      Invert the sense of matching, to select non-matching lines.
-C, --count             count
-N, --number            The max|min|sum|avg value of column
-T, --top               top number of count
-R, --reverse           reverse of count
-V, --version           Version of logtool
-h, --help              help

example:
$ ./logtool.sh count -f sms.log -c 3 -N -k "username"
```

###dnscount tool usage
```shell
usage: ./logtool.sh dnscount  [ OPTIONS ]

OPTIONS:

-f, --file              dns log file name
-k, --keyword           matching PATTERN
-d, --date              date
-s, --start             start of time
-e, --end               end of time
-t, --top               top num of count
-c, --count             count
-r, --reverse           reverse
-w, --word-regexp       Select only those lines containing matches that form whole words.
-i, --ignore-case       Ignore case distinctions in both the PATTERN and the input files.
-v, --invert-match      Invert the sense of matching, to select non-matching lines.
-V, --version           Version of logtool
-h, --help              help

example:
$ ./logtool.sh dnscount -f log -s "14:06:00" -e "14:08:00" -d "25-Mar-2013" -k "www.google.com"
```
