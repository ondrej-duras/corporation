" VIM highlighting for Cisco IOS/IOS XE/IOS XR/NX-OS command-line configuration
" 20170403, Ing. Ondrej DURAS (dury)
" VERSION=2021.040701
"=vim source $VIM/backup.vim
"=vim call Backup("/usr/good-oldies")
"=vim let @c="syntax match XCisco  /^"
"=vim set nohlsearch
source $VIM/itn-dc.vim
nmap <c-a>u :!start gvim $VIM/cisco.txt
nmap <c-a>U :!start gvim $VIM/cisco.vim
set complete+=k
set dictionary=$VIM/cisco.txt
let @a=" configure terminal"
let @b=" copy running startup"
let @c="  switchport trunk allowed vlan add "
let @r="  switchport trunk allowed vlan remove "
let @d="#=vim source $VIM/itn-dc.vim"
let @e="# --- end ---"

syntax match Xnumber /[0-9]\+/ contained
syntax keyword Xwords add remove
syntax match XCisco  /\<\(configure terminal\|copy running startup\|commit\)$/
syntax match XCisco  /^snmp-server location\s\+\S\+/
syntax match XCisco  /^snmp-server contact\s\+\S\+/
syntax match XCisco  /^vlan [0-9]\+\(-[0-9]\+\)\?\(,[0-9]\+\(-[0-9]\+\)\?\)*$/
syntax match XCisco  /^  name [0-9A-Z_]\+/ contains=Xvlan
syntax match XCiscoW /^interface [A-Za-z0-9,\/-]\+$/ contains=XjuInt
syntax match XCiscoW /^default interface [A-Za-z0-9,\/-]\+$/ contains=XjuInt
syntax match XCiscoW /^no interface Po[0-9]\+\(,Po[0-9]\+\)*$/ contains=XjuInt
syntax match XCisco  /^  description\>/
syntax match XCisco  /^  switchport$/
syntax match XCisco  /^  switchport mode trunk$/
syntax match XCisco  /^  switchport trunk native vlan [0-9]\{1,4}$/ contains=Xnumber
syntax match XCisco  /^  switchport trunk allowed vlan [-0-9,]\+$/ contains=Xnumber
syntax match XCisco  /^  switchport trunk allowed vlan \(add\|remove\) [-0-9,]\+$/ contains=Xnumber,Xwords
syntax match XCisco  /^  switchport access vlan [0-9]\+$/
syntax match XCisco  /^  switchport mode access$/
syntax match XCisco  /^  spanning-tree portfast$/
syntax match XCisco  /^  priority-flow-control mode off$/
syntax match XCisco  /^  spanning-tree port type edge trunk$/
syntax match XCisco  /^  flowcontrol receive on$/
syntax match XCisco  /^  flowcontrol send on$/
syntax match XCisco  /^  no snmp trap link-status$/
syntax match XCisco  /^  channel-group [0-9]\+ force mode on$/ 
syntax match XCisco  /^  channel-group [0-9]\+ force mode active$/ 
syntax match XCisco  /^  channel-group [0-9]\+ force$/ 
syntax match XCisco  /^  no lacp suspend-individual$/
"syntax match XCisco  /^  $/
syntax match XCisco  /^  load-interval 30$/ 
syntax match XCisco  /^  speed 10\{2,10}$/ 
syntax match XCisco  /^  mtu 9180$/
syntax match XCisco  /^  vpc [0-9]\+$/
syntax match XCisco  /^  no cdp enable$/
syntax match XCisco  /^  cdp enable$/
syntax match XCiscoW /^  no shutdown$/
syntax match XCisco  /^\(  \)*exit$/
syntax match XCiscoW /^end$/
syntax match XCisco  /^hostname [A-Z0-9-]\+$/ contains=Xhost

syntax match XCisco  /^role name read-only$/
syntax match XCisco  /^  rule 7 permit command show \*$/
syntax match XCisco  /^  rule 6 permit command terminal length \*$/
syntax match XCisco  /^  rule 5 permit command terminal width \*$/
syntax match XCisco  /^  rule 4 permit command terminal monitor$/
syntax match XCisco  /^  rule 3 permit command traceroute \*$/
syntax match XCisco  /^  rule 2 permit command ping \*$/
syntax match XCisco  /^  rule 1 permit read$/
syntax match XCisco  /^username \(admin\|preceda\|shelladmin\|dno\|dne\) password 5 \S\+  role network-admin$/
syntax match XCisco  /^username \(admin\|preceda\|shelladmin\|dno\|dne\) passphrase  lifetime 99999 warntime 14 gracetime 3$/
syntax match XCisco  /^feature \(telnet\|vrrp\|ospf\|bgp\|pim\|udld\|interface-vlan\|lacp\|lldp\|fex\)$/


syntax match XCisco  /^logging level adbm 2$/
syntax match XCisco  /^logging level pltfm_config 4$/
syntax match XCisco  /^logging server [0-9.]\+ 5 use-vrf default facility local1$/
syntax match XCisco  /^logging source-interface Vlan[0-9]\+$/ contains=XjuInt
syntax match XCisco  /^logging timestamp milliseconds$/
syntax match XCisco  /^logging event link-status default$/
syntax region XCiscoW start=/^banner motd -/ end=/^-/

syntax match XCisco  /^no ip domain-lookup$/
syntax match XCisco  /^radius-server host [0-9.]\+ key 7 "\S\+" auth-port 1645 acct-port 1646 authentication accounting timeout 5 retransmit 2$/
syntax match XCisco  /^aaa group server radius \S\+$/
syntax match XCisco  /^  server [0-9.]\+$/

syntax match XCiscoG /^show int \S\+ status$/ contains=XjuInt


high XCisco  ctermfg=brown 
high XCiscoW ctermfg=darkcyan
high XCiscoG ctermfg=darkgreen
high Xnumber ctermfg=darkcyan
high Xwords  ctermfg=darkcyan
" --- end ---

