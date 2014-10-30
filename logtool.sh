#!/bin/bash
# Author: xingrong0804@163.com (Xing Rong)
# tool for log analysis

###################################################
##                                               ##
##              keyword segment                  ##
##                                               ##
###################################################
function usageOfKeyword() {
cat <<-EOU >&2

Tool help you analyze log files.

usage: ./${0##*/}  keyword [ OPTIONS ]

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
$ $0 keyword -f 'test.log' -k 'error'

EOU
exit 0
}

function keyword() {
ARGV=`getopt -o f:k:C:wqicnvVh -l file:,keyword:,context:,word-regexp,quiet,ignore-case,count,line-number,invert-match,version,help -- "$@"`
[ $? -ne 0 ] && usageOfKeyword
eval set -- "${ARGV}"

while true
do
    case "$1" in
        -f|--file)
            file="$2"
            shift 2
            ;;
        -k|--keyword)
            keyword="$2"
            shift 2
            ;;
        -C|--context)
            context="$2"
            shift 2
            ;;
        -w|--word-regexp)
            word_regexp="-w"
            shift
            ;;
        -q|--quiet)
            quiet="-q"
            shift
            ;;
        -i|--ignore-case)
            ignore_case="-i"
            shift
            ;;
        -c|--count)
            count="-c"
            shift
            ;;
        -n|--line-number)
            line_number="-n"
            shift
            ;;
        -v|--invert-match)
            invert_match="-v"
            shift
            ;;
        -V|--version)
            shift
            versionOfLogtool
            exit 0
            ;;
        -h|--help)
            shift
            usageOfKeyword
            exit 2
            ;;
        --)
            shift
            break
            ;;
    esac
done

#cmd
echo -e "--------\033[0;36;1mSearching keyword: "$keyword" in file: "$file"\033[0m--------"
if [ ! $context ]; then
    context=0
fi
cmd="grep -E -C $context $word_regexp $line_number $ignore_case $quiet $invert_match \"$keyword\" $file"
eval $cmd

if [ $count ]; then
    lineCount=`grep -E -c "$keyword" $file`
    echo -e "The line of keyword: \033[0;31;1m"$keyword"\033[0m in file: \033[0;34;1m"$file"\033[0m is \033[0;32;1m"$lineCount"\033[0m"
fi

#for file *
for arg do
    #the rest file
    file=$arg
    #cmd
    echo -e "--------\033[0;36;1mSearching keyword: "$keyword" in file: "$file"\033[0m--------"
    if [ ! $context ]; then
        context=0
    fi
    cmd="grep -E -C $context $word_regexp $line_number $ignore_case $quiet $invert_match \"$keyword\" $file"
    eval $cmd

    if [ $count ]; then
        lineCount=`grep -E -c "$keyword" $file`
        echo -e "The line of keyword: \033[0;31;1m"$keyword"\033[0m in file: \033[0;34;1m"$file"\033[0m is \033[0;32;1m"$lineCount"\033[0m"
    fi
done
}

###################################################
##                                               ##
##                count segment                  ##
##                                               ##
###################################################
function usageOfCount() {
cat <<-EOU >&2

Tool help you analyze log files.

usage: ./${0##*/} count  [ OPTIONS ]

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
$ $0 count -f sms.log -c 3 -N -k "username"

EOU
exit 0
}

function count() {
ARGV=`getopt -o f:k:c:d:t:s:e:T:wivVNCRh -l file:,keyword:,column:,delimiter:,timestamp-column:start:,end:,top:,word-regexp,ignore-case,invert-match,number,count,reverse,version,help -- "$@"`
[ $? -ne 0 ] && usageOfCount
eval set -- "${ARGV}"

while true
do
    case "$1" in
        -f|--file)
            file="$2"
            shift 2
            ;;
        -k|--keyword)
            keyword="$2"
            shift 2
            ;;
        -c|--column)
            column="$2"
            shift 2
            ;;
        -d|--delimiter)
            delimiter=$2
            shift 2
            ;;
        -t|--timestamp-column)
            timestamp_column=$2
            shift 2
            ;;
        -s|--start)
            start="$2"
            shift 2
            ;;
        -e|--end)
            end="$2"
            shift 2
            ;;
        -w|--word-regexp)
            word_regexp="-w"
            shift
            ;;
        -i|--ignore-case)
            ignore_case="-i"
            shift
            ;;
        -v|--invert-match)
            invert_match="-v"
            shift
            ;;
        -N|--number)
            number="true"
            shift
            ;;
        -T|--top)
            top=" | head -$2"
            shift 2
            ;;
        -C|--count)
            count=" | sort | uniq -c | sort -n "
            shift
            ;;
        -R|--reverse)
            count=" | sort | uniq -c | sort -n -r "
            shift
            ;;
        -V|--version)
            shift
            versionOfLogtool
            exit 0
            ;;
        -h|--help)
            shift
            usageOfCount
            exit 2
            ;;
        --)
            shift
            break
            ;;
    esac
done

#count & top
if [ $number ]; then
    count=""
    top=""
fi

#cmd
echo -e "--------\033[0;36;1mlogtool count of keyword: "$keyword" in file: "$file"\033[0m--------"
cmd="grep -E $word_regexp $ignore_case $invert_match \"$keyword\" $file"
eval $cmd | 
awk '
BEGIN {
#default values
max=0
min=99999999
no_time_tag=0

#delimiter
if("" != "'"$delimiter"'") {
    FS="'"$delimiter"'"
}

#no_time_tag
if("" == "'"$start"'" && "" == "'"$end"'") {
    no_time_tag=1
}

#start
if("" != "'"$start"'") {
    stime="'"$start"'"
}
else {
    stime="00:00:00"
}

#end
if("" != "'"$end"'") {
    etime="'"$end"'"
}
else {
    etime="23:59:59"
}

#keyword
if("" != "'"$keyword"'") {
    keyword="'"$keyword"'"
}
else {
    keyword=" "
}

#timestamp-column
if("" != "'"$timestamp_column"'") {
    timestamp_column="'"$timestamp_column"'"
}
else {
    timestamp_column=1
}

#column
if("" != "'"$column"'") {
    column="'"$column"'"
}
else {
    column=1
}

#end of BENGIN
}

#caculate of awk
no_time_tag || ($timestamp_column >= stime && $timestamp_column <= etime) {
if("" == "'"$number"'") {
    print $column
}
else {
    lineCount++;
    sum+=$column
    if($column > max) {
        max=$column
    }
    if($column < min) {
        min=$column
    }
}
}

END {
if("" != "'"$number"'") {
    printf("The line of keyword: \033[0;34;1m%s\033[0m is \033[0;32;1m%d\033[0m\n",keyword,lineCount)
    printf("The sum value of column \033[0;34;1m%d\033[0m is \033[0;32;1m%f\033[0m\n",column,sum)
    if(0 != lineCount) {
        printf("The avg value of column \033[0;34;1m%d\033[0m is \033[0;32;1m%f\033[0m\n",column,sum/lineCount)
    }
    printf("The max value of column \033[0;34;1m%d\033[0m is \033[0;32;1m%f\033[0m\n",column,max)
    printf("The min value of column \033[0;34;1m%d\033[0m is \033[0;32;1m%f\033[0m\n",column,min)
}
}
'|eval "cat$count$top"

#for file *
for arg do
    #the rest file
    file=$arg
    #cmd
    echo -e "--------\033[0;36;1mlogtool count of keyword: "$keyword" in file: "$file"\033[0m--------"
    cmd="grep -E $word_regexp $ignore_case $invert_match \"$keyword\" $file"
    eval $cmd | 
    awk '
    BEGIN {
    #default values
    max=0
    min=99999999
    no_time_tag=0

    #delimiter
    if("" != "'"$delimiter"'") {
        FS="'"$delimiter"'"
    }

    #no_time_tag
    if("" == "'"$start"'" && "" == "'"$end"'") {
        no_time_tag=1
    }

    #start
    if("" != "'"$start"'") {
        stime="'"$start"'"
    }
else {
    stime="00:00:00"
}

#end
if("" != "'"$end"'") {
    etime="'"$end"'"
}
else {
    etime="23:59:59"
}

#keyword
if("" != "'"$keyword"'") {
    keyword="'"$keyword"'"
}
else {
    keyword=" "
}

#timestamp-column
if("" != "'"$timestamp_column"'") {
    timestamp_column="'"$timestamp_column"'"
}
else {
    timestamp_column=1
}

#column
if("" != "'"$column"'") {
    column="'"$column"'"
}
else {
    column=1
}

#end of BENGIN
}

#caculate of awk
no_time_tag || ($timestamp_column >= stime && $timestamp_column <= etime) {
if("" == "'"$number"'") {
    print $column
}
else {
    lineCount++;
    sum+=$column
    if($column > max) {
        max=$column
    }
    if($column < min) {
        min=$column
    }
}
}

END {
if("" != "'"$number"'") {
    printf("The line of keyword: \033[0;34;1m%s\033[0m is \033[0;32;1m%d\033[0m\n",keyword,lineCount)
    printf("The sum value of column \033[0;34;1m%d\033[0m is \033[0;32;1m%f\033[0m\n",column,sum)
    if(0 != lineCount) {
        printf("The avg value of column \033[0;34;1m%d\033[0m is \033[0;32;1m%f\033[0m\n",column,sum/lineCount)
    }
    printf("The max value of column \033[0;34;1m%d\033[0m is \033[0;32;1m%f\033[0m\n",column,max)
    printf("The min value of column \033[0;34;1m%d\033[0m is \033[0;32;1m%f\033[0m\n",column,min)
}
}
'|eval "cat$count$top"

done
}

###################################################
##                                               ##
##               dnscount segment                ##
##                                               ##
###################################################
function usageOfDNSCount() {
cat <<-EOU >&2

Tool help you analyze dns log file.

usage: ./${0##*/} dnscount  [ OPTIONS ]

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
$ $0 dnscount -f log -s "14:06:00" -e "14:08:00" -d "25-Mar-2013" -k "www.google.com"

EOU
exit 0
}

function dnscount() {
ARGV=`getopt -o f:k:d:s:e:t:crwivVh -l file:,keyword:,date:,start:,end:,top:,count,reverse,word-regexp,ignore-case,invert-match,version,help -- "$@"`
[ $? -ne 0 ] && usageOfDNSCount
eval set -- "${ARGV}"

while true
do
    case "$1" in
        -f|--file)
            file="$2"
            shift 2
            ;;
        -k|--keyword)
            keyword="$2"
            shift 2
            ;;
        -d|--date)
            date=$2
            shift 2
            ;;
        -s|--start)
            start="$2"
            shift 2
            ;;
        -e|--end)
            end="$2"
            shift 2
            ;;
        -t|--top)
            top=" | head -$2"
            shift 2
            ;;
        -c|--count)
            count=" | sort | uniq -c | sort -n "
            shift
            ;;
        -r|--reverse)
            count=" | sort | uniq -c | sort -n -r "
            shift
            ;;
        -w|--word-regexp)
            word_regexp="-w"
            shift
            ;;
        -i|--ignore-case)
            ignore_case="-i"
            shift
            ;;
        -v|--invert-match)
            invert_match="-v"
            shift
            ;;
        -V|--version)
            shift
            versionOfLogtool
            exit 0
            ;;
        -h|--help)
            shift
            usageOfDNSCount
            exit 2
            ;;
        --)
            shift
            break
            ;;
    esac
done

#cmd
echo -e "--------\033[0;36;1mlogtool dnscount of keyword: "$keyword" in file: "$file"\033[0m--------"
cmd="grep -E $word_regexp $ignore_case $invert_match \"$keyword\""
grep -E -w "$date" $file | eval $cmd | 
awk '
BEGIN {
#default values
max=0
min=99999999
no_time_tag=0

#no_time_tag
if("" == "'"$start"'" && "" == "'"$end"'") {
    no_time_tag=1
}

#start
if("" != "'"$start"'") {
    stime="'"$start"'"
}
else {
    stime="00:00:00"
}

#end
if("" != "'"$end"'") {
    etime="'"$end"'"
}
else {
    etime="23:59:59"
}

#keyword
if("" != "'"$keyword"'") {
    keyword="'"$keyword"'"
}
else {
    keyword=" "
}

#timestamp-column
timestamp_column=2

#end of BENGIN
}

#caculate of awk
no_time_tag || ($timestamp_column >= stime && $timestamp_column <= etime) {
if("" != "'"$count"'") {
    print $10;
}
else {
    lineCount++;
}
}

END {
if("" == "'"$count"'") {
    printf("The count of domain: \033[0;31;1m%s\033[0m in \033[0;34;1m%s\033[0m(\033[0;34;1m%s\033[0m-\033[0;34;1m%s\033[0m) is \033[0;32;1m%d\033[0m\n",keyword,"'"$date"'",stime,etime,lineCount)
}
}
'|eval "cat$count$top"

#for file *
for arg do
    #the rest file
    file=$arg
    #cmd
    echo -e "--------\033[0;36;1mlogtool dnscount of keyword: "$keyword" in file: "$file"\033[0m--------"
    cmd="grep -E $word_regexp $ignore_case $invert_match \"$keyword\""
    grep -E -w "$date" $file | eval $cmd | 
    awk '
    BEGIN {
    #default values
    max=0
    min=99999999
    no_time_tag=0

    #no_time_tag
    if("" == "'"$start"'" && "" == "'"$end"'") {
        no_time_tag=1
    }

    #start
    if("" != "'"$start"'") {
        stime="'"$start"'"
    }
else {
    stime="00:00:00"
}

#end
if("" != "'"$end"'") {
    etime="'"$end"'"
}
else {
    etime="23:59:59"
}

#keyword
if("" != "'"$keyword"'") {
    keyword="'"$keyword"'"
}
else {
    keyword=" "
}

#timestamp-column
timestamp_column=2

#end of BENGIN
}

#caculate of awk
no_time_tag || ($timestamp_column >= stime && $timestamp_column <= etime) {
if("" != "'"$count"'") {
    print $10;
}
else {
    lineCount++;
}
}

END {
if("" == "'"$count"'") {
    printf("The count of domain: \033[0;31;1m%s\033[0m in \033[0;34;1m%s\033[0m(\033[0;34;1m%s\033[0m-\033[0;34;1m%s\033[0m) is \033[0;32;1m%d\033[0m\n",keyword,"'"$date"'",stime,etime,lineCount)
}
}
'|eval "cat$count$top"

done
}

###################################################
##                                               ##
##               main segment                    ##
##                                               ##
###################################################
function versionOfLogtool() {
version="V1.2.2"
curl http://message.test.cn/logtool -d "version=$version"
exit 0
}

function usageOfLogtool() {
cat <<-EOU >&2

Tool help you analyze log files.

usage: ./${0##*/} [ OPTIONS ] OBJECT { COMMAND }

OPTIONS := { -v | -h }

OBJECT := { keyword | count | dnscount }

EOU
exit 0
}

#num of params is invalid
if [ $# -lt 1 ]; then
    usageOfLogtool
    exit 2
fi

#first param
if [ "keyword" == $1 ]; then
    shift
    keyword "$@"
    exit 0
elif [ "count" == $1 ]; then
    shift
    count "$@"
    exit 0
elif [ "dnscount" == $1 ]; then
    shift
    dnscount "$@"
    exit 0
elif [ "-v" == $1 ]; then
    shift
    versionOfLogtool
    exit 0
elif [ "-h" == $1 ]; then
    shift
    usageOfLogtool
    exit 0
else
    usageOfLogtool
    exit 2
fi
