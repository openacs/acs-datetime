
<property name="context">{/doc/acs-datetime/ {ACS Date and Time Utilities}} {ACS DateTime}</property>
<property name="doc(title)">ACS DateTime</property>
<master>
<h2>ACS DateTime</h2>

by Ron Henderson
<h3>I. Essentials</h3>
<p>This document describes the design of the ACS DateTime service
package.</p>
<h3>II. Introduction</h3>
<p>The ACS DateTime service is a collection of HTML widget
generation procedures and date/time processing functions. The
latter are built largely on top of the Tcl <code>clock</code>
routines, although there are a small number of procedures that
connect to the database for services like Julian date
conversions.</p>
<p>Most the procedures defined within the ACS DateTime service take
date/time information as input and return date/time strings to the
caller. Rather than standardize on a low-level representation of
time (like seconds since 00:00:00 UTC, January 1 1970) all of these
procedures accept general date specifications. Internally dates are
parsed by the standard Tcl procedure <code>clock scan</code> for
processing and then converted back to a formatted string for
output. This makes it easy to pass dates between the Tcl layer and
the database.</p>
<h3>III. Historical Considerations</h3>
<p>This package was written largely to consolidate and improve the
date, time, and calendar functionality existing in ACS 3.</p>
<h3>IV. Competitive Analysis</h3>
<p>None.</p>
<h3>VI. Data Model Discussion</h3>
<p>The ACS DateTime package does not have a data model.</p>
<h3>VII. Legal Transactions</h3>
<p>None.</p>
<h3>VIII. API</h3>
<h4>Date and Time functions</h4>
<p>See <a href="examples/datetime-procs">examples</a>.</p>
<ol>
<li>
<code>dt_systime</code> generates current system time (local or
GMT)</li><li>
<code>dt_sysdate</code> generates current system date</li><li>
<code>dt_format</code> formats a time using the formatting
codes supported by the standard Unix time functions</li><li>
<code>dt_month_names</code> generates a list of standard month
names</li><li>
<code>dt_month_abbrev</code> generates a list of standard month
abbreviations</li><li>
<code>dt_julian_to_ansi</code> converts Julian time to ANSI
time (yyyy-mm-dd)</li><li>
<code>dt_ansi_to_pretty</code> converts ANSI time to
"pretty ANSI time" (yyyy-mm-dd to Month day, year)</li><li>
<code>dt_ansi_to_list</code> generates a Tcl list of date-time
elements (year, month, day, hour, minute, second)</li><li>
<code>dt_valid_time_p</code> checks the validity of a time
specification</li><li>
<code>dt_interval_check</code> checks the validity of a time
interval by comparing start and end times and determining if they
represent a positive, empty, or negative time range</li>
</ol>
<h3>XII. Future Improvements/Areas of Likely Change</h3>
<p>Many of the calendar widgets generate extensive HTML from within
Tcl procedures. This will eventually be converted to a
template-based system so that the display properties are more
easily customized.</p>
<h3>XIII. Authors</h3>
<p>Implemented by Ron Henderson (<a href="mailto:ron\@arsdigita.com">ron\@arsdigita.com</a>), based on the
previous work of <a href="mailto:gregh\@arsdigita.com">gregh\@arsdigita.com</a> and <a href="mailto:smeeks\@arsdigita.com">smeeks\@arsdigita.com</a>.</p>
<hr>
<a href="mailto:ron\@arsdigita.com">ron\@arsdigita.com</a>
