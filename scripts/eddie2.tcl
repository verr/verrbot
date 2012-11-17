# Eddie's Extensions v0.8.6 - Tcl script for an eggdrop bot
#   http://sourceforge.net/projects/eddie42/
#
# Copyright (C) 2000-2002  <Jamie 'Wonko' Cheetham> - jamie@softham.co.uk
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# Commenting out the following items will disable that function
# bind msgm - "*asl*" asl
# bind msg - !encrypt encrypt1
# bind msg - encrypt encrypt1
# bind msg - !decrypt decrypt1
# bind msg - decrypt decrypt1
# bind msg - !poll msg_vote
# bind msg - poll msg_vote
# bind pubm - "*# Appears as *" pub_nocomic
# bind pubm - "*all your * are belong to *" checkbase
# bind pub - !8ball 8ball
# bind pub - 8ball 8ball
# bind pub - !8-ball 8ball
# bind pub - 8-ball 8ball
# bind pub - !addquote addquote
# bind pub - !calc calc
# bind pub - !calculate calc
# bind pub - !devoice devoice
# bind pub - !eddie eddies
# bind pub - !flags flags
# bind pub - !giveme giveme
# bind pub - !giveto giveto
# bind pub - !help help
# bind pub - @invite invite
bind pub - !list showlist
# bind pub - !lock lock
bind pub - !op op
bind pub - !pi pi
# bind pub - !ping ping_me
# bind pub - !poll poll
# bind pub - !quote quote
bind pub - !random random
bind pub - !random2 random2
# bind pub - !seanmode seanmode
# bind pub - !sms sms
bind pub - !status status
bind pub - !time time
# bind pub - !unlock unlock
bind pub - !uptime uptime
# bind pub - !url url
# bind pub - @url url
bind pub - !version version
bind pub - !voice voice
# bind pub - !whack whack
bind pub - !whoami whoami
bind pub - @whoami whoami
bind pub - !xmas xmas
# bind pub o|o !resetbans pub_resetbans
# bind pub n|n !cleanusers cleanusers
bind dcc m auth dcc_auth
bind dcc m eddiecheck dcc_eddiecheck
bind dcc m kill dcc_kill
bind dcc m limit dcc_limits
bind dcc m seanmode dcc_sean
bind dcc m sms dcc_sms
bind dcc m join dcc_join
bind dcc m part dcc_part
bind dcc o poll dcc_poll
bind dcc o locktopic dcc_locktopic
bind dcc o unlocktopic dcc_unlocktopic
bind dcc v broadcast dcc_broadcast
bind dcc * action dcc_action
bind dcc * hand2nick dcc_findnick
bind dcc * stats dcc_stats
bind dcc * urls dcc_url
bind ctcp - DCC got_dcc
bind topc - * ctopic
bind kick - * kicked
bind sign - * sign
bind mode - * opped

##### YOU SHOULDN'T NEED TO EDIT ANYTHING BELOW HERE #####

bind join - * enter
bind time - "** % % % %" check_limits
bind ctcr - PING ping_me_reply
bind bot - vBOTNET_EDDIE_CHECK bot_check
bind bot - vBOTNET_EDDIE_CHECK_ACK bot_check_ack

set greeter "scripts/greeter.tcl"
if {![info exists eddie(chans)] || $eddie(chans) == ""} {"\002Eddie's Extensions\002: WARNING - Not configured properly!"}
if {![info exists n] || $n < 0} {set n 2}
if {![info exists seanmoden]} {set seanmode 1}
if {![info exists nocomic]} {set nocomic 1}
if {![info exists greeting]} {set greeting 1}
if {![info exists help_notice]} {set help_notice 1}
if {![info exists chan_m]} {set chan_m 1}
if {![info exists sign_msg]} {set sign_msg 1}
if {![info exists quotedir]} {set quotedir "/home/eggdrop/quotes/"}
if {[string range $quotedir [expr [string length $quotedir]-1] end] != "/"} {set quotedir $quotedir/}
if {![info exists eddie_key]} {set eddie_key 42}
if {![info exists Expired_after] || $Expired_after < 0} {set Expired_after 21}
if {![info exists eddie_key] || $Expired_after < 0} {set maxtime 60}
if {$chan_limits == ""} {set eddie_lim 0}
if {$greeting > 2} {source $greeter}

### DO NOT ALTER THESE VALUES!
set eddie_ver "v0.8.6a"
set eddie_lim 1
set eddie(poll) 0
set eddie(v_nick) ""
set eddie(v_host) ""
set yes 0
set no 0
set question "test"
set eddie(code) ""
set last_asked ""
set sms_user ""
set sms_addy ""
set url_name ""
set url_addy ""
set t_locks ""
set pi 3.1415926535897932
set e 2.71828182845905
set g 9.81
###

if {$chan_m} {
  unbind dcc n +chan *dcc:+chan
  bind dcc m +chan *dcc:+chan
  unbind dcc n -chan *dcc:-chan
  bind dcc m -chan *dcc:-chan
}

proc init_serv {type} {dcc_auth "" -1 ""}
proc dcc_auth {handle idx arg} {
  global service serv_user serv_pass undernet
  if {$undernet} {
    putserv "PRIVMSG $service :login $serv_user $serv_pass"
  } else {putserv "PRIVMSG $service :auth $serv_user $serv_pass"}
}

proc eddies {nick host handle chan arg} {
  global eddie
  if {[string first $chan $eddie(chans)] >= 0} {
    putserv "NOTICE $chan :Eddie's Extensions is online. Channel commands are available. Use !help for more info."
  } else {putserv "NOTICE $chan :Eddie's Extensions is online. Channel commands are not available."}
  putserv "NOTICE $chan :Eddie's Extensions is available from http\://sourceforge.net/projects/eddie42/."
}

proc dcc_poll {handle idx arg} {
  global eddie question yes no
  set cmd [lindex [string tolower $arg] 0]
  if {$cmd == "on" } {
    if {$question == "test"} {
      putidx $idx "WARNING\: No queston set!"
      return 0
    }
    putidx $idx "My poll has started..."
    foreach chan $eddie(chans) {putserv "NOTICE $chan :The poll is now open! For more info, type !poll"}
    set eddie(poll) 1
  } elseif {$cmd == "off" && $eddie(poll)} {
    putidx $idx "The poll is now closed."
    foreach chan $eddie(chans) {putserv "NOTICE $chan :The poll is now closed! For results, type !poll results"}
    set eddie(poll) 0
    putidx $idx "YES - $yes       NO - $no"
    putidx $idx "TOTAL NUMBER OF VOTES - [expr $yes+$no]"
    putidx $idx "VOTED NICKS - $eddie(v_nick)"
    putidx $idx "VOTED HOSTS - $eddie(v_host)"
  } elseif {$cmd == "off" && !$eddie(poll)} {
    putidx $idx "The poll is already closed."
  } elseif {$cmd == "status" } {
    if {$question != "test"} {
      putidx $idx "The question is '$question'"
    } else {putidx $idx "No question is set."}
    if {$eddie(poll)} { 
      putidx $idx "The poll is running."
    } else {putidx $idx "The poll is closed."}
  } elseif {$cmd == "reset" } {
    if {$eddie(poll)} { 
      putidx $idx "The poll can only be reset when it is closed."
      return 0
    }
    set yes 0
    set no 0
    set question "test"
    set eddie(v_nick) ""
    set eddie(v_host) ""
    putidx $idx "The poll has now been reset. You will need to set a new question."
  } elseif {$eddie(poll)} { 
    putidx $idx "The question can only be changed when the poll is closed."
  } else {
    if {$arg == ""} {
      putidx $idx "\002Usage:\002 .poll <on/off/reset>  or  .poll (new question)"
    } else {
      set question $arg
      putidx $idx "New question set."
    }
  }
}

proc dcc_sean {handle idx arg} {
  global seanmode
  set cmd [lindex $arg 0]
  switch $cmd {
  "on" {
    putidx $idx "Seanmode is now enabled!"
    set seanmode 1
  } "off" {
    putidx $idx "Seanmode is now disabled!"
    set seanmode 0
  } "status" {
    if {!$seanmode} {putidx $idx "!seanmode is currently not active."}
    if {$seanmode} {putidx $idx "!seanmode is currently active."}
  } default {putidx $idx "\002Usage:\002 .seanmode <on/off/status>"}}
}

proc dcc_limits {handle idx arg} {
  global n eddie_lim chan_limits
  set arg [string tolower $arg]
  switch $arg {
  "on" {
    if {$chan_limits == ""} {
      putidx $idx "ERROR\: \$chan_limits not set!"
    } else {
      set eddie_lim 1
      putidx $idx "Channel limit is now enabled!"
    }
  } "off" {
    set eddie_lim 0
    putidx $idx "Channel limit is now disabled!"
  } "check" {
    check_limits 1 1 1 1 1
    putidx $idx "Channel limits have now been rechecked."
  } "status" {
    if {$eddie_lim} {putidx $idx "Channel limiting is currently active on $chan_limits. \$n = $n."}
    if {!$eddie_lim} {putidx $idx "Channel limiting is currently not active."}
  } default {
    if {![regexp "\[^0-9\]" $arg] && $arg > 0} {
      set n $arg
      putidx $idx "Channel limit is now set to users+$arg"
    } else {
      putidx $idx "\002Usage:\002 .limit <on/off/status/\$n>"
      putidx $idx "NB. channel limit = current number of users on the chan + \$n"
    }
  }}
}

proc dcc_sms {handle idx arg} {
  global sms_user sms_addy
  set arg [string tolower $arg]
  switch $arg {
  "list" {
    set i 0
    foreach sms_tmp $sms_user {
      putidx $idx "$sms_tmp [lindex $sms_addy $i]"
      incr i
    }
  } "reload" {
     putidx $idx "Sorry, this command has been disabled."
     putidx $idx "see also: restart"
  } default {putidx $idx "\002Usage:\002 .sms <list>"}}
}

proc dcc_url {handle idx arg} {
  global url_name url_addy
  set i 0
  foreach url_tmp $url_name {
    putidx $idx "$url_tmp [lindex $url_addy $i]"
    incr i
  }
}

proc dcc_action {handle idx arg} {
  set chan [string tolower [lindex $arg 0]]
  set tmp [lrange $arg 1 end]
  if {[lsearch -exact [string tolower [channels]] $chan] > -1 && $tmp != ""} {
    putserv "PRIVMSG $chan :\001ACTION $tmp\001"
  } else {putidx $idx "\002Usage:\002 .action <channel> <message>"}
}

proc dcc_broadcast {handle idx msg} {
  if {$msg != ""} {
    foreach i [channels] {putserv "PRIVMSG $i :Broadcast from $handle: \002$msg\002"}
  } else {putidx $idx "\002Usage:\002 .broadcast <message>"}
}

proc dcc_findnick {handle idx arg} {
  set handle [lindex $arg 0]
  if {[validuser $handle]} {
    set chan [lindex $arg 1]
    if {[string range $chan 0 1] != "#"} {set chan #$arg}
    set nick [hand2nick $handle]
    if {[validchan $chan]} {set nick [hand2nick $handle $chan]}
    if {$nick == ""} {
      putidx $idx "I don't see $handle online."
    } else {putidx $idx "$handle is currently using the nick $nick."}
    return 0
  } else {putidx $idx "I have no user record for $handle."}
  putidx $idx "\002Usage:\002 .hand2nick <handle> \[channel\]"
  putidx $idx "If <channel> is not specified, I will check all of my channels"
}

proc dcc_kill {handle idx arg} {
  if {$arg != ""} {
    set victim [lindex $arg 0]
    if {[validuser $victim]} {
      set reason [lrange $arg 1 end]
      if {$reason == ""} {set reason "Requested"}
      putdcc [hand2idx $victim] "Closing connection: Killed ($handle ($reason))"
      killdcc [hand2idx $victim]
      dccbroadcast "$handle killed ($victim ($reason))"
    } else {putidx $idx "I have no user record for $arg."}
  } else {putidx $idx "\002Usage:\002 .kill <handle> <reason>"}
}

proc dcc_join {handle idx arg} {
  if {$arg == ""} {
    putdcc $idx "\002Usage:\002 .join <channel>"
    return 0
  }
  set chan [lindex $arg 0]
  if {[validchan $chan]} {
    putserv "JOIN $chan"
  } else {
    channel add $chan
    channel set $chan -clearbans -enforcebans -dynamicbans +userbans -autoop -bitch -greet -protectops -statuslog -stopnethack -revenge -autovoice -secret -shared
  }
  putdcc $idx "Joining channel $chan ..."
  putcmdlog "([hand2nick $handle]) !$handle! JOIN $arg"
}

proc dcc_part {handle idx arg} {
  if {$arg == ""} {
    putdcc $idx "Usage: part <channel>"
  } elseif {![validchan [lindex $arg 0]]} {
    putdcc $idx "WARNING\: [lindex $arg 0] is an invalid channel."
  } else {
    channel remove [lindex $arg 0]
    putdcc $idx "Leaving channel [lindex $arg 0] ..."
  }
  putcmdlog "([hand2nick $handle]) !$handle! PART $arg"
}

proc dcc_eddiecheck {handle idx arg} {
  global botnick eddie_ver
  putdcc $idx "Checking for Eddie's Extensions on botnet..."
  putdcc $idx "$botnick is running Eddie's Extensions version $eddie_ver."
  putallbots "vBOTNET_CHECK_EDDIE $idx $handle"
}

proc dcc_locktopic {handle idx arg} {
  global t_locks
  set chan [lindex $arg 0]
  if {[validchan $chan]} {
    lappend t_locks [string tolower $chan]
    putdcc $idx "The topic on $chan is now locked."
  } else {
    putdcc $idx "\002Usage:\002 .locktopic <channel>"
    putdcc $idx "The following channels are locked\: $t_locks"
  }
}

proc dcc_unlocktopic {handle idx arg} {
  global t_locks
  set chan [lindex $arg 0]
  if {[validchan $chan]} {
    set pos [lsearch -exact $t_locks [string tolower $chan]]
    lreplace t_locks $pos $pos ""
    putdcc $idx "The topic on $chan is now unlocked."
  } else {putdcc $idx "\002Usage:\002 .unlocktopic <channel>"}
}

proc poll {nick host handle channel arg} {
  global eddie question yes no
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  set cmd [lindex [string tolower $arg] 0]
  if {$cmd == "results"} {
    if {$question == "test" && !$yes && !$no} {
      putserv "NOTICE $channel :The poll has not been set."
      return 0
    }
    if {!$eddie(poll)} {
      putserv "NOTICE $channel :I took a poll on `$question'"
    } else {putserv "NOTICE $channel :I'm taking a poll on `$question'"}
    set total [expr $yes+$no]
    set tmp1 0
    set tmp2 0
    if {$yes != 0} {set tmp1 [expr ($yes*100)/$total]}
    if {$no != 0} {set tmp2 [expr ($no*100)/$total]}
    putserv "NOTICE $channel :YES - $tmp1 %       NO - $tmp2 %"
    putserv "NOTICE $channel :TOTAL NUMBER OF VOTES - $total"
    if {!$eddie(poll)} {
      if {$yes > $no} {putserv "NOTICE $channel :Final result \: YES"}
      if {$yes < $no} {putserv "NOTICE $channel :Final result \: NO"}
      if {$yes == $no} {putserv "NOTICE $channel :Final result \: It was a tie!"}
    }
    return 0
  } 
  if {!$eddie(poll)} {return 0}
  if {[string first $host $eddie(v_host)] >= 0 && $cmd != ""} {
    putserv "NOTICE $nick :Sorry $nick, you appear to have already voted on my poll..."
    return 0
  }
  if {$cmd == "yes"} {
    putserv "NOTICE $nick :$nick\: Thank you for voting!"
    incr yes
    set eddie(v_nick) [lappend eddie(v_nick) $nick]
    set eddie(v_host) [lappend eddie(v_host) [getchanhost $nick]]
  } elseif {$cmd == "no"} {
    putserv "NOTICE $nick :$nick\: Thank you for voting!"
    incr no
    set eddie(v_nick) [lappend eddie(v_nick) $nick]
    set eddie(v_host) [lappend eddie(v_host) [getchanhost $nick]]
  } else {
    putserv "NOTICE $channel :I'm taking a poll on '$question'"
    putserv "NOTICE $channel :Type \002!poll yes\002 to vote yes and \002!poll no\002 to vote no."
  }
}

proc msg_vote {nick host handle arg} {
  global eddie yes no question
  set cmd [lindex [string tolower $arg] 0]
  if {!$eddie(poll)} {
    putserv "PRIVMSG $nick :Sorry, my poll is currently closed."
    return 0
  }
  if {[string first $host $eddie(v_host)] >= 0} {
    putserv "NOTICE $nick :Sorry $nick, you appear to have already voted on my poll..."
  } elseif {$cmd == "yes"} {
    putserv "PRIVMSG $nick :Thank you for voting!"
    incr yes
    set eddie(v_nick) [lappend eddie(v_nick) $nick]
    set eddie(v_host) [lappend eddie(v_host) [getchanhost $nick]]
  } elseif {$cmd == "no"} {
    putserv "PRIVMSG $nick :Thank you for voting!"
    incr no
    set eddie(v_nick) [lappend eddie(v_nick) $nick]
    set eddie(v_host) [lappend eddie(v_host) [getchanhost $nick]]
  } else {
    putserv "PRIVMSG $nick :I'm taking a poll on '$question'"
    putserv "PRIVMSG $nick :Type \002!poll yes\002 to vote yes and \002!poll no\002 to vote no."
  }
}

proc op {nick host handle channel arg} {
#  What about if the user only has a channel +o on the bot?
  global service botnick
  if {[botisop $channel]} {
    if {[matchattr $handle o] || [matchchanattr $handle o $channel]} {
      pushmode $channel +o $nick
    } else {
      putserv "PRIVMSG $channel :$nick\: I'm already an op though. Did you think I was going to op you? haha! \:)"
    }
  } else {putserv "PRIVMSG $service :op $channel $botnick"}
}

proc voice {nick host handle channel target} {
  if {[botisop $channel]} {
    if {[matchattr $handle v] || [matchchanattr $handle v $channel]} {
      if {$target == "" || [string tolower $target] == "me"} {
        pushmode $channel +v $nick
        return 0
      }
    }
    if {[isop $nick $channel] || [matchattr $handle o] || [matchchanattr $handle o $channel]} {
       if {[onchan $target $channel]} {
         pushmode $channel +v $target
       } else {putserv "PRIVMSG $channel :$nick\: Sorry, I can't voice $target."}
    } else {putserv "PRIVMSG $channel :$nick\: Sorry, you don't have permission to do that."}
  }
}

proc devoice {nick host handle channel target} {
  if {[botisop $channel]} {
    if {$target == "" || [string tolower $target] == "me"} {
      pushmode $channel -v $nick
      return 0
    }
    if {[isop $nick $channel] || [matchattr $handle o] || [matchchanattr $handle o $channel]} {
       if {[onchan $target $channel]} {
         pushmode $channel -v $target
       } else {putserv "PRIVMSG $channel :$nick\: Sorry, I can't devoice $target."}
    } else {putserv "PRIVMSG $channel :$nick\: Sorry, you don't have permission to do that."}
  }
}

proc version {nick host handle channel arg} {
  global eddie_ver botnick bseen version
  set eggdrop [string range $version 0 4]
  if {$bseen} {
    set bseen_ver " bseen 1.4.2c,"
  } else {set bseen_ver ""}
  putserv "NOTICE $channel :My name is $botnick and I am running Eggdrop v$eggdrop with$bseen_ver and Eddie Extensions $eddie_ver. I am using [eval unames]."
}

proc time {nick host handle channel arg} {
  global eddie
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  set zone [lindex $arg 0]
  set current [strftime %H:%M]
  if {$zone != ""} {
    if {[string toupper $zone] == "GMT"} {
      puthelp "PRIVMSG $channel :$nick\: GMT is [ctime [expr [unixtime]-3600]]."
    } elseif {[string toupper $zone] == "EST"} {
      puthelp "PRIVMSG $channel :$nick\: EST is [ctime [expr [unixtime]-18000]]."
    } elseif {[string toupper $zone] == "CET" || [string toupper $zone] == "CEST"} {
      puthelp "PRIVMSG $channel :$nick\: CET is [ctime [expr [unixtime]+3600]]."
    } else {putserv "NOTICE $channel :$nick\: Sorry, I don't know about the time in '$zone'."}
  } else {
    puthelp "PRIVMSG $channel :$nick\: It's $current in the United Kingdom. Don't you have a clock on your computer??"
  }
}

proc uptime {nick host handle channel arg} {
  global eddie uptime botnick
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  putserv "PRIVMSG $channel :Uptime for $botnick: [duration [expr [unixtime]-$uptime]]"
}

proc 8ball {nick host handle channel arg} {
  global magic
  set cmd [string tolower [lindex $arg 0]]
  if {![isop $nick $channel] && ![matchattr $handle o]} {
    if {$cmd == "on" || $cmd == "off"} {
      putserv "NOTICE $channel :$nick\: Sorry, you don't have permission to do that." 
      return 0
    }
  }
  if {$cmd == "on"} {
    putserv "NOTICE $channel :My magic 8-ball is now online.   \:-)"
    set magic 1
    return 0
  }
  if {$cmd == "off"} {
    putserv "NOTICE $channel :My magic 8-ball is now offline."
    set magic 0
  }
  if {!$magic} {return 0}
  if {$cmd == ""} {
    putserv "NOTICE $channel :ERROR\: No question specified."
    return 0
  }
  if {[file exists 8ball.txt]} {
    set list [open 8ball.txt r]
    set test ""
    while {![eof $list]} {
      set tmp [gets $list]
      set test [lappend test [string trim $tmp]]
    }
    close $list
  } else {putserv "NOTICE $channel :WARNING\: 8ball.txt not found!"}
  set number [rand [expr [llength $test] + 1]]
  putserv "PRIVMSG $channel :$nick, my 8-ball says [lindex $test $number]"
} 

proc whack {nick host handle channel arg} {
  global eddie botnick
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  if {![botisop $channel]} {
    putserv "NOTICE $channel :I need ops on $channel to whack people!"
    return 0
  }
  set victim [lindex $arg 0]
  if {$victim == $botnick} {
    putserv "PRIVMSG $channel :$nick:\ You can't do that to me... hehe"
    putserv "PRIVMSG $channel :\001ACTION whacks $nick with a lead pipe\001"
    putkick $channel $nick "Respect me!"
    putserv "PRIVMSG $channel :oops, hit him too hard..."
    return 0
  }
  if {![isop $nick $channel] && $victim != "me"} {return 0}
  if {[string tolower $victim] == "me" && ![onchan "me" $channel]} {set victim $nick}
  if {![onchan $victim $channel]} {
    putserv "NOTICE $channel :$victim is not on $channel"
  } else {
    putserv "PRIVMSG $channel :\001ACTION whacks $victim with a lead pipe\001"
    putkick $channel $victim "ouch"
    putserv "PRIVMSG $channel :oops, hit him too hard..."
    putcmdlog "($nick) !$handle! whacked $victim on $channel"
  }
}

proc seanmode {nick host handle channel arg} {
  global seanmode
  if {!$seanmode || ![botisop $channel]} {return 0}
  putserv "PRIVMSG $channel :$nick:\ Fool! \:-)"
  putserv "PRIVMSG $channel :\001ACTION spanks $nick\001"
  putkick $channel $nick "Don't beg for ops!"
}

proc showlist {nick host handle channel arg} {
  if {[botisop $channel]} {putkick $channel $nick "No cake for you!"}
  putcmdlog "($nick) !$handle! was tricked by !list"
}

proc giveme {nick host handle channel arg} {
  global eddie
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  if {$arg == ""} {set arg "nothing"}
  putserv "PRIVMSG $channel :\001ACTION gives $arg to $nick\001"
}

proc giveto {nick host handle channel arg} {
  global eddie
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  if {$arg == ""} {
    help $nick $host $handle $channel giveto
    return 0
  }
  set person [lindex $arg 0]
  set item [lrange $arg 1 end]
  if {$item == ""} {set item "nothing"}
  if {[string tolower $person] == "me"} {set person $nick}
  putserv "PRIVMSG $channel :\001ACTION gives $item to $person\001"
}

proc pi {nick host handle channel arg} {
  global eddie
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  set places [lindex $arg 0]
  set pie 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679
  if {$places > 100 || $places < 1} {set places 100}
  putserv "PRIVMSG $channel :Pi = [string range $pie 0 [expr $places+2]]"
}

proc calc {nick host handle channel arg} {
  global eddie pi e g
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  if {$arg != "" && ![string match "\[" $arg] && ![string match "\]" $arg]} { 
    putserv "PRIVMSG $channel :[expr $arg]"
  } else {help $nick $host $handle $channel calc}
}

proc status {nick host handle channel arg} {
  global eddie botnick
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  putserv "NOTICE $channel :\002Channel status on $channel :\002"
  putserv "NOTICE $channel :Topic\: [topic $channel]"
  putserv "NOTICE $channel :Modes\: [getchanmode $channel]"
  putserv "NOTICE $channel :\002My status :\002"
  putserv "NOTICE $channel :Linked bots\:  [bots]"
  putserv "NOTICE $channel :User records\: [countusers]"
  putserv "NOTICE $channel :My time:     [realtime date], [realtime]"
  putserv "NOTICE $channel :Bot owners:  [userlist n]"
  putcmdlog "($nick) !$handle! !status"
}

proc lock {nick host handle chan arg} {
  global eddie
  if {[string first $chan $eddie(chans)] < 0} {return 0}
  if {![isop $nick $chan] && ![matchattr $handle o]} {
    putserv "NOTICE $nick :$nick\: Sorry, you don't have permission to do that." 
    return 0
  }
  if {![botisop $chan]} {
    putserv "NOTICE $nick :I need ops on $chan to adjust the lock on the channel!"
    return 0
  }
  set cmd [lindex $arg 0]
  if {$cmd == "off"} {
#    pushmode $chan -i
    pushmode $chan -k $eddie(code)
    flushmode $chan
    putserv "NOTICE $chan :$chan should now be unlocked."
    putcmdlog "($nick) !$handle! unlocked $chan"
    return 0
  }    
  set chmode [getchanmode $chan]
  if {[string first "k" $chmode] > 0} {
    putserv "NOTICE $chan :$chan is already locked."
    return 0
  }
  set chars abcdefghijklmnopqrstuvwxyz0123456789
  set count [string length $chars]
  set eddie(code) ""
  for {set i 0} {$i < 8} {incr i} {append eddie(code) [string index $chars [rand $count]]}
#  pushmode $chan +i
  pushmode $chan +s
  pushmode $chan +t
  pushmode $chan +k $eddie(code)
  flushmode $chan
  putserv "NOTICE $chan :$chan should now be locked."
  putcmdlog "($nick) !$handle! locked $chan"
} 

proc unlock {nick host handle channel arg} {
  lock $nick $host $handle $channel "off"
}

proc quote {nick host handle channel arg} {
  global eddie quotedir
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  set filename "Techies.sg"
  if {$arg != ""} {set filename $arg}
  set filename $quotedir$filename
  if {[file exists $filename]} {
    set list [open $filename r]
    while {![eof $list]} {
      set quotes [lappend quotes [string trim [gets $list]]]
    }
    close $list
    set number [rand [llength $quotes]]
    puthelp "PRIVMSG $channel :[lindex $quotes $number]"
  } else {putserv "NOTICE $channel :WARNING\: $filename not found!"}
}

proc addquote {nick host handle channel arg} {
  global eddie quotedir
  if {[matchattr $handle n] || [matchattr $handle m]} {
    if {$arg == ""} {
      putserv "PRIVMSG $channel :ERROR\: You must specify a quote!"
    } else {
      putserv "PRIVMSG $channel :Not implemented yet."
    }
  } else {putserv "NOTICE $nick :Sorry, you don't have permission to do that."}
}

proc randInt { min max } {
    set randDev [open /dev/urandom {RDONLY}]
    set random [read $randDev 8]
    binary scan $random H8 random
    set randomInt [scan $random %x]
    putlog "reading from /dev/urandom - min is $min, max is $max, random is $random ($randomInt)"
    set random [expr {($randomInt % (($max-$min) + 1) + $min)}]
    putlog " \[$randomInt % (($max - $min) + 1) + $min\] = $random"
    close $randDev
    return $random
}

proc random {nick host handle channel arg} {
  global eddie
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  if {$arg < -1 || [regexp {^[0-9].[0-9].[0-9]+$} $arg]} {set arg 10}
  putserv "PRIVMSG $channel :The random number I have selected is [randInt 1 $arg]. The maximum was $arg."
}

proc random2 {nick host handle channel arg} {
  global eddie
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  if {$arg < -1 || [regexp {^[0-9].[0-9].[0-9]+$} $arg]} {set arg 10}
  putserv "PRIVMSG $channel :The random number I have selected is [expr [eval rand $arg] +1]. The maximum was $arg."
}



proc sms {nick host handle channel arg} {
  # Only people with +o or +f flags on the bot or operator status on the channel can use this
  global eddie sms_user sms_addy
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  if {[lindex $arg 1] == ""} {
    help $nick $host $handle $channel sms
  } elseif {$sms_user == "" || $sms_addy == ""} {
    putserv "NOTICE $nick :ERROR\: SMS data not loaded. Please inform a bot owner or master."
  } elseif {[matchattr $handle o] || [matchattr $handle f] || [isop $nick $channel]} {
    set sms_alias [string tolower [lindex $arg 0]]
    set tmp [lsearch -exact $sms_user $sms_alias]
    if {$tmp < 0} {
      putserv "NOTICE $nick :ERROR\: Alias $sms_alias was not found!"
      return 0
    } else {
      exec mail -s "[lrange $arg 1 end]" [lindex $sms_addy $tmp]
      putserv "NOTICE $nick :Your message is on it's way!"
      putcmdlog "($nick) !$handle! just sent an SMS message to $sms_alias."
    }
  } else {putserv "NOTICE $nick :Sorry, you don't have permission to do that."}
}

proc url {nick host handle channel arg} {
  global eddie url_name url_addy
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  if {[lindex $arg 0] == ""} {
    help $nick $host $handle $channel url
  } elseif {$url_name == "" || $url_addy == ""} {
    putserv "NOTICE $nick :ERROR\: URL data not loaded. Please inform a bot owner or master."
  } else {
    set url_alias [string tolower [lindex $arg 0]]
    set tmp [lsearch -exact [string tolower $url_name] $url_alias]
    if {$tmp < 0} {
      putserv "NOTICE $nick :ERROR\: Alias $url_alias was not found!"
    } else {putserv "PRIVMSG $channel :$url_alias may be found at [lindex $url_addy $tmp]"}
  }
}

proc ping_me {nick host handle channel arg} {
  global eddie pingchan pingwho
  if {[string first $channel $eddie(chans)] < 0 || $handle == "*"} {return 0}
  if {![isop $nick $channel] && ![matchattr $handle o]} {return 0}
  set arg [string tolower $arg]
  if {$arg == "" || [string match "#*" $arg]} {
    help $nick $host $handle $channel ping
  } elseif {$arg == "me"} {
    putserv "PRIVMSG $nick :\001PING [unixtime]\001"
    set pingwho 0
  } else {
    putserv "PRIVMSG $arg :\001PING [unixtime]\001"
    set pingwho 1
  }  
  set pingchan $channel
}

proc ping_me_reply {nick host handle dest key arg} {
  global pingchan pingwho
  if {![regexp "\[^0-9\]" $arg]} {
    if {!$pingwho} {
      puthelp "PRIVMSG $pingchan :$nick\: You're [expr [unixtime] - $arg] seconds lagged."
    } else {puthelp "PRIVMSG $pingchan :$nick is [expr [unixtime] - $arg] seconds lagged."}
  }
  return 1
}

proc cleanusers {nick host handle channel arg} {
  # Only the bot's owners can use this command
  global eddie Expired_after
  if {[string first $channel $eddie(chans)] < 0 || ![matchattr $handle n] || $Expired_after <= 0} {return 0}
  set expire [expr $Expired_after * 86400]
  set current [unixtime]
  foreach i [userlist] {
    set last [lindex [getuser $i LASTON] 0]
    if {$last == ""} {set last 0}
    set difference [expr ($current - $last)]
    if {$difference > $expire} {
      set check 0
      foreach j [channels] {
        set tmp [chattr $i $j]
        if {[regexp "o" $tmp] || [regexp "b" $tmp] || [regexp "v" $tmp] || [regexp "k" $tmp]} {set check 1}
      }
      if {!$check} {
        putlog "\002$i\002 has not been seen for [duration $difference] - DELETING..."
        deluser $i
      }
    }
  }
  putcmdlog "($nick) !$handle! cleaned up the userlist"
  putserv "NOTICE $nick :Done."
}

proc pub_resetbans {nick host handle channel arg} {
  global eddie
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  if {![isop $nick $channel] && ![matchattr $handle o]} {return 0}
  putserv "NOTICE $channel :Now resetting all bans on $channel to match my banlist..."
  resetbans $channel
  putcmdlog "($nick) !$handle! !resetbans"
}

proc whoami {nick host handle channel arg} {
  global eddie botnick
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  putserv "PRIVMSG $nick :You are $nick !$host"
  if {[validuser $handle]} {
    putserv "NOTICE $nick :Your handle on $botnick is $handle with [chattr $handle $channel] flags."
    putserv "NOTICE $nick :Your hosts are [getuser $handle HOSTS]"
    if {[matchattr $handle n] || [matchattr $handle m]} {putserv "NOTICE $nick :You are my owner or a master"}
    set info [getuser $handle INFO]
    if {$info == ""} {return 0}
    putserv "NOTICE $nick :Your global INFO line is $info"
  }
}

proc xmas {nick host handle channel arg} {
  global eddie
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  set curr_year [lindex [ctime [unixtime]] 4]
  set xmas_day [expr 883008000 + (($curr_year - 1998) * 31536000)]
  putserv "PRIVMSG $channel :It is [time_diff [unixtime] $xmas_day] since last Christmas."
  set days [time_diff [unixtime] [expr $xmas_day + 604800]]
  putserv "PRIVMSG $channel :We are $days into $curr_year."
  set days [time_diff [expr $xmas_day + 31536000] [unixtime]]
  set tmp [time_diff [expr $xmas_day + 31536000 + 604800] [unixtime]]
  putserv "PRIVMSG $channel :You have $days left to shop before Christmas and $tmp left before [expr $curr_year + 1]!  \:)"
}

proc invite {nick host handle channel arg} {
  global invite
  if {[string first $chan $invite(from)] < 0 || $invite(from) == ""} {return 0}
  if {$invite(from) == "*"} {set $invite(from) [channels]}
  foreach chan $invite(to) {
    if {[matchattr $handle $invite(flag)] && ![onchan $nick $chan]} {putserv "INVITE $nick $chan"}
  }
}

proc flags {nick host handle channel arg} {
  global eddie
  if {[string first $channel $eddie(chans)] < 0} {return 0}
  if {[isop $nick $channel] || [matchattr $handle o] || [matchchanattr $handle o $channel]} {
    set hand [lindex $arg 0]
    if {[string tolower $hand] == "me" || $hand == ""} {set hand $handle}
    if {[validuser $hand]} {
      putserv "PRIVMSG $channel :$hand has \002[chattr $hand $channel]\002 flags on $channel."
    } else {putserv "PRIVMSG $channel :No such handle\: $hand"}
  }
}

proc help {nick host handle chan arg} {
  global eddie bseen help_notice url_name
  if {[string first $chan $eddie(chans)] < 0} {return 0}
  set cmd [lindex [string tolower $arg] 0]
  if {$cmd == "me"} {
    set tmp $nick
  } else {set tmp $chan}   
  if {!$help_notice} {set chan $nick}
  switch $cmd {
  "calc" {
    putserv "NOTICE $chan :Usage\: \002!calc\002 <expression, eg. 4+2>"
    putserv "NOTICE $chan :Available constants:  \$pi \$e \$g"
    putserv "NOTICE $chan :Available maths functions:  abs(), acos(), asin(), atan(), atan2(), ceil(), cos(), cosh(), exp(), floor(), fmod(), hypot(), log(), log10(), pow(), round(), sin(), sinh(), sqrt(), tan(), tanh()"
    putserv "NOTICE $chan :\[ and \] are forbidden characters in the expression."
  } "giveto" {
    putserv "NOTICE $chan :Usage\: \002!giveto\002 <person> <item>"
  } "sms" {
    putserv "NOTICE $chan :Usage\: \002!sms\002 <alias> <short text message>"
    putserv "NOTICE $chan :Only ops and friends (+f) the bot recognises may use this command."
    putserv "NOTICE $chan :Aliases and email addresses should be set in scripts/sms.dat"
  } "ping" {
    putserv "NOTICE $chan :Usage\: \002!ping\002 <nick>"
    putserv "NOTICE $chan :Use 'me' for self pinging."
  } "url" {
    putserv "NOTICE $chan :Usage\: \002!url\002 <name>"
    putserv "NOTICE $chan :Possible names\: $url_name"
  } default {
    puthelp "NOTICE $tmp :!version  !giveme <item>  !giveto <nickname> <item>  !time <zone>  !list  !op"
    puthelp "NOTICE $tmp :!uptime  !8ball <question>  !calc <expression>  !insult <nick>  !seanmode  !bar"
    puthelp "NOTICE $tmp :!status  !pi <d.p.>  !quote  !poll  !random <max>  !whoami  !xmas  !voice  !eddie"
    puthelp "NOTICE $tmp :!sms <alias> <message>  !url <name>"
    if {$bseen} {puthelp "NOTICE $tmp :!seen <nickname>  !seenstats  !chanstats <channel>  !lastspoke <nickname>"}
    puthelp "NOTICE $tmp : = "
    puthelp "NOTICE $tmp :!encrypt <text>  and  !decrypt <text>  are also available in a query to me."
    puthelp "NOTICE $tmp : ="
    puthelp "NOTICE $tmp :The following commands are for ops only:"
    puthelp "NOTICE $tmp :  !whack <nickname>  !8ball <on/off>  !lock <on/off>  !ping <nick>  !resetbans"
    puthelp "NOTICE $tmp :  !voice <nickname>  !devoice <nickname>  !flag <handle>"
    puthelp "NOTICE $tmp :Owners can also use:  !cleanusers"
#    puthelp "NOTICE $tmp :Owners can also use:  !cleanusers  !addquote <newquote>"
  }}
}

proc pub_nocomic {nick host handle chan arg} {
  global eddie botnick nocomic
  if {[string first $chan $eddie(chans)] < 0 || !$nocomic || [matchattr $handle b]} {return 0}
  if {![botisop $chan]} {
    putserv "PRIVMSG $chan :\001ACTION yells 'MS Comic Chat sucks!'\001"
  } elseif {![matchattr $handle n]} {
    putserv "PRIVMSG $nick :\002Microsoft Comic Chat is a forbidden client on $chan, so please go and get a decent IRC client.\002"
    putserv "PRIVMSG $chan :\002$nick : We don't allow MS Comic Chat clients in \"comic\" mode to be used.\002"
    newchanban $chan [maskhost $nick!$host] $botnick "MS Comic Chat auto-removal" 1
    putserv "KICK $chan $nick :\002MS Comic Chat auto-removal\002"
  }
}

proc checkbase {nick host handle chan arg} {putlog "All your base are belong to $nick"}

proc encrypt1 {nick host handle arg} {
  global eddie_key
  if {$arg == ""} {putserv "PRIVMSG $nick :You must give me something to encrypt... \;)"}
  putserv "PRIVMSG $nick :[encrypt $eddie_key $arg]"
}

proc decrypt1 {nick host handle arg} {
  global eddie_key
  if {$arg == ""} {putserv "PRIVMSG $nick :You must give me something to decrypt... \;)"}
  putserv "PRIVMSG $nick :[decrypt $eddie_key $arg]"
}

proc got_dcc {nick host handle dest key arg} {
  global botnick
  set filename [string tolower [lindex $arg 1]]
  if {[string match "*.exe" $filename] || [string match "*.bat" $filename] || [string match "*.vbs" $filename] || [string match "*.ini" $filename]} {
    newban "*!*$host" $botnick "Infected with a virus ($filename)" 20 sticky
    foreach i [channels] {putkick $i $nick "You're infected with $filename virus"}
    putserv "PRIVMSG $nick :You're infected with a virus ($filename). For more information please visit http://www.nohack.net"
#    foreach i [channels] {if {[onchan $nick $i]} {putkick $i $nick "You're infected with $filename virus - GET OUT!"}}
  }
}

proc ctopic {nick host handle channel topic} {
  global eddie botnick t_locks
  set chan [string tolower $channel]
  if {[string first $chan $eddie(chans)] < 0 || $nick == "*"} {return 0}
  set old_topic $topic
  if {[string first $chan $t_locks] > -1} {
    if {$nick == $botnick} {return 0}
    putserv "TOPIC $chan :$old_topic"
    putserv "NOTICE $nick :Sorry, the topic for $chan is locked."
  } else {
    if {$nick == $botnick} {set nick "I"}
    putserv "PRIVMSG $chan :$nick just changed the topic of $chan.... that's.... interesting \:-)"
  }
}

proc enter {nick host handle channel} {
  global chan_limits botnick eddie greeting greeter
  set chan [string tolower $channel]
  if {[lsearch -exact [string tolower [channels]] $chan] == -1} {return 0}
  if {[validuser $handle] && [string first $chan $chan_limits] > -1} {pushlimit $chan}
  if {$nick == $botnick || [matchattr $handle b] || $greeting != 1} {return 0}
  if {[string first $chan $eddie(chans)] < 0 && $greeting < 2} {return 0}
  if {![file exists $greeter] || $greeter == 1} {putserv "NOTICE $nick :Greetings $nick, welcome to $chan!!"}
}
	
proc kicked {nick host handle chan target reason} {
  global botnick eddie
  if {[string first $chan $eddie(chans)] < 0} {return 0}
  if {$target == $botnick} {
    putserv "PRIVMSG $nick :Please don't kick me again!"
    return 0
  }
  set sayings {"hehe, $nick kicked you from $chan :-)" "$target, you deserved that kick."
    "Hahahahaha bye bye $target!" "You won't be missed at $chan! :)" "You are off the xmas card list!"
    "$chan air sure smells cleaner now! ;-)" "$nick doesn't like you. ;)"}
  if {[string tolower $nick] == [string tolower $botnick]} {set nick "I"}
  set msg [parse_msg [lindex $sayings [rand [llength $sayings]]] $nick $chan $target]
  puthelp "PRIVMSG $target :$msg"
}

proc sign {nick host handle channel reason} {
  global eddie sign_msg
  if {[string first $channel $eddie(chans)] < 0 || !$sign_msg} {return 0}
  set sayings {"\:-(  $nick left us for some strange reason..." "I'll miss $nick... \:-p"
    "I wonder where $nick has gone..." "I hope $nick comes back a nicer person! \;-)"}
  set msg [parse_msg [lindex $sayings [rand [llength $sayings]]] $nick $channel ""]
  putserv "PRIVMSG $channel :$msg"
}

proc opped {nick host handle channel modechange victim} {
  global botnick
  if {$victim == $botnick} {putserv "PRIVMSG $channel :$nick\: thanks ;-)"}
}

proc asl {nick host handle text} {
  global last_asked botnick
  set sayings {"I'm female, I'm over a year old and I was born in England." "why should I tell you my asl?"}
  if {[string tolower $nick] == [string tolower $botnick]} {set nick "I"}
  set msg [parse_msg [lindex $sayings [rand [llength $sayings]]] $nick "" ""]
  if {$last_asked == $nick} {puthelp "PRIVMSG $nick :Haven't I already told you my details? Anyway..."}
  puthelp "PRIVMSG $nick :$msg"
  set last_asked $nick
}

proc check_limits {min hour day month year} {
  global chan_limits
  foreach i $chan_limits {if {[validchan $i]} {pushlimit $i}}
}

proc pushlimit {channel} {
  global n eddie_lim
  if {![botisop $channel] || !$eddie_lim} {return 0}
  set wanted [expr [llength [chanlist $channel]] + $n]
  set limit [lindex [getchanmode $channel] end]
  if {$limit != $wanted} {pushmode $channel +l $wanted}
}

proc bot_check {bot cmd arg} {
  global eddie_ver botnick
  putlog "\#[lindex $arg 1]@$bot\# EDDIE_CHECK"
  putbot $bot "vBOTNET_EDDIE_CHECK_ACK [lindex $arg 0] $botnick running Eddie's Extensions version $eddie_ver"
}

proc bot_check_ack {bot cmd arg} {putdcc [lindex $arg 0] "$bot acknowledged: [lreplace $arg 0 0]"}

proc say_stuff {} {
  global maxtime
  set number [rand [llength [channels]]]
  set clist [chanlist [lindex [channels] $number]]
  set nick [lindex $clist [rand [llength $clist]]]
  set chan [lindex [channels] $number]
  set sayings {"is anyone out there?" "anyone awake?" "aarrgghh" "baaaaah" "hehe" "damn!"
    "anyway..." "hehe" "mwhahaha" "ha ha" "hello" "hiya" "hi everyone" "howdy" "lo" "lol"
    "\001ACTION yawns...\001" "\001ACTION looks around the room\001"
    "\001ACTION slaps $nick about a bit with a large trout\001"}
  set msg [parse_msg [lindex $sayings [rand [llength $sayings]]] $nick $chan ""]
  puthelp "PRIVMSG $chan :$msg"
  timer [expr [rand $maxtime] + 1] say_stuff
}

proc parse_msg {msg nick chan target} {
  if {($msg != "")} {
    regsub {\$nick} $msg $nick msg
    regsub {\$target} $msg $target msg
    regsub {\$chan} $msg $chan msg
    regsub {\\001} $msg \001 msg
    regsub {\\001} $msg \001 msg
    regsub {\\002} $msg \002 msg
    regsub {\\002} $msg \002 msg
  }
  return $msg
}

proc time_diff {time2 time1} {
  set tmp [expr $time2 - $time1]
  set secs [expr $tmp % 60]
  set tmp [expr ($tmp - $secs) / 60]
  set mins [expr $tmp % 60]
  set tmp [expr ($tmp - $mins) / 60]
  set hrs [expr $tmp % 24]
  set days [expr ($tmp - $hrs) / 24]
  if {$days} {
    lappend result $days day
    if {$days > 1} {append result s}
  }
  if {$hrs} {
    lappend result $hrs hour
    if {$hrs > 1} {append result s}
  }
  if {$mins} {
    lappend result $mins minute
    if {$mins > 1} {append result s}
  }
  if {$secs} {
    lappend result $secs second
    if {$secs > 1} {append result s}
  }
  return $result
}

foreach tmp $sms_data {
  if {[lindex $tmp 0] != "" && [lindex $tmp 1] != "" && [string first "@" [lindex $tmp 1]] > 0} {
    lappend sms_user [lindex $tmp 0]
    lappend sms_addy [lindex $tmp 1]
  }
}
foreach tmp $url_data {
  regsub {\$host} $tmp [string range $botname [expr [string first "@" $botname] + 1] end] tmp
  if {[lindex $tmp 0] != "" && [lindex $tmp 1] != "" && [string length [lindex $tmp 1]] > 5} {
    lappend url_name [lindex $tmp 0]
    lappend url_addy [lindex $tmp 1]
  }
}
if {[info vars ctcp-version] == "ctcp-version"} {set ctcp-version "${ctcp-version} + eddies extensions $eddie_ver"}
putlog "\002Eddie's Extensions\002 $eddie_ver by Jamie Cheetham  -- loaded! --"
if {$maxtime >= 1} {timer [expr [rand $maxtime] + 1] say_stuff}
