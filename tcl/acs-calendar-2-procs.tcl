
# /packages/acs-datetime/tcl/acs-calendar-procs.tcl

ad_library {

    Library for calendar display widgets

    @author  ron@arsdigita.com
    @creation-date 2000-11-21
    @cvs-id  $Id$
}

ad_proc dt_widget_week { 
    {
	-calendar_details "" 
	-date "" 
	-large_calendar_p 1 
	-master_bgcolor "" 
	-header_bgcolor "" 
	-header_text_color "white" 
	-header_text_size "+2" 
	-day_template {<!--$julian-->$day} 
	-day_header_size 2 
	-day_header_bgcolor "#666666" 
	-calendar_width "100%" 
	-day_bgcolor "#DCDCDC" 
	-today_bgcolor "#FFF8DC" 
	-day_text_color "white" 
	-empty_bgcolor "white"  
	-next_week_template ""   
	-prev_week_template "" 
	-prev_next_links_in_title 0 
	-fill_all_days 0 
    }
} {
    Returns a calendar for a specific week, with details supplied by
    Julian date. Defaults to this week. 

    To specify details for the individual days (if large_calendar_p is
    set) put data in an ns_set calendar_details.  The key is the
    Julian date of the day, and the value is a string (possibly with
    HTML formatting) that represents the details. 

    The variables in the templates are:
    - day_template: julian,day,date,pretty_date
    - next_week_template:
    - prev_week_template:
} {

    set today_date [dt_sysdate]

    if {[empty_string_p $date]} {
        set date $today_date
    }

    set current_date $date

    set date_list [dt_ansi_to_list $current_date]

    set year [dt_trim_leading_zeros [lindex $date_list 0]]
    set month [dt_trim_leading_zeros [lindex $date_list 1]]
    set day [dt_trim_leading_zeros [lindex $date_list 2]]

    set current_date_julian [dt_ansi_to_julian $year $month $day]

    # 1 = Sun ... 7 = Sat
    set current_date_weekday_no [expr [clock format [clock scan $date] -format %w] + 1]

    # What day does the week start on?
    # 0 = Sunday, 6 = Saturday
    set first_day_of_week [lc_get firstdayofweek]

    set first_day_of_week_julian [expr $current_date_julian - (($current_date_weekday_no + 6 - $first_day_of_week) % 7)]

    set last_week [dt_julian_to_ansi [expr $current_date_julian - 7]]
    set last_week_pretty [lc_time_fmt $last_week "%q"]
    set next_week [dt_julian_to_ansi [expr $current_date_julian + 7]]
    set next_week_pretty [lc_time_fmt $next_week "%q"]

    # Initialize the ns_set
    if { [empty_string_p $calendar_details] } {
	set calendar_details [ns_set create calendar_details]
    }

    set julian $first_day_of_week_julian
    set return_html "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"95%\">\n"
    
    # Navigation Bar
    append return_html "<tr><td>
    <table cellpadding=\"3\" cellspacing=\"0\" border=\"0\" width=\"90%\" class=\"table-display\">
    <tr class=\"table-header\" bgcolor=\"lavender\">
    <td align=center>
    [subst $prev_week_template]
    <font face=\"Arial,Helvetica\" size=\"-1\">
    <B>
    [lc_time_fmt [dt_julian_to_ansi $first_day_of_week_julian] "%Q"] - [lc_time_fmt [dt_julian_to_ansi [expr $first_day_of_week_julian + 6]] "%Q"]
    </B>
    </FONT>
    [subst $next_week_template]
    </td>
    </tr>
    </table></td></tr>
    "

    append return_html "<tr>
    <td>
    <table  class=\"table-display\" cellpadding=0 cellspacing=0 border=0 width=90%>"

    for { set julian $first_day_of_week_julian } { $julian < [expr $first_day_of_week_julian + 7] } { incr julian } {
        set date [dt_julian_to_ansi $julian]
        set pretty_date [string totitle [lc_time_fmt $date "%q"]]
        set day [string totitle [lc_time_fmt $date "%A"]]
        set day_html [subst $day_template]

        if {$date == $today_date} {
            set bgcolor $today_bgcolor
        } else {
            set bgcolor $day_bgcolor
        }

        append return_html "<tr><td class=\"cal-week\" bgcolor=\"$bgcolor\">$day_html &nbsp;
        </td>
        </tr>
        <tr>
        <td class=\"cal-week-event\">
        <table cellpadding=0 cellspacing=0 border=0 width=100%>"
	    
        # Go through events
        while {1} {
            set index [ns_set find $calendar_details $julian]
            if {$index == -1} {
                break
            }

            append return_html "
            <tr>
            <td class=\"cal-week-event\">
            <font size=-1>
            [ns_set value $calendar_details $index]		    
	    </font>
	    </td>      
	    </tr>
	    "

            ns_set delete $calendar_details $index
        }

        append return_html "</table></td></tr>"


        append return_html "</td></tr>\n"
    }

    append return_html "</table></td></tr></table>"
    
    return $return_html
}



ad_proc dt_widget_day { 
    {
	-calendar_details "" 
	-date ""
        -hour_template {$display_hour}
        -start_hour {0}
        -end_hour {23}
        -show_nav 1
        -prev_nav_template {<a href="?date=[ns_urlencode $yesterday]">&lt;</a>}
        -next_nav_template {<a href="?date=[ns_urlencode $tomorrow]">&gt;</a>}
	-master_bgcolor "black" 
	-header_bgcolor "black" 
	-header_text_color "white" 
	-header_text_size "+2" 
	-calendar_width "100%" 
	-day_bgcolor "#DDDDDD" 
	-today_bgcolor "yellow" 
	-day_text_color "white" 
	-empty_bgcolor "white"  
        -overlap_p 0
    }
} {
    Returns a calendar for a specific day, with details supplied by
    hour. Defaults to today.

} {

    if {[empty_string_p $date]} {
        set date [dt_sysdate]
    }

    set current_date $date

    # Initialize the ns_set
    if [empty_string_p $calendar_details] {
	set calendar_details [ns_set create calendar_details]
    }

    for { set hour 0 } { $hour < 24 } { incr hour } { 
        if { ($hour < $start_hour || $hour > $end_hour) && [ns_set find $calendar_details [format "%02d" $hour]] != -1 } {
            if { $hour < $start_hour } {
                set start_hour $hour
            } elseif { $hour > $end_hour } {
                set end_hour $hour
            }
        }
    }

    # Collect some statistics about the events (for overlap)
    for {set hour $start_hour} {$hour <= 23} {incr hour} {
        set n_events($hour) 0
        set n_starting_events($hour) 0
    }

    # Count number of overlapping events each hour

    # Make a copy of the calendar_details set that we can work on for a minute, discard afterwards.
    set calendar_details_2 [ns_set copy $calendar_details]

    for {set hour $start_hour} {$hour <= $end_hour} {incr hour} {
        if {$hour < 10} {
            set index_hour "0$hour"
        } else {
            set index_hour $hour
        }

        # Go through events
        while {1} {
            set index [ns_set find $calendar_details_2 $index_hour]
            if {$index == -1} {
                break
            }
            
            set item_val [ns_set value $calendar_details_2 $index]
            ns_set delete $calendar_details_2 $index
            # Count the num of events starting at this hour
            set n_starting_events($hour) [expr $n_starting_events($hour) + 1]

            # Diff the hours 
            set hours_diff [dt_hour_diff -start_time [lindex $item_val 0] -end_time [lindex $item_val 1]]

            # Count the num of events at the hours of operations
            for {set i 0} {$i <= $hours_diff} {incr i} {
                set the_hour [expr $hour + $i]
                set n_events($the_hour) [expr $n_events([expr $the_hour - $i]) + 1]
            }
        }
    }

    # the MAX num of events
    set max_n_events 1
    for {set hour $start_hour} {$hour <= $end_hour} {incr hour} {
        if {$max_n_events < $n_events($hour)} {
            set max_n_events $n_events($hour)
            ns_log Notice "BMA-DEBUG-CAL: Setting max_n_events to $max_n_events"
        }
    }
    
    # Select some basic stuff, sets day_of_the_week, yesterday, tomorrow vars
    db_1row select_day_info {}
    
    set day_of_the_week [string totitle [lc_time_fmt $current_date "%Q"]]

    set return_html ""

    if {$show_nav} {
        set prev_nav [subst $prev_nav_template]
        set next_nav [subst $next_nav_template]
        append return_html "<table border=0 cellspacing=0 cellpadding=0 width=$calendar_width><tr class=\"table-header\"><th> $prev_nav &nbsp; &nbsp; $day_of_the_week $next_nav &nbsp; &nbsp; </th></tr>
</table>"
    }

    # Loop through the hours of the day
    append return_html "<table border=0 cellpadding=0 cellspacing=0 width=$calendar_width><tr><td><table cellpadding=1 cellspacing=0 border=0 width=100%>
"

    # The items that have no hour (all day events)
    set hour ""
    set next_hour ""
    set start_time ""
    set odd_row_p 0
    set display_hour "<img border=0 align=\"center\" src=\"/doc/acs-datetime/pics/diamond.gif\" alt=\"No Time\">"
    append return_html "<tr class=\"z_light\"><td class=\"center\" align=\"left\" width=\"60\" \"nowrap\"><font size=-1>[subst $hour_template]</font></td>"
    append return_html "<td colspan=\"$max_n_events\"><font size=-1>"
    
    # Go through events
    while {1} {
        set index [ns_set find $calendar_details "X"]
        if {$index == -1} {
            break
        }
        
        if {$overlap_p} {
            append return_html "[lindex [ns_set value $calendar_details $index] 2]<br>"
        } else {
            append return_html "[ns_set value $calendar_details $index]<br>\n"
        }
        
        ns_set delete $calendar_details $index
    }

    append return_html "</font>
    </td></tr>"

    # Normal hour-by-hour display
    for {set hour $start_hour} {$hour <= $end_hour} {incr hour} {
        
        set next_hour [expr $hour + 1]

        if {$hour < 10} {
            set index_hour "0$hour"
        } else {
            set index_hour $hour
        }
        
        set display_hour [string tolower [string trimleft [lc_time_fmt "0000-00-00 ${hour}:00:00" "%X"] 0]]

	if { $odd_row_p } {
	    set class "z_light"
	    set odd_row_p 0
	} else {
	    set class "z_dark"
	    set odd_row_p 1
	}

        set display_hour [subst $hour_template]
        append return_html "<tr class=\"$class\"><td class=\"center\" align=left width=\"60\" \"nowrap\"><nobr><font size=-2>$display_hour</font></nobr></td>\n"
        
        set n_processed_events 0
        
        # A flag to force completion of the row
        set must_complete_p 0

        # Go through events
        while {1} {
            set index [ns_set find $calendar_details $index_hour]
            if {$index == -1} {
                break
            }

            incr n_processed_events

            if {$overlap_p} {
                set one_item_val [ns_set value $calendar_details $index]
                
                set hour_diff [dt_hour_diff -start_time [lindex $one_item_val 0] -end_time [lindex $one_item_val 1]]

                set start_time $hour

                # Calculate the colspan
                if {$n_processed_events == $n_starting_events($hour)} {
                    # This is the last one, make it as wide as possible
                    if {$hour_diff > 0} {
                        set colspan 1
                        set must_complete_p 1
                    } else {
                        # HACK
                        set colspan 1
                        set must_complete_p 1
                        #set colspan [expr "$max_n_events - $n_events($hour) + 1"]
                    }
                } {
                    # Just make it one
                    set colspan 1
                } 

                append return_html "<td valign=top rowspan=[expr $hour_diff + 1] colspan=$colspan><font size=-1>[lindex $one_item_val 2]</font></td>"
            } else {
                append return_html "[ns_set value $calendar_details $index]<br>\n"
            }

            ns_set delete $calendar_details $index
        }

        if {$n_processed_events == 0 || ($n_events($hour) < $max_n_events && $must_complete_p)} {
            if {$n_events($hour) == 0 || $n_events($hour) == $n_processed_events} {
		append return_html "<td colspan=\"[expr $max_n_events - $n_events($hour)]\" class=\"$class\">&nbsp;</td>"
	    } else {
		for {set i 0} {$i < [expr "$max_n_events - $n_events($hour)"]} {incr i} {
		    append return_html "<td colspan=\"1\" class=$class>&nbsp;</td>"
		}
	    }
	    

        }

        append return_html "</tr>\n"
    }

    append return_html "</table>
</td></tr>
</table>"
    
    return $return_html
}



ad_proc -public dt_widget_list {
    {-calendar_details:required}
    {-item_template {$item}}
    {-start_date ""}
    {-end_date ""}
    {-order_by ""}
    {-url_template {?order_by=$order_by}}
} {
    create a listing widget for lists

    (ben) I would like to ask forgiveness from the coding gods for this proc.
    Right now this is a big hack to make the schedule look a lot like the SloanSpace v1.0
    display. Once we have thought this through a bit more, I will generalize this proc. I promise.
    Please forgive me.
} {
    # Check for zero size
    if {[ns_set size $calendar_details] == 0} {
        return "<i>[_ acs-datetime.No_Items]</i>"
    }

    # The title
    if {[empty_string_p $start_date] && [empty_string_p $end_date]} {
	#This used to be All Items but that was just taking up space and not adding value so now we assume All Items and only give a title if its something else. - Caroline@meekshome.com
        set title ""
    }

    if {[empty_string_p $start_date] && ![empty_string_p $end_date]} {
        set title "Items until [lc_time_fmt $end_date "%Q"]"
    }

    if {![empty_string_p $start_date] && [empty_string_p $end_date]} {
        set title "Items starting [lc_time_fmt $start_date "%Q"]"
    }

    if {![empty_string_p $start_date] && ![empty_string_p $end_date]} {
        set title "[_ acs-datetime.Items_from] [lc_time_fmt $start_date "%Q"] [_ acs-datetime.to] [lc_time_fmt $end_date "%Q"]"
    }

    set return_html "<b>$title</b><p>"

    # Prepare the templates
    set real_order_by $order_by
    set order_by "item_type"
    set item_type_url [subst $url_template]
    set order_by "start_date"
    set start_date_url [subst $url_template]

    # Create the header
    append return_html "
    <table class=\"table-display\" border=0 cellspacing=0 cellpadding=2>
    <tr class=\"table-header\"><th>[_ acs-datetime.Day_of_Week]</th><th><a href=\"$start_date_url\">[_ acs-datetime.Date]</a></th><th>[_ acs-datetime.Start_Time]</th><th>[_ acs-datetime.End_Time]</th>"

    if {$real_order_by != "item_type"} {
        append return_html "<th><a href=\"$item_type_url\">[_ acs-datetime.Type]</a></th>"
    }


    append return_html "<th>[_ acs-datetime.Title]</th></tr>\n"

    # initialize the item_type so we can do intermediate titles
    set old_item_type ""

    set flip 0

    # Loop through the events, and add them
    for {set i 0} {$i < [ns_set size $calendar_details]} {incr i} {
        set item [ns_set value $calendar_details $i]
        set date [lindex $item 0]
        set start_time [lindex $item 1]
        set end_time [lindex $item 2]
        set weekday [lindex $item 3]
        set item_type [lindex $item 4]
        set item_details [lindex $item 5]

        # Adjust the display of no-time items
        if {[dt_no_time_p -start_time $start_time -end_time $end_time]} {
            set start_time "--"
            set end_time "--"
        }

        # Do we need a title?
        if {$real_order_by == "item_type" && $item_type != "$old_item_type"} {
            if {[empty_string_p $item_type]} {
                set item_type_for_title "([_ acs-datetime.No_Item_Type])"
            } else {
                set item_type_for_title $item_type
            }
            append return_html "<tr class=\"table-title\"><td colspan=5><b>$item_type_for_title</b></td></tr>\n"
            set flip 0
        }

        set old_item_type $item_type

        if {[expr $flip % 2] == 0} {
            set z_class z_light 
        } else {
            set z_class z_dark
        }
        
        append return_html "
        <tr class=$z_class><td>$weekday</td><td>$date</td><td>$start_time</td><td>$end_time</td>"
        
        if {$real_order_by != "item_type"} {
            append return_html "<td>$item_type</td>"
        }

        append return_html "<td>$item_details</td></tr>\n"
        incr flip
    }

    append return_html "</table>
<!-- End of dt_widget_list --->"

    return $return_html
}
    
        
#
# Additional Utility Procs
#

ad_proc dt_midnight_p {
    time
} {
    check if a time is midnight
} {
    if {$time == "00:00" || $time == ""} {
        return 1
    }
    
    if {[regexp {00:00 *[aA][mM]} $time the_match]} {
        return 1
    }
    
    if {[regexp {12:00 *[aA][mM]} $time the_match]} {
        return 1
    }
    
    if {[regexp {[0-9]+-[0-9]+[0-9]+ (0?)0:0(0?)} $time the_match]} {
	return 1
    }

    if {[regexp {[0-9]+-[0-9]+ (0?)0:0(0?)} $time the_match]} {
	return 1
    }
    return 0
}

ad_proc dt_no_time_p {
    {-start_time:required}
    {-end_time:required}
} {
    This decides whether an item is without a time
} {
    # Compare times and make sure it's midnight on both
    if {[dt_midnight_p $start_time] && [dt_midnight_p $end_time]} {
        return 1
    } else {
        return 0
    }
}

ad_proc dt_hour_diff {
    {-start_time:required}
    {-end_time:required}
} {
    24-hour times input (23:00,02:00).
    This gives us the num of hours of difference,
    taking into account that if something goes until 5:01, it is one
    more hour long than if it goes until 5:00
} {
    set start_hour [string trimleft [string range $start_time 0 1] 0]
    set end_hour [string trimleft [string range $end_time 0 1] 0]
    set end_minutes [string range $end_time 3 4]

    # Special case when the hour is exact
    if {[string compare $end_minutes "00"] == 0} {
        return [expr "$end_hour - $start_hour - 1"]
    } else {
        return [expr "$end_hour - $start_hour"]
    }
}
