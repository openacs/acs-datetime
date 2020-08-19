ad_library {
    Automated tests.

    @author Simon Carstensen
    @author Héctor Romojaro <hector.romojaro@gmail.com>
    @creation-date 16 Nov 2003
    @cvs-id $Id$
}

aa_register_case \
    -procs {dt_valid_time_p} \
    -cats {api production_safe} \
    dt_valid_time_p {
    Test dt_valid_time_p proc.
} {
    #
    # Valid time
    #
    set valid_time_p [dt_valid_time_p "13:00"]
    aa_true "Time is valid" $valid_time_p
    #
    # Invalid time
    #
    set valid_time_p [dt_valid_time_p ":"]
    aa_false "Time is valid" $valid_time_p
}

aa_register_case \
    -procs {dt_ansi_to_julian_single_arg} \
    -cats {api production_safe} \
    dt_ansi_to_julian_single_arg {
    Test dt_ansi_to_julian_single_arg proc.
} {
    #
    # Valid julian date
    #
    set date [dt_ansi_to_julian_single_arg "2003-01-01 01:01:01"]
    aa_equals "Returns correct julian date" $date "2452641"
}

aa_register_case \
    -procs {dt_ansi_to_julian} \
    -cats {api production_safe} \
    dt_ansi_to_julian {
    Test dt_ansi_to_julian proc.
} {
    #
    # Valid julian date
    #
    set date [dt_ansi_to_julian "2003" "01" "01"]
    aa_equals "Returns correct julian date" $date "2452641"
}

aa_register_case \
    -procs {dt_julian_to_ansi} \
    -cats {api production_safe} \
    dt_julian_to_ansi {
    Test dt_julian_to_ansi proc.
} {
    #
    # Valid ansi date
    #
    set date [dt_julian_to_ansi "2452641"]
    aa_equals "Returns correct ansi date" $date "2003-01-01"
}

aa_register_case \
    -procs {dt_ansi_to_list} \
    -cats {api production_safe} \
    dt_ansi_to_list {
    Test dt_ansi_to_list proc.
} {
    #
    # Valid ansi date
    #
    set list [dt_ansi_to_list "2003-01-01 01:01:01"]
    aa_equals "Returns correct ansi date" $list {2003 1 1 1 1 1}
}

aa_register_case \
    -procs {dt_num_days_in_month} \
    -cats {api production_safe} \
    dt_num_days_in_month {
    Test dt_num_days_in_month proc.
} {
    #
    # Test all months of 2003
    #
    set year 2003
    set month_days {1 31 2 28 3 31 4 30 5 31 6 30 7 31 8 31 9 30 10 31 11 30 12 31}
    dict for {month days} $month_days {
        aa_equals "Number of days in month $month is $days" "[dt_num_days_in_month $year $month]" "$days"
    }
}

aa_register_case -procs {
        dt_sysdate
        dt_systime
    } -cats {
        api
        production_safe
    } dt_sysdate_systime {
        Test dt_sysdate and dt_systime procs.
} {
    #
    # Test if the format is correct
    #
    aa_true "Current system date looks like a valid date" [dt_valid_time_p [dt_sysdate]]
    aa_true "Current system time looks like a valid time" [dt_valid_time_p [dt_systime]]
    aa_true "Current system time (GMT) looks like a valid time" [dt_valid_time_p [dt_systime -gmt true]]
}

aa_register_case -procs {
        dt_prev_month
        dt_next_month
    } -cats {
        api
        production_safe
    } dt_prev_next_month {
        Test dt_next_month and dt_prev_month procs.
} {
    set month 8
    set year 2020
    #
    # Ansi date for previous month
    #
    set month_prev {01 12 02 01 03 02 04 03 05 04 06 05 07 06 08 07 09 08 10 09 11 10 12 11}
    dict for {month prev} $month_prev {
        if {$month == 01} {
            aa_equals "Previous month to $month" "[dt_prev_month $year $month]" "[expr {$year -1}]-$prev-01"
        } else {
            aa_equals "Previous month to $month" "[dt_prev_month $year $month]" "$year-$prev-01"
        }
    }
    #
    # Ansi date for next month
    #
    set month_next {01 02 02 03 03 04 04 05 05 06 06 07 07 08 08 09 09 10 10 11 11 12 12 01}
    dict for {month next} $month_next {
        if {$month == 12} {
            aa_equals "Next month to $month" "[dt_next_month $year $month]" "[expr {$year + 1}]-$next-01"
        } else {
            aa_equals "Next month to $month" "[dt_next_month $year $month]" "$year-$next-01"
        }
    }
}

aa_register_case -procs {
        dt_interval_check
    } -cats {
        api
        production_safe
    } dt_interval_check {
        Test dt_interval_check proc.
} {
    #
    # Start of the interval is after the end
    #
    set start "2020-08-20"
    set end "2020-08-19"
    aa_true "Start > End"   "[expr {[dt_interval_check $start $end] < 0}]"
    #
    # Start of the interval is before the end
    #
    set end "2020-08-21"
    aa_true "Start < End"   "[expr {[dt_interval_check $start $end] > 0}]"
    #
    # Start and end of the interval are equal
    #
    set end "2020-08-20"
    aa_equals "Start = End" "[dt_interval_check $start $end]" "0"
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
