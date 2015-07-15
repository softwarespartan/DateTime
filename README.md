
<html><body><div class="content"><h1>DateTime Object Tutorial</h1><p>DateTime objects provide a transparent way to handle different <i>representations</i> of date/time information and facilitate transfer between time standards such as UTC and TAI.</p><h2>Contents</h2><div><ul><li><a href="#1">Initializing DateTime Objects</a></li><li><a href="#8">DateTime Arithmetic and Comparisons</a></li><li><a href="#14">The Colon Operator</a></li><li><a href="#19">String Functions</a></li><li><a href="#24">Working with Arrays of DateTime Objects</a></li><li><a href="#31">Helper Functions</a></li><li><a href="#38">Possible Issues</a></li><li><a href="#40">Advanced Examples</a></li></ul></div><h2>Initializing DateTime Objects<a name="1"></a></h2><p>There are various ways to initialize a date time objects such as using the YEAR, DOY, and SOD constructor where "DOY" stands for day of year, and "SOD" stands for seconds of day</p><pre class="codeinput">DateTime(1980,7,43200)
</pre><pre class="codeoutput">
ans = 

  DateTime with properties:

     PRECISION: 3
          year: 1980
           doy: 7
         month: 1
           day: 7
       gpsWeek: 0
    gpsWeekDay: 1
           mjd: 44245
    serialDate: 723187.5
          hour: 12
        minute: 0
           soh: 0
           sod: 43200
           sow: 129600

</pre><p>Notice that the DateTime object has precomputed many different time representations.  The table below gives a description for each DateTime property:</p><p>
<table border=1>
<tr><td>Property</td><td>Description</td></tr>
<tr><td>PRECISION</td><td>This value indicates millisecond precision</td></tr>
<tr><td>year</td><td>Calendar year</td></tr>
<tr><td>month</td><td>Calendar month of year (range: 1 - 12)</td></tr>
<tr><td>day</td><td>Calendar day of month (range: 1 - 31)</td></tr>
<tr><td>gpsWeek</td><td>Number of weeks since Jan 6, 1980</td></tr>
<tr><td>gpsWeekDay</td><td>The day of gpsWeek (range: 0 - 6)</td></tr>
<tr><td>mjd</td><td>Modified Julian date (MJD)</td></tr>
<tr><td>serialDate</td><td>Matlab linear datenum referenced to Jan 1, 0000</td></tr>
<tr><td>hour</td><td>Hour of Day (range: 0 - 23)</td></tr>
<tr><td>minute</td><td>Minute of hour (range: 0 - 59)</td></tr>
<tr><td>soh</td><td>Second of hour (range: 0 - 59)</td></tr>
<tr><td>sod</td><td>Second of day (range: 0 - 86399)</td></tr>
<tr><td>sow</td><td>Second of gpsWeek (range: 0 - 604799)</td></tr>
</table>
</p><p>There are a few helper functions which act like properties</p><p>
<table border=1>
<tr><td>Meta-Property</td><td>Description</td><td>Example</td></tr>
<tr><td>fyear</td><td>Fraction of year where one day is 1/366 for leap years and 1/365 otherwise</td><td>2015.283483</td></tr>
<tr><td>fmjd</td><td>Fraction of modified julian day</td><td>57694.7584309</td></tr>
<tr><td>fjd</td><td>Fraction of julian day</td><td>2455920.5489322</td></tr>
</table>
</p><p>Likewise the table below outlines the various DateTime constructors:</p><p>
<table border=1>
<tr><td>Constructor</td><td>Description</td></tr>
<tr><td>DateTime(YYYY,DOY,SOD)</td><td>Useful in many operational settings since DOY is linear for the year and SOD is linear for the day</td></tr>
<tr><td>DateTime(GPSWeek,SOW)</td><td>Used to initialize date time objects associated with GPS/IGS related information</td></tr>
<tr><td>DateTime(datenum)</td><td>Used to create DateTime objects from Matlab serial date numbers (e.g. datenum, datevec, datestr)</td></tr>
<tr><td>DateTime()</td><td>Empty constructor initializes all properties to NaN for use with second stage constructor (see below)</td></tr>
</table>
</p><p>Note that these constructors initialize only a single DateTime object at once.  Use two-stage constructors to initialize vectors of DateTime objects.</p><p>Since overloading the constructor can get sloppy, two-stage constructors are used to make object initialization more transparent:</p><p>
<table border=1>
<tr><td>Second Stage Constructor</td><td>Description</td></tr>
<tr><td>DateTime.initWithMJD(mjd)</td><td>Many occasions data files use fMJD to specify observation epochs. Note, if input MJD arg is 1xN then output is 1xN array of DateTime objects</td></tr>
<tr><td>DateTime.initWithSerialDate(dn)</td><td>Use datestr to convert date strings to serial date numbers and then use this constructor to convert to array of DateTime objects</td></tr>
<tr><td>DateTime.initWithFyear(fy)</td><td>Use fractional year to initialize DateTime object.  Note that one day is 1/366 for leap years and 1/365 otherwise.</td>
</table>
</p><p><b>Example 1</b>: initialize DateTime for current time</p><pre class="codeinput">dt = DateTime(now)
</pre><pre class="codeoutput">
dt = 

  DateTime with properties:

     PRECISION: 3
          year: 2015
           doy: 195
         month: 7
           day: 14
       gpsWeek: 1853
    gpsWeekDay: 2
           mjd: 57217
    serialDate: 736159.948896852
          hour: 22
        minute: 46
           soh: 24.688
           sod: 81984.688
           sow: 254784.688

</pre><p><b>Example 2</b>: initialize DateTime objects for array of modified julian dates and extract the day of year and second of day</p><pre class="codeinput">mjd = [56215.5, 56216.6, 56217.7];

dt = DateTime.initWithMJD(mjd);

sod = [dt.sod]
</pre><pre class="codeoutput">
sod =

       43200       51840       60480

</pre><p><b>Example 3</b>: initialize DateTime objects from timestamps and extract GPS date and time.  Notice here that DateTime() objects interoperate with existing MATLAB datenum. Here time stamps are in a common calendar format and can be easily converted to serial date number</p><pre class="codeinput">timestamps = {<span class="string">'2012/05/23 15:56:30'</span>, <span class="string">'2012/05/23 15:57:00'</span>, <span class="string">'2012/05/23 15:57:30'</span>}

dn = datenum(timestamps,<span class="string">'YYYY/mm/dd HH:MM:SS'</span>)

dt = DateTime.initWithSerialDate(dn)

gpsWeek = [dt.gpsWeek]

gpsSOW = [dt.sow]
</pre><pre class="codeoutput">
timestamps = 

    '2012/05/23 15:56:30'    '2012/05/23 15:57:00'    '2012/05/23 15:57:30'


dn =

          735012.664236111
          735012.664583333
          735012.664930556


dt = 

  1x3 DateTime array with properties:

    PRECISION
    year
    doy
    month
    day
    gpsWeek
    gpsWeekDay
    mjd
    serialDate
    hour
    minute
    soh
    sod
    sow


gpsWeek =

        1689        1689        1689


gpsSOW =

      316590      316620      316650

</pre><h2>DateTime Arithmetic and Comparisons<a name="8"></a></h2><p>All of the usual operators such as +,-, &lt;, &gt;= etc have been overloaded for DateTime objects. Since DateTime objects keep an internally normalized version of the epoch, comparison operators are particularly useful for comparing date and time information with differing representations.  For example comparing GPS date information with MJD. Similarly, arithmetic operators make it easy to work in seconds of week and then convert to seconds of day or seconds of hour.</p><p>To facilitate a variety of use cases there are predefined lengths of time (time delta) summarized below</p><p>
<table border=1>
<tr><td>Time Delta</td><td>Description</td></tr>
<tr><td>DateTime.ONE_SEC</td><td>All DateTime arithmetic is computed with time deltas in units of one second</td></tr>
<tr><td>DateTime.ONE_MIN</td><td> 60 seconds = 60 * DateTime.ONE_SEC</td></tr>
<tr><td>DateTime.ONE_HOUR</td><td>3600 seconds = 60 minutes </td>
<tr><td>DateTime.ONE_DAY</td><td>86400 seconds = 24 hours</td>
<tr><td>DateTime.ONE_WEEK</td><td> 604800 = 7 days</td>
<tr><td>DateTime.ONE_MONTH</td><td>2592000 seconds = 30 days </td>
<tr><td>DateTime.ONE_YEAR</td><td>31536000 seconds = 365 days </td>
</table>
</p><p>Note that the + operator is only defined for double and returns a new date time incremented rhs many seconds (dt + rhs).  However, the minus operator, -, is defined for both double and DateTime such that the subtraction of two DateTime objects returns a time delta (in seconds) while subtraction of a double returns a new DateTime object decremented by rhs many seconds (dt - rhs).</p><p><b>Example 0</b>: Basic arithmetic and comparisons</p><pre class="codeinput">dt = DateTime(2014,278,67467);

<span class="comment">% compare equals</span>
dt == dt

<span class="comment">% less than</span>
dt &lt; dt + 1

<span class="comment">% greater than</span>
dt &gt; dt - DateTime.ONE_HOUR
</pre><pre class="codeoutput">
ans =

     1


ans =

     1


ans =

     1

</pre><p>DateTime comparisons operators (&lt;, &gt;, ==, &lt;=, &gt;=) only consider time deltas larger than 1 millisecond.</p><pre class="codeinput">dt == dt + 0.000001
</pre><pre class="codeoutput">
ans =

     1

</pre><p><b>Example 1</b>: Equality comparison of two dates with different representations</p><pre class="codeinput"><span class="comment">% init obj with modified julian date</span>
dt1 = DateTime.initWithMJD(56785.8349);

<span class="comment">% init with GPS week and second of week</span>
dt2 = DateTime(1791,417735.36);

<span class="comment">% equivalence regardless of representation ...</span>
dt1 == dt2
</pre><pre class="codeoutput">
ans =

     1

</pre><p><b>Example 2</b>: DateTime object can also be used in a a control flow loop accumulating a time delta.</p><pre class="codeinput"><span class="comment">% init with year, day of year, and second of day</span>
dt = DateTime(2012,144,57390);

<span class="comment">% init stop</span>
dt_stop = dt + DateTime.ONE_DAY;

<span class="comment">% loop until dt_stop</span>
<span class="keyword">while</span> dt &lt;= dt_stop
    % do stuff ...

    % update date time by 30 seconds
    dt = dt + 30 * DateTime.ONE_SEC;
<span class="keyword">end</span>
</pre><p><b>Example 3</b>: Loop until some time delta is acheived.  Note that the subtraction of two DateTime objects returns a time delta (in seconds).</p><pre class="codeinput"><span class="comment">% init with fraction of year</span>
dt_start = DateTime.initWithFyear(2013.47839890);

<span class="comment">% init loop var at start time</span>
dt = dt_start;

<span class="keyword">while</span> dt - dt_start &lt;= DateTime.ONE_HOUR
    % do stuff ...

    % increment dt by 30 seconds
    dt = dt + 30 * DateTime.ONE_SEC;
<span class="keyword">end</span>
</pre><h2>The Colon Operator<a name="14"></a></h2><p>Using DateTime arithmetic and time deltas, arrays of DateTime objects with uniform time step can be initialized using the : operator.</p><p><b>Example 0</b>: initialize array of DateTime objects with 30 second time step</p><pre class="codeinput"><span class="comment">% init with year, doy, and second of day</span>
a = DateTime(2014,293,43200);
b = a + DateTime.ONE_DAY;

<span class="comment">% create DateTime objects with a 30 second interval</span>
a : 30 * DateTime.ONE_SEC : b
</pre><pre class="codeoutput">
ans = 

  1x2881 DateTime array with properties:

    PRECISION
    year
    doy
    month
    day
    gpsWeek
    gpsWeekDay
    mjd
    serialDate
    hour
    minute
    soh
    sod
    sow

</pre><p>Or, create date time objects for each hour of a day</p><pre class="codeinput"><span class="comment">% init with gps week and gps second of week</span>
dt = DateTime(1678,487377);

<span class="comment">% create array of DateTime objects with time step of one hour</span>
dt : DateTime.ONE_HOUR : dt + DateTime.ONE_DAY
</pre><pre class="codeoutput">
ans = 

  1x25 DateTime array with properties:

    PRECISION
    year
    doy
    month
    day
    gpsWeek
    gpsWeekDay
    mjd
    serialDate
    hour
    minute
    soh
    sod
    sow

</pre><p>Finally, create DateTime objects for each day of a year</p><pre class="codeinput"><span class="comment">% init with GPS week and GPS second of week</span>
dt = DateTime(1778,43200);

<span class="comment">% create DateTime object array with time delta of 3.5 days</span>
dt : 3.5 * DateTime.ONE_DAY : dt + DateTime.ONE_YEAR
</pre><pre class="codeoutput">
ans = 

  1x105 DateTime array with properties:

    PRECISION
    year
    doy
    month
    day
    gpsWeek
    gpsWeekDay
    mjd
    serialDate
    hour
    minute
    soh
    sod
    sow

</pre><p>Note that if no time step is defined, a default time delta of one second is used</p><pre class="codeinput">a:a+10
</pre><pre class="codeoutput">
ans = 

  1x11 DateTime array with properties:

    PRECISION
    year
    doy
    month
    day
    gpsWeek
    gpsWeekDay
    mjd
    serialDate
    hour
    minute
    soh
    sod
    sow

</pre><h2>String Functions<a name="19"></a></h2><p>There are various string functions to facilitate date and time formatting similar to MATLAB built-in function datestr.</p><p>
<table cellspacing="0" class="body" cellpadding="4" border="2">
<thead>
    <tr valign="top"><th><p>String Function</p></th><th><p>Description</p></th><th><p>Example</p></th></tr>
</thead>
<tbody>
<tr><td>str</td><td>Default string representation with format dd/mm/yyyy HH:MM:SS.FFF </td><td>02/02/2014 12:00:00.000</td></tr>
<tr><td>timestr</td><td>Default time (only) string with format HH:MM:SS.FFF</td><td>20:02:15.360</td></tr>
<tr><td>datestr(format)</td><td>Shortcut for generating custom format string</td><td>dt.datestr('yyyy-QQ')</td></tr>
<tr><td>doystr</td><td>Day of year in three digits</td><td>005, 067, 295</td></tr>
<tr><td>sodstr</td><td>Second of day in five digits</td><td>00049, 07783, 72189</td></tr>
<tr><td>yyyy</td><td>Year in four digits</td><td>1990, 2002</td></tr>
<tr><td>yy</td><td>Year in two digits</td><td>90, 02</td></tr>
<tr><td>QQ</td><td>Quarter year using letter Q and onedigit</td><td>Q1</td></tr>
<tr><td>mmmm</td><td>Month using full name</td><td>March, December</td></tr>
<tr><td>mmm</td><td>Month using first three letters</td><td>Mar, Dec</td></tr>
<tr><td>mm</td><td>Month in two digits</td><td>03, 12</td></tr>
<tr><td>m</td><td>Month using capitalized first letter</td><td>M, D</td></tr>
<tr><td>dddd</td><td>Day using full name</td><td>Monday, Tuesday</td></tr>
<tr><td>ddd</td><td>Day using first three letters</td><td>Mon, Tue</td></tr>
<tr><td>dd</td><td>Day in two digits</td><td>05, 20</td></tr>
<tr><td>d</td><td>Day using capitalized first letter</td><td>M, T</td></tr>
<tr><td>HH</td><td>Hour in two digits </td><td>05, 12</td></tr>
<tr><td>MM</td><td>Minute in two digits</td><td>12, 02</td></tr>
<tr><td>SS</td><td>Second in two digits</td><td>07, 59</td></tr>
<tr><td>FFF</td><td>Millisecond in three digits</td><td>057</td></tr>
</tbody>
</table>
</p><p><b>Example 0</b>: Simple usage of string format functions</p><pre class="codeinput">fprintf(<span class="string">'%s %s %s\n'</span>, dt.yyyy,  dt.doystr,  dt.sodstr)
</pre><pre class="codeoutput">2014 033 43200
</pre><p><b>Example 1</b>: Noisy time tag</p><pre class="codeinput">[dt.dddd,<span class="string">'_'</span>,dt.mmmm,<span class="string">'_'</span>,dt.dd,<span class="string">'_'</span>,dt.yyyy]
</pre><pre class="codeoutput">
ans =

Sunday_February_02_2014

</pre><p><b>Example 2</b>: Noisy time tag using shortcut to Matlab built-in datestr function</p><pre class="codeinput">dt.datestr(<span class="string">'dddd_mmmm_dd_yyyy'</span>)
</pre><pre class="codeoutput">
ans =

Sunday_February_02_2014

</pre><p><b>Example 3</b>: Noisy time tag using Matlab built-in datestr directly</p><pre class="codeinput">datestr(dt.serialDate,<span class="string">'dddd_mmmm_dd_yyyy'</span>)
</pre><pre class="codeoutput">
ans =

Sunday_February_02_2014

</pre><h2>Working with Arrays of DateTime Objects<a name="24"></a></h2><p>When working with a data set it is not unusual to have an array of DateTime objects.  These arrays of DateTime objects work just like normal vectors in MATLAB.</p><p>For example, suppose x = [1 2 3 4]; then x + 1 = [2 3 4 5] where each element of the vector has been incremented by 1.  Vectors of DateTime objects work in a similar fashion.  Such operations are typical of transforming an array of DateTime objects from one time reference system to another, say GPS to TAI.</p><p><b>Example 0</b>: Convert array of DateTime objects from GPS to UTC to TAI time.</p><pre class="codeinput"><span class="comment">% define number of seconds between UTC and GPS time reference systems</span>
leapsecs = 36;

<span class="comment">% define an array of DateTime objects using reference information in GPS time</span>
dtGPS = DateTime(1668,0):DateTime.ONE_DAY:DateTime(1669,0);

<span class="comment">% view the year, day of year, and second of day</span>
GPS = dtGPS.str

<span class="comment">% convert from GPS time reference system to UTC</span>
dtUTC = dtGPS  - leapsecs + 19;

<span class="comment">% notice how DateTime objects semelessly handle year and day boundaries</span>
UTC = dtUTC.str

<span class="comment">% finally, convert UTC to TAI</span>
dtTAI = dtUTC + leapsecs;

<span class="comment">% have a look</span>
TAI = dtTAI.str
</pre><pre class="codeoutput">
GPS = 

    '25/12/2011 00:00:00.000'
    '26/12/2011 00:00:00.000'
    '27/12/2011 00:00:00.000'
    '28/12/2011 00:00:00.000'
    '29/12/2011 00:00:00.000'
    '30/12/2011 00:00:00.000'
    '31/12/2011 00:00:00.000'
    '01/01/2012 00:00:00.000'


UTC = 

    '24/12/2011 23:59:43.000'
    '25/12/2011 23:59:43.000'
    '26/12/2011 23:59:43.000'
    '27/12/2011 23:59:43.000'
    '28/12/2011 23:59:43.000'
    '29/12/2011 23:59:43.000'
    '30/12/2011 23:59:43.000'
    '31/12/2011 23:59:43.000'


TAI = 

    '25/12/2011 00:00:19.000'
    '26/12/2011 00:00:19.000'
    '27/12/2011 00:00:19.000'
    '28/12/2011 00:00:19.000'
    '29/12/2011 00:00:19.000'
    '30/12/2011 00:00:19.000'
    '31/12/2011 00:00:19.000'
    '01/01/2012 00:00:19.000'

</pre><p>In the last example a string function was called for an array of DateTime objects which return a cell array, one result for each DateTime object.</p><pre class="codeinput">class(TAI)
</pre><pre class="codeoutput">
ans =

cell

</pre><p>But on the other hand, if working with a 1x1 "scalar" DateTime object string functions return type char.</p><pre class="codeinput">class(dtGPS(1).str)
</pre><pre class="codeoutput">
ans =

char

</pre><p>Finally, when working with arrays of DateTime objects, need to use square brackets when accessing object properties</p><pre class="codeinput">doyArray = [dtGPS.doy]

size(doyArray)
</pre><pre class="codeoutput">
doyArray =

   359   360   361   362   363   364   365     1


ans =

     1     8

</pre><p>If the square brackets are not used, Matlab will return a single ans, one for each object.  Matlab calls this behavior "comma seperated lists".</p><pre class="codeinput"><span class="comment">% dont forget square brackets!!</span>
doyArray = dtGPS.doy;

<span class="comment">% oi vey ... only got a single result</span>
doyArray
</pre><pre class="codeoutput">
doyArray =

   359

</pre><p><b>Example 1</b>: Another common operation to to compute elapsed seconds from a particular reference epoch.</p><pre class="codeinput"><span class="comment">% define a reference epoch</span>
refEpoch = DateTime(1980,1,0);

<span class="comment">% compute elapsed seconds from reference epoch</span>
elapsedSeconds = dtGPS - refEpoch
</pre><pre class="codeoutput">
elapsedSeconds =

  Columns 1 through 3

                1009238400                1009324800                1009411200

  Columns 4 through 6

                1009497600                1009584000                1009670400

  Columns 7 through 8

                1009756800                1009843200

</pre><h2>Helper Functions<a name="31"></a></h2><p>There are a few helper functions worth mentioning here.  Often with working with a data set we need to get the time span of the data.  This can be accomplished with the min and max functions</p><p><b>Example 0</b>: Compute the timespan of an array of DateTime objects in days using DateTime min and max functions</p><pre class="codeinput">timespan = (dtGPS.max - dtGPS.min) / DateTime.ONE_DAY
</pre><pre class="codeoutput">
timespan =

     7

</pre><p>In a perhaps more idiomatic fashion</p><pre class="codeinput">timespan = (max(dtGPS) - min(dtGPS)) / DateTime.ONE_DAY
</pre><pre class="codeoutput">
timespan =

     7

</pre><p><b>Example 1</b>: Likewise, arrays of DateTime objects can be sorted using the sort function</p><pre class="codeinput"><span class="comment">% create random permutation index</span>
ix = randperm(numel(dtGPS));

<span class="comment">% shuffle the array</span>
dtShuffle = dtGPS(ix);

<span class="comment">% have a look</span>
doyShuffled = [dtShuffle.doy]

<span class="comment">% sort the array</span>
dtSorted = dtGPS.sort;

<span class="comment">% have another look at sorted result</span>
doySorted = [dtSorted.doy]
</pre><pre class="codeoutput">
doyShuffled =

     1   360   363   364   359   365   361   362


doySorted =

   359   360   361   362   363   364   365     1

</pre><p>Both datetime and datevec have been added to facilitate iteroperability with other Matlab functionality <b>Example 2</b>: plot data with datetime axis</p><pre class="codeinput"><span class="comment">% define an array of DateTime objects using GPS time representation</span>
dt = DateTime(1668,0):DateTime.ONE_DAY:DateTime(1670,0);

<span class="comment">% define some y data</span>
ydat = rand(size(dt));

<span class="comment">% plot data with datetime axis lables using Matlab's built-in datetime objects</span>
plot(dt.datetime, ydat);
</pre><img vspace="5" hspace="5" src="DateTimeTutorial_01.png" alt=""> <p><b>Example 3</b>: Get date vectors for each DateTime object</p><pre class="codeinput">dv = dtUTC.datevec

<span class="comment">% check the size</span>
size(dv)
</pre><pre class="codeoutput">
dv =

        2011          12          24          23          59          43
        2011          12          25          23          59          43
        2011          12          26          23          59          43
        2011          12          27          23          59          43
        2011          12          28          23          59          43
        2011          12          29          23          59          43
        2011          12          30          23          59          43
        2011          12          31          23          59          43


ans =

     8     6

</pre><p><b>Example 4</b>: Getting index of unique DateTime objects in an array</p><pre class="codeinput"><span class="comment">% create vector with duplicate DateTime objects</span>
dt = [dtGPS, dtGPS];

<span class="comment">% extract unique DateTime</span>
dtu = dt.unique;

<span class="comment">% locate first unique DateTime</span>
indx = dt == dtu(2)
</pre><pre class="codeoutput">
indx =

  Columns 1 through 13

     0     1     0     0     0     0     0     0     0     1     0     0     0

  Columns 14 through 16

     0     0     0

</pre><h2>Possible Issues<a name="38"></a></h2><p><b>Example 0</b>: It is important to keep in mind 3 digits of percision when comparing DateTime objects "small" differences</p><pre class="codeinput"><span class="comment">% create two DateTime objects with sub-millisecond difference</span>
dt1 = DateTime(2015,13,43200.111111);
dt2 = DateTime(2015,13,43200.111555);

<span class="comment">% comparison of these DateTime objects will only consider down to millisecond when evaluating equality of DateTime objects.</span>
dt1 == dt2

<span class="comment">% but notice explicit comparison of dt1 and dt2 properties will return false since using equal for two doubles.</span>
dt1.sod == dt2.sod
</pre><pre class="codeoutput">
ans =

     1


ans =

     0

</pre><h2>Advanced Examples<a name="40"></a></h2><p>DateTime objects can out of range values during initialization</p><p><b>Example 0a</b>: negative day of year, and day of year zero simply roll over to previous year</p><pre class="codeinput">dt = [ DateTime(2015,-1,0), DateTime(2015,0,0), DateTime(2015,1,0)]; dt.str
</pre><pre class="codeoutput">
ans = 

    '30/12/2014 00:00:00.000'
    '31/12/2014 00:00:00.000'
    '01/01/2015 00:00:00.000'

</pre><p><b>Example 0b</b>: day of year overflow is properly accumulated in years.  This is day 101 of 2015</p><pre class="codeinput">dt = DateTime(2013,830,0) + DateTime.ONE_DAY;

wala = [dt.yyyy,<span class="string">' '</span>,dt.doystr]
</pre><pre class="codeoutput">
wala =

2015 101

</pre><p><b>Example 0c</b>: This is first second of GPS week 1678</p><pre class="codeinput">dt = DateTime(1678,0); dt.str
</pre><pre class="codeoutput">
ans =

04/03/2012 00:00:00.000

</pre><p>While this is the last second of GPS week 1677</p><pre class="codeinput">dt = DateTime(1678,-1); dt.str
</pre><pre class="codeoutput">
ans =

03/03/2012 23:59:59.000

</pre><p><b>Example 1</b>: Find the day of year of the 31st of every month</p><pre class="codeinput">dt = DateTime(2014,1,0):DateTime.ONE_DAY:DateTime(2015,0,0);
[dt([dt.day]==31).doy]
</pre><pre class="codeoutput">
ans =

    31    90   151   212   243   304   365

</pre><p><b>Example 2</b>: Compute the date of every Monday in 2008</p><pre class="codeinput">dt = DateTime(2008,1,0):DateTime.ONE_DAY:DateTime(2009,0,0);
dt_mon = dt(strcmp(dt.dddd,<span class="string">'Monday'</span>));
dt_mon(1:3).str
size(dt_mon)
</pre><pre class="codeoutput">
ans = 

    '07/01/2008 00:00:00.000'
    '14/01/2008 00:00:00.000'
    '21/01/2008 00:00:00.000'


ans =

     1    52

</pre><p>Notice here that the specification of the last day of 2008 as DateTime(2009,0,0) circumvents needing to know that 2008 isa leap year</p><p class="footer"><br><a href="http://www.mathworks.com/products/matlab/">Published with MATLAB&reg; R2015a</a><br></p></div>
</body></html>