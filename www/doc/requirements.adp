
<property name="context">{/doc/acs-datetime {ACS Date and Time Utilities}} {ACS DateTime}</property>
<property name="doc(title)">ACS DateTime</property>
<master>
<h2>ACS DateTime Requirements</h2>

by <a href="mailto:ron\@arsdigita.com">Ron Henderson</a>
<h3>I. Introduction</h3>
<p>This document describes the requirements for the ACS DateTime
service package.</p>
<h3>II. Vision Statement</h3>
<p>ACS DateTime has the following primary functions:</p>
<ul>
<li>Allows applications to use a common set of procedures for
collecting date and time information from users.</li><li>Provides utilities to convert and format date and time
information.</li><li>Provides customizable form fragment widgets of varying degrees
of temporal granularity through which applications can collect date
and time information.</li><li>Provides customizable calendar display widgets that allow
applications to hook calendar information into a flexible display
mechanism.</li>
</ul>
<p>Note that most of this functionality has existed within the ACS
for a long time, but it has been spread over a combination of ACS
and module libraries. The ACS DateTime service packages brings
these procedures into a common framework and provides for a more
consistent use of formatting conventions.</p>
<p>Note that these procedures do not make any specific reference to
timezone information and do not provide for conversion between
timezones. This is left up to the application programmer. For
information on timezone conversions see the ACS Reference service
package and specifically the timezone reference pack therein.</p>
<h3>III. System/Application Overview</h3>
<p>This service packages consists of a set of Tcl widget libraries
and other procedures for processing date and time information.
These libraries are roughly separated into date-time and calendar
procedures.</p>
<h3>IV. Use-cases and User-Scenarios</h3>
<p>This package is only used as a procedural library for
applications.</p>
<h3>V. Related Links</h3>
<p>None.</p>
<h3>VI. Requirements</h3>
<h4>Date and Time functions</h4>
<ol>
<li>Generate current system time (local or GMT)</li><li>Generate current system date</li><li>Format a calendar time (system-dependent representation of
time) using the formatting codes supported by the standard Unix
time functions</li><li>Generate a list of standard month names</li><li>Generate a list of standard month abbreviations</li><li>Convert Julian time to ANSI time (yyyy-mm-dd)</li><li>Convert ANSI time to "pretty ANSI time" (yyyy-mm-dd
to Month day, year)</li><li>Generate a Tcl list of date-time elements (year, month, day,
hour, minute, second)</li><li>Check the validity of a time interval by comparing start and
end times and determining if they represent a positive, empty, or
negative time range</li>
</ol>
<h4>Date and Time widgets</h4>
<ol>
<li>Generate HTML select widgets for collecting date and time
information from users with varying granularity. Granularity should
be optional and specified in units of seconds, minutes, fives (five
minute intervals), quarters (fifteen minute intervals), halves
(thirty minute intervals), hours, days, or months</li><li>Generate an HTML select widget for months of the year</li><li>Generate an HTML select widget for general numeric ranges</li>
</ol>
<h4>Calendar widgets</h4>
<p>All of the following allow the programmer to supply calendar
details in an <code>ns_set</code> keyed on Julian date, and return
an HTML table.</p>
<ol>
<li>Generate a basic monthly calendar</li><li>Generate a small monthly calendar</li><li>Generate small monthly calendars centered in a given month
(previous, current, next)</li><li>Generate a yearly calendar (composed of small montly calendars)
given the starting month as a date</li><li>Generate a yearly calendar based on calendar year (Jan to Dec),
given any date within that calendar year</li><li>Generate a calendar navigation widget with viewing options for
day, week, month and year</li>
</ol>
<hr>

ron\@arsdigita.com
