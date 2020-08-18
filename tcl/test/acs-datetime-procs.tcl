ad_library {
    Automated tests.

    @author Simon Carstensen
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

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
