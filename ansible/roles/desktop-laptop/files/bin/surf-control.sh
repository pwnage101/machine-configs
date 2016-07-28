#!/bin/sh
# $1 = $xid
# $2 = $p = _SURF_FIND _SURF_BMARK _SURF_URI _SURF_URI_RAW (what SETPROP sets in config.h)
#
# // replace default setprop with this one
# #define SETPROP(p) { .v = (char *[]){ "/bin/sh", "-c", "surf-control.sh $0 $1", winid, p, NULL } }
#
# { MODKEY,               GDK_g,      spawn,      SETPROP("_SURF_URI") },
# { MODKEY|GDK_SHIFT_MASK,GDK_g,      spawn,      SETPROP("_SURF_URI_RAW") },
# { MODKEY,               GDK_f,      spawn,      SETPROP("_SURF_FIND") },
# { MODKEY,               GDK_b,      spawn,      SETPROP("_SURF_BMARK") },

font='-*-terminus-medium-*-*-*-*-*-*-*-*-*-*-*'
normbgcolor='#181818'
normfgcolor='#e9e9e9'
selbgcolor='#dd6003'
selfgcolor='#e9e9e9'
bmarks=~/Documents/bookmarks.txt

xid=$1
p=$2
uri=`xprop -id $xid _SURF_URI | cut -d '"' -f 2`
kw=`xprop -id $xid _SURF_FIND | cut -d '"' -f 2`
dmenu="dmenu -nb $normbgcolor -nf $normfgcolor \
       -sb $selbgcolor -sf $selfgcolor"

s_xprop() {
    [ -n "$2" ] && xprop -id $xid -f $1 8s -set $1 "$2"
}

case "$p" in
"_SURF_FIND")
    ret="`echo $kw | $dmenu -p find:`"
    s_xprop _SURF_FIND "$ret"
    ;;
"_SURF_BMARK")
    echo $uri | $dmenu -p "bookmark this?" && \
      grep "$uri" $bmarks >/dev/null 2>&1 || echo "$uri" >> $bmarks
    ;;
"_SURF_URI_RAW")
    ret=`echo $uri | $dmenu -p "uri:"`
    s_xprop _SURF_GO "$ret"
    ;;
"_SURF_URI")
    sel=`tac $bmarks 2> /dev/null | $dmenu -l 10 -p "uri [dgtwy*]:"`
    [ -z "$sel" ] && exit
    opt=$(echo $sel | cut -d ' ' -f 1)
    arg=$(echo $sel | cut -d ' ' -f 2-)
    case "$opt" in
    "s") # search for it
        ret="https://startpage.com/do/search?query=$arg"
        ;;
    "t") # tinyurl
        ret="http://tinyurl.com/create.php?url=$uri"
        ;;
    "w") # wikipedia
        ret="https://wikipedia.org/wiki/$arg"
        ;;
    "y") # youtube
        ret="http://www.youtube.com/results?search_query=$arg&aq=f"
        ;;
    "jira") # search jira tickets
        ret="https://openedx.atlassian.net/browse/$arg"
        ;;
    "wiki") # search the confluence wiki
        ret="https://openedx.atlassian.net/wiki/dosearchsite.action?queryString=$arg"
        ;;
    *)
        ret="$sel"
        ;;
    esac
    s_xprop _SURF_GO "$ret"
    ;;
*)
    echo Unknown xprop
    ;;
esac
