
ad_proc dt_widget_week { 
    {
	-calendar_details "" 
	-date "" 
	-large_calendar_p 1 
	-master_bgcolor "black" 
	-header_bgcolor "black" 
	-header_text_color "white" 
	-header_text_size "+2" 
	-day_template {<!--$julian-->$day} 
	-day_header_size 2 
	-day_header_bgcolor "#666666" 
	-calendar_width "100%" 
	-day_bgcolor "#DDDDDD" 
	-today_bgcolor "#DDDDDD" 
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

    if {[empty_string_p $date]} {
        set date [dt_sysdate]
    }

    set current_date $date

    # Get information for the week
    db_1row select_week_info {}
    
    # Initialize the ns_set
    if [empty_string_p $calendar_details] {
	set calendar_details [ns_set create calendar_details]
    }

    # Loop through the days of the week
    set julian $sunday_julian
    set return_html "<table border=0 cellpadding=1 cellspacing=0 width=$calendar_width>
    <tr bgcolor=black><td>
    <table cellpadding=2 cellspacing=0 border=0 width=100%>\n"
    
    set days_of_week {Sunday Monday Tuesday Wednesday Thursday Friday Saturday}
    foreach day $days_of_week {

        set lower_day [string tolower $day]
        set julian [set ${lower_day}_julian]
        set date [set ${lower_day}_date]
        set pretty_date [util_AnsiDatetoPrettyDate $date]
        set day_html [subst $day_template]

        append return_html "<tr bgcolor=#cccccc><td>$day_html</td></tr>
        <tr bgcolor=white><td>&nbsp;"
        
        # Go through events
        while {1} {
            set index [ns_set find $calendar_details $julian]
            if {$index == -1} {
                break
            }

            append return_html "[ns_set value $calendar_details $index]<br>\n"

            ns_set delete $calendar_details $index
        }

        append return_html "</td></tr>\n"
        incr julian
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
	-master_bgcolor "black" 
	-header_bgcolor "black" 
	-header_text_color "white" 
	-header_text_size "+2" 
	-calendar_width "100%" 
	-day_bgcolor "#DDDDDD" 
	-today_bgcolor "#DDDDDD" 
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

    # Select some basic stuff
    db_1row select_day_info {}

    set return_html ""

    if {$show_nav} {
        append return_html "<table border=0 cellpadding=0 width=$calendar_width><tr bgcolor=#dddddd><th><a href=?date=$yesterday>&lt;</a> &nbsp; &nbsp; $day_of_the_week &nbsp; &nbsp; <a href=?date=$tomorrow>&gt;</a></th></tr></table><p>\n"
    }

    # Loop through the hours of the day
    append return_html "<table border=0 cellpadding=0 cellspacing=0 width=$calendar_width><tr bgcolor=#999999><td>
    <table cellpadding=1 cellspacing=1 border=0 width=100%>\n"

    # The items that have no hour
    set hour ""
    set next_hour ""
    set start_time ""
    set display_hour "No Time"
    append return_html "<tr bgcolor=#cccccc><td width=70 bgcolor=white><font size=-1>&nbsp;[subst $hour_template]</font></td>"
    if {[ns_set find $calendar_details ""] != -1} {
        append return_html "<td bgcolor=white>"
    }
    
    # Go through events
    while {1} {
        set index [ns_set find $calendar_details "X"]
        if {$index == -1} {
            break
        }
        
        if {$overlap_p} {
            append return_html "[lindex [ns_set value $calendar_details $index] 2]"
        } else {
            append return_html "[ns_set value $calendar_details $index]<br>\n"
        }
        
        ns_set delete $calendar_details $index
    }

    for {set hour $start_hour} {$hour <= $end_hour} {incr hour} {

        set next_hour [expr $hour + 1]

        if {$hour < 10} {
            set index_hour "0$hour"
        } else {
            set index_hour $hour
        }

        # display stuff
        if {$hour >= 12} {
            set ampm_hour [expr $hour - 12]
            set pm 1
        } else {
            set ampm_hour $hour
            set pm 0
        }

        if {$ampm_hour == 0} {
            set ampm_hour 12
        }

        if {$ampm_hour < 10} {
            set display_hour "0$ampm_hour"
        } else {
            set display_hour "$ampm_hour"
        }

        append display_hour ":00 "

        if {$pm} {
            append display_hour "pm"
        } else {
            append display_hour "am"
        }

        set display_hour [subst $hour_template]
        append return_html "<tr bgcolor=white><td width=70><font size=-1>&nbsp;$display_hour</font></td>"
        
        # Go through events
        while {1} {
            set index [ns_set find $calendar_details $index_hour]
            if {$index == -1} {
                break
            }

            if {$overlap_p} {
                set one_item_val [ns_set value $calendar_details $index]
                
                # One ugly hack
                set end_time_lst [split [lindex $one_item_val 1] ":"]

                if {[string range [lindex $end_time_lst 1] 0 1] == "00"} {
                    set end_time [expr [string trimleft [lindex $end_time_lst 0] 0] - 1]
                } else {
                    set end_time [lindex $end_time_lst 0]
                }

                ns_log Notice "$end_time_lst / $end_time / $start_time"

                set start_time $hour
                append return_html "<td valign=top bgcolor=white rowspan=[expr $end_time - $start_time + 1]><font size=-1>[lindex $one_item_val 2]</font></td>"
            } else {
                append return_html "[ns_set value $calendar_details $index]<br>\n"
            }

            ns_set delete $calendar_details $index
        }

        append return_html "</tr>\n"
    }

    append return_html "</table></td></tr></table>"
    
    return $return_html
}
