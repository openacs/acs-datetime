# /packages/acs-datetime/tcl/acs-datetime-procs.tcl

ad_library {

    Tcl library for the ACS Date-Time service package

    @author  ron@arsdigita.com
    @created 2000-11-21
    @cvs-id  $Id$
}

ad_proc dt_systime {
    {-format "%Y-%m-%d %H:%M:%S" -gmt f}
} {
    Returns current server time in the standard format "yyyy-mm-dd
    hh:mi:ss".  With the optional -gmt flag it returns the time in
    GMT. 
} {
    return [clock format [clock seconds] -format $format -gmt $gmt]
}
    
ad_proc dt_sysdate {
    {-format "%Y-%m-%d"}
} {
    Returns current server date in the standard format "yyyy-mm-dd"
} {
    return [clock format [clock seconds] -format $format]
}

ad_proc dt_valid_time_p { 
    time 
} {
    Returns 1 if "time" is a valid time specification, 0 otherwise.
} {
    if [catch { clock scan $time }] {
	return 0
    } else {
	return 1
    }
}

ad_proc dt_format {
    {-format "%Y-%m-%d %H:%M:%S" -gmt f}
    time
} {
    return [clock format [clock scan $time] -format $format -gmt $gmt]
}

ad_proc dt_month_names {} {
    Returns the calendar month names as a Tcl list (January, February, ...)
} {
    set month_names [list]
    
    for {set i 1} {$i <= 12} {incr i} {
	lappend month_names [clock format [clock scan "2000-$i-1"] -format "%B"]
    }

    return $month_names
}

ad_proc dt_month_abbrev {} {
    Returns the calendar month names as a Tcl list (Jan, Feb, ...)
} {
    set month_names [list]
    
    for {set i 1} {$i <= 12} {incr i} {
	lappend month_names [clock format [clock scan "2000-$i-1"] -format "%b"]
    }

    return $month_names
}

ad_proc dt_julian_to_ansi {
    julian_date
} {
    Returns julian_date formatted as "yyyy-mm-dd"
} {
    return [db_string julian_to_ansi "
    select to_char(to_date(:julian_date,'J'),'yyyy-mm-dd') from dual"]
}

    
ad_proc dt_ansi_to_pretty {
    {ansi_date ""}
} {
    Converts 1998-09-05 to September 5, 1998.  With no argument it
    returns the current date based on server time.  Works for both
    date and date-time strings.
} {
    if [empty_string_p $ansi_date] {
	set ansi_date [dt_sysdate]
    }

    set date [clock scan $ansi_date]
    set day  [clock format $date -format "%e"]

    return [clock format $date -format "%B [string trim $day], %Y"]
}

ad_proc dt_ansi_to_list {
    {ansi_date ""}
} {
    Parses the given ansi_date string into a list of year, month, day,
    hour, minute, and second. Works for any date than can be parsed
    by clock scan. 
} {
    if [empty_string_p $ansi_date] {
	set ansi_date [dt_systime]
    }

    foreach item [split [clock format [clock scan $ansi_date] -format "%Y %m %d %H %M %S"] " "] { 
	lappend date_info [dt_trim_leading_zeros $item]
    }
    
    return $date_info
}

ad_proc -public dt_widget_datetime { 
    {-show_date 1 -date_time_sep "&nbsp;" -use_am_pm 0 -default none}
    {name}
    {granularity days}
} {

    Returns an HTML form fragment for collecting date-time
    information with names "$name.year", "$name.month", "$name.day",
    "$name.hours", "$name.minutes", "$name.seconds", and "$name.ampm".
    These will be numeric ("ampm" is 0 for am, 1 for pm) 

    Default specifies what should be set as the current time in the
    form. Valid defaults are "none", "now", or any valid date string
    that can be converted with clock scan.

    Granularity can be "months" "days" "hours" "halves" "quarters"
    "fives" "minutes" or "seconds".

    Use -show_date 0 for a time entry widget (no dates).

    All HTML widgets will be output *unless* show_date is 0; they will
    be hidden if not needed to satisfy the current granularity
    level. Values default to 1 for MM/DD and 0 for HH/MI/SS/AM if not 
    found in the input string or if below the granularity threshold.
} {
    set to_precision [dt_precision $granularity]

    set show_day     [expr $to_precision < 1441]
    set show_hours   [expr $to_precision < 61]
    set show_minutes [expr $to_precision < 60]
    set show_seconds [expr $to_precision < 1]

    if {$to_precision == 0} { 
	set to_precision 1 
    }

    switch $default {
	none    { set value [dt_systime] }
	now     { set value [dt_systime] }
	default { set value [dt_format $default] }
    }

    set parsed_date [dt_ansi_to_list $value]
    set year        [lindex $parsed_date 0]
    set month       [lindex $parsed_date 1]
    set day         [lindex $parsed_date 2]
    set hours       [lindex $parsed_date 3]
    set minutes     [lindex $parsed_date 4]
    set seconds     [lindex $parsed_date 5]

    # Kludge to get minutes rounded.  Should make general-purpose for
    # the other values too...

    if {$to_precision < 60} {
        set minutes [expr [dt_round_to_precision $minutes $to_precision] % 60]
    }

    if {$default == "none"} {
        set year    ""
        set month   ""
        set day     ""
        set hours   ""
        set minutes ""
        set seconds ""
    }

    if {$show_date} {
        append input [dt_widget_month_names "$name.month" $month]
        append input [dt_widget_maybe_range $show_day "$name.day" 1 31 $day 1 0 1]
        append input "<input name=\"$name.year\" size=5 maxlength=4 value=\"$year\"> $date_time_sep "
    }

    if {$use_am_pm} {
        if { $hours > 12 } {
            append input [dt_widget_maybe_range \
		    $show_hours "$name.hours" 1 12 [expr {$hours - 12}] 1 0]
        } elseif {$hours == 0} {
            append input [dt_widget_maybe_range \
		    $show_hours "$name.hours" 1 12 12 1 0]
        } else {
            append input [dt_widget_maybe_range \
		    $show_hours "$name.hours" 1 12 $hours 1 0]
        }
    } else {
        append input [dt_widget_maybe_range \
		$show_hours "$name.hours" 0 23 $hours 1 0]
    }

    if {$show_minutes} { 
	append input ":" 
    }

    append input [dt_widget_maybe_range \
	    $show_minutes "$name.minutes" 0 59 $minutes $to_precision 1]

    if {$show_seconds} { 
	append input ":" 
    }

    append input [dt_widget_maybe_range \
	    $show_seconds "$name.seconds" 0 59 $seconds 1 1]

    if {$use_am_pm} {
        if {$hours < 12 || ! $show_hours} {
            set am_selected " selected"
            set pm_selected ""
        } else {
            set am_selected ""
            set pm_selected " selected"
        }

        append input "
        <select name=\"${name}.ampm\">
        <option value=0${am_selected}>AM
        <option value=1${pm_selected}>PM
        </select>"
    } else {
        append input [dt_export_value "${name}.ampm" "AM"]
    }

    return $input
}

ad_proc dt_widget_month_names { 
    name 
    {default ""}
} {
    Returns a select widget for months of the year. 
} {
    set month_names [dt_month_names]
    set default     [expr $default-1]
    set input       "<option value=_undef>---------"

    for {set i 0} {$i < 12} {incr i} {
	append input "<option [expr {$i == $default ? "selected" : ""}] value=[expr $i+1]>[lindex $month_names $i]\n"
    }
    
    return "<select name=\"$name\">\n $input \n </select>\n"
}

ad_proc dt_widget_numeric_range { 
    name 
    begin 
    end 
    {default ""} 
    {interval 1} 
    {with_leading_zeros 0}
} {
    Returns an HTML select widget for a numeric range
} {
    if $with_leading_zeros {
	set format "%02d"
    } else {
	set format "%d"
    }

    if ![empty_string_p $default] {
	set default [dt_trim_leading_zeros $default]
    }

    set input "<option value=_undef>--\n"

    for { set i $begin } { $i <= $end } { incr i $interval} {
	append input "[expr {$i == $default ? "<option selected>" : "<option>"}][format $format $i]\n"
    }

    return "<select name=\"$name\">\n$input</select>"
}

ad_proc dt_widget_maybe_range {
    {-hide t -hidden_value "00" -default "" -format "%02d"}
    ask_for_value 
    name 
    start
    end
    default_value 
    {interval 1 } 
    {with_leading_zeros 0} 
    {hidden_value "00"}
} {
    Returns form numeric range, or hidden_value if ask_for_value is false.
} {
    if !$ask_for_value {
        # Note that this flattens to hidden_value for hidden fields
        if $with_leading_zeros {
            return [dt_export_value $name $hidden_value]
        } else {
            return [dt_export_value $name [dt_trim_leading_zeros $hidden_value]]
        }
    }

    return [dt_widget_numeric_range \
	    "$name" $start $end $default_value $interval $with_leading_zeros]
}

ad_proc dt_interval_check { start end } {

    Checks the values of start and end to see if they form a valid
    time interval.  Returns:

    > 0  if end > start
      0  if end = start
    < 0  if end < start

    Input variables can be any strings that can be converted to times
    using clock scan.
} {
    return [expr [clock scan $end]-[clock scan $start]]
}

ad_proc -private dt_trim_leading_zeros { 
    string 
} {
    Returns a string w/ leading zeros trimmed.
    Used to get around TCL interpreter problems w/ thinking leading
    zeros are octal. We could just use validate_integer, but it runs
    one extra regexp that we don't need to run. 
} {
    set string [string trimleft $string 0]

    if [empty_string_p $string] {
        return "0"
    }

    return $string
}

ad_proc -private dt_export_value { 
    name 
    value 
} {
    Makes a hidden form item w/ given name and value
} {
    return "<input name=\"$name\" type=hidden value=\"$value\">"
}

ad_proc -private dt_round_to_precision { 
    number 
    precision 
} {

    Rounds the given number to the given precision,
    i.e. <tt>calendar_round_to_precision 44 5</tt> will round to the
    nearest 5 and return 45, while <tt>calendar_round_to_precision
    32.678 .1</tt> will round to 32.7.

} {
    return [expr $precision * round(double($number)/$precision)]
}

ad_proc -private dt_precision {
    granularity
} {
    Returns the precision in minutes corresponding to a named
    granularity 
} {
    switch -exact $granularity {
	months   { set precision 40000}
	days     { set precision 1440}
	hours    { set precision 60}
	halves   { set precision 30}
	quarters { set precision 15}
	fives    { set precision 5}
	minutes  { set precision 1}
	seconds  { set precision 0}
	default  { set precision 15}
    }

    return $precision
}

