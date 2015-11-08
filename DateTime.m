classdef DateTime < handle
    
    % precision indicator
    properties(Access = 'public',Constant)            
        PRECISION = 3;
    end
    
    % class fields
    properties(Access = 'public')                     
        year       = nan;
        doy        = nan;
        
        month      = nan;
        day        = nan;
        
        gpsWeek    = nan;
        gpsWeekDay = nan;
        
        mjd        = nan;
        serialDate = nan;
        
        hour       = nan;
        minute     = nan;
        
        soh        = nan;
        sod        = nan;
        sow        = nan;
    end
    
    % two-stage constructors
    methods(Static)                                   
        
        % two-stage factory constructor
        function dt = initWithMJD(mjd)                
            
            % enforce function signature
            if nargin ~= 1 
                error('usage: DateTime.initWithMJD(mjd)');
            end
            
            % mem alloc
            dt = DateTime.empty(0,numel(mjd));
            
            % compute dt(i) for each mjd(i)
            for i = 1:numel(mjd)
                
                % convert the MJD to year month day
                [y,m,d] = DateTime.mjd2date(floor(mjd(i)));

                % convert calendar date to doy
                ddd = DateTime.date2doy(y,m,d);

                % compute the second of day
                sss = (mjd(i) - floor(mjd(i)))*86400;

                % create new datetime object
                dt(i) = DateTime(y,ddd,sss);
            end
        end
        
        % two-stage factory constructor
        function dt = initWithSerialDate(sd)          
            
            % enforce function signature
            if nargin ~= 1 
                error('usage: DateTime.initWithSerialDate(sd)');
            end
            
            % mem alloc
            dt = DateTime.empty(0,numel(sd));
            
            % compute dt(i) for each mjd(i)
            for i = 1:numel(sd); dt(i) = DateTime(sd(i)); end
        end
        
        % two-stage factory constructor
        function dt = initWithFyear(fyear)            
            
            % enforce function signature
            if nargin ~= 1; error('usage: DateTime.initWithFyear(fyear)'); end
            
            % enforce input argument type
            if ~ isa(fyear,'double'); error('arg1 must be array of doubles'); end
            
            % mem alloc DateTime obj for each fyear
            dt = DateTime.empty(0,numel(fyear));
            
            % compute the integer year 
            yyyy = floor(fyear);
            
            % init number of days in year, leap years have 366 days
            ndays = ones(size(fyear))*365; ndays(rem(yyyy,4)==0) = 366;
            
            % compute the fractional day of year
            ddd = ( (fyear-yyyy) .* ndays ) + 1;
            
            % compute the second of day
            sss = ( ddd - floor(ddd) ) .* 86400;
            
            % compute integer day of year
            ddd = floor(ddd);
            
            % init DateTime object for each fyear
            for i = 1:numel(fyear); dt(i) = DateTime(yyyy(i),ddd(i),sss(i)); end
        end
    end
    
    % time deltas/intervals
    methods (Static, Access = 'public')               
        function delta = ONE_SEC  (); delta = 1       ; end
        function delta = ONE_MIN  (); delta = 60      ; end
        function delta = ONE_HOUR (); delta = 3600    ; end
        function delta = ONE_DAY  (); delta = 86400   ; end
        function delta = ONE_WEEK (); delta = 604800  ; end
        function delta = ONE_MONTH(); delta = 2592000 ; end
        function delta = ONE_YEAR (); delta = 31536000; end
    end
    
    % DateTimeLib
    methods(Static, Access = 'protected')             
        
        function secs                    = yds2sec(year,doy,sod)            
            
            y = (year-year(1))*86400*365.25;
            d = (doy - doy(1))*86400       ;            
            s = (sod - floor(sod(1)))      ;
            
            % compute the ellpased seconds from start
            secs = y + d + s               ;
        end
        
        function [hour, minute, second]  = sod2hms    (sod)                 
            
            % compute the hour, minute, and second 
            hour   = floor(    sod/3600    );
            minute = floor(rem(sod,3600)/60);
            second = rem  (rem(sod,3600),60);
        end
       
        function sod                     = hms2sod    (h,m,s)               
            sod = s + m * 60 + h * 60 * 60;
        end
        
        function doy                     = date2doy   (yyyy,mm,day)         

            if nargin ~= 3
                error('USAGE: doy = date2doy(yyyy,mm,day)')
            end

            %create date number
            dn = datenum(yyyy,mm,day);

            % create data vector from date number
            dv = datevec(dn);

            % window date vector
            dv(:,2:end) = 0;

            % simple calculation ...
            doy = dn - datenum(dv);

        end
        
        function mjd                     = gpsDate2mjd(gpsWeek,gpsWeekDay)  
            mjd = (gpsWeek * 7) + 44244 + gpsWeekDay;
        end

        function [year,month,day]        = mjd2date    (mjd)                

            %   Author:      Peter J. Acklam
            %   Time-stamp:  2002-05-24 15:24:45 +0200
            %   E-mail:      pjacklam@online.no
            %   URL:         http://home.online.no/~pjacklam


            if nargin ~= 1
                error('USAGE:  [year,month,day] = mjd2date(mjd)');
            end

            jd  = mjd + 2400000.5;
            ijd = floor(jd + 0.5);

            a = ijd + 32044;
            b = floor((4 * a + 3) / 146097);
            c = a - floor((b * 146097) / 4);

            d = floor((4 * c + 3) / 1461);
            e = c - floor((1461 * d) / 4);
            m = floor((5 * e + 2) / 153);

            day   = e - floor((153 * m + 2) / 5) + 1;
            month = m + 3 - 12 * floor(m / 10);
            year  = b * 100 + d - 4800 + floor(m / 10);

        end
        
        function [month,day]             = doy2date    (year,doy)           
 
            if nargin ~= 2
                error('USAGE:  [month,day] = doy2date(year,doy)')
            end

            if year < 1900 || year > 2100
                error(['Invalid year!!! year = ',num2str(year)])
            end

            isLeapYear = false;
            if rem(year,4) == 0
                isLeapYear = true;
            end

            if isLeapYear
                fday = [1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336];
                lday = [31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366];
            else
                fday = [1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335,];
                lday = [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];
            end

            month = find(doy <= lday,1);
            if isempty(month)
               month = 12;
            end
            day   = doy - fday(month) +1;
        end
 
        function [gpsWeek, gpsWeekDay]   = date2gpsDate(year,month,day)     

            if month <= 2
                month = month + 12;
                year  = year - 1;
            end

            ut  = rem(day,1)*24;
            day = floor(day);

            julianDay = floor( 365.25 * year )             ...
                        + floor( 30.6001 * ( month + 1 ) ) ...
                        + day                              ...
                        + ut/24                            ...
                        + 1720981.5;

            gpsWeek    = floor((julianDay - 2444244.5)/7);
            gpsWeekDay = mod(  (julianDay - 2444244.5),7);

        end
        
        function dt                      = truncate    (dt,n)               
        
            % check input arge
            if nargin < 1
                error('USAGE: t = truncate(t,n) ');
            end
            
            % default 3 decimal places
            if nargin == 1
                n = 3;
            end
            
            % round to 5 decimal places
            f = 10.^n;
            
            % truncate the serial date numbers
            dt = round(dt .* f) ./ f;

        end
        
        function dt                      = hardTruncate(dt)                 
            % check input arge
            if nargin < 1; error('USAGE: t = truncate(t,n) ');end
            
            % convert to string
            s = num2str(dt);
            
            indx = strfind(s,'.')+3;
            
            if isempty(indx); return; end
            
            indx = min( numel(s), indx );
            
            % take up to n digits after decimal
            dt = str2double( s(1:indx) );
        end
    end
    
    % base constructor
    methods(Access = 'public')                        
        
        % Constructor
        function this = DateTime(varargin)            
            
            % check for subclass instanciation
            if numel(varargin) == 1 && isa(varargin{1},'cell')
                varargin = varargin{1};
            end
            
            % check for two stage init
            if numel(varargin) == 0; return; end
            
            % make sure have 2 or 3 input arguments
            if numel(varargin) > 3
                error('must provide 1, 2, or 3 input args')
            end
            
            if numel(varargin) == 1
                
                % get initial date time info
                this.serialDate = varargin{1};
                
                % compute ymd + hms from serial date
                [this.year, this.month, this.day,                   ...
                    this.hour, this.minute, this.soh]               ...
                        = datevec(this.serialDate);
                    
                % truncate the seconds of hour
                this.soh = DateTime.truncate(this.soh,this.PRECISION);
                    
                % now compute the GPS date information
                [this.gpsWeek, this.gpsWeekDay]                     ...
                    = DateTime                                   ...
                        .date2gpsDate(this.year,this.month,this.day);
                    
                % comput the modified julian day from gps date
                this.mjd                                            ...
                    = DateTime                                   ...
                        .gpsDate2mjd(this.gpsWeek, this.gpsWeekDay);
                
                % finally, compute the day of year 
                this.doy                                            ... 
                    = DateTime                                   ...
                        .date2doy(this.year, this.month, this.day);
                    
                % compute the second of day from hour minute second
                this.sod = this.hour*3600 + this.minute*60 + this.soh;
                
                % truncate the seconds of day
                this.sod = DateTime.truncate(this.sod,this.PRECISION);
                    
                % compute the second of week
                this.sow = (this.gpsWeekDay * 86400) + this.sod;
           
                % truncate the seconds of week
                this.sow = DateTime.truncate(this.sow,this.PRECISION);
                
            % check for gpsWeek and gpsSow
            elseif numel(varargin) == 2
                
                % get the initial date time info gpsWeek and second of week
                this.gpsWeek = varargin{1};
                this.sow     = varargin{2};
                
                % adjust for out of range sow
                this.gpsWeek = this.gpsWeek + floor(this.sow/DateTime.ONE_WEEK);
                this.sow     = mod(this.sow,DateTime.ONE_WEEK);
                
                % truncate the seconds of week
                this.sow = DateTime.truncate(this.sow,this.PRECISION);
                
                % compute the gpsWeekDay
                this.gpsWeekDay = floor(this.sow/86400);
                
                % now compute the second of day
                this.sod = rem(this.sow,86400);
                
                % truncate the seconds of day
                this.sod = DateTime.truncate(this.sod,this.PRECISION);
                
                % compute the hour, min, sec from second of day
                [this.hour, this.minute, this.soh]                  ...
                    = DateTime                                   ...
                        .sod2hms(this.sod);                      
                
                % truncate the seconds of hour
                this.soh = DateTime.truncate(this.soh,this.PRECISION);
                    
                % compute the modified julian day 
                this.mjd                                            ...
                    = DateTime                                   ...
                        .gpsDate2mjd(this.gpsWeek, this.gpsWeekDay);
                
                % OK, now compute year, month, day from mjd
                [this.year, this.month, this.day]                   ...
                    = DateTime                                   ...
                        .mjd2date(this.mjd);
                    
                % compute serial date from ymd + hms
                this.serialDate                                     ...
                    = datenum(                                      ...
                              this.year, this.month,  this.day,     ...
                              this.hour, this.minute, this.soh      ...
                             );
                         
                % finally, compute the day of year 
                this.doy                                            ... 
                    = DateTime                                   ...
                        .date2doy(this.year, this.month, this.day);
            
            elseif numel(varargin) == 3
                
                % extract the initial date time information
                this.year = varargin{1};
                this.doy  = varargin{2};
                this.sod  = varargin{3};
                
                % truncate the seconds of day
                this.sod = DateTime.truncate(this.sod,this.PRECISION);
                
                % compute the hour, min, sec from second of day
                [this.hour, this.minute, this.soh]                  ...
                    = DateTime                                   ...
                        .sod2hms(this.sod);
                    
                % truncate the seconds of hour
                this.soh = DateTime.truncate(this.soh,this.PRECISION);
                    
                % compute the month and day from year and doy                   
                [this.month, this.day]                              ...
                    = DateTime                                   ...
                        .doy2date(this.year,this.doy);
                    
                % now compute the serial date from ymd + hms
                this.serialDate                                     ...
                    = datenum(                                      ...
                              this.year, this.month,  this.day,     ...
                              this.hour, this.minute, this.soh      ...
                             );
                         
                % now compute the GPS date information
                [this.gpsWeek, this.gpsWeekDay]                     ...
                    = DateTime                                   ...
                        .date2gpsDate(this.year,this.month,this.day);
                    
                % comput the modified julian day from gps date
                this.mjd                                            ...
                    = DateTime                                   ...
                        .gpsDate2mjd(this.gpsWeek, this.gpsWeekDay);
                    
                % finally compute the second of week
                this.sow = (this.gpsWeekDay * 86400) + this.sod;
                
                % truncate the seconds of week
                this.sow = DateTime.truncate(this.sow,this.PRECISION);
            end
        end
    end
    
    % helper functions
    methods (Access = 'public')                       
        
        % helper function
        function fd = fmjd(this)                      
            fd = [this.mjd] + [this.sod]/86400;
        end
        
        % helper function
        function fy = fyear(this)                     
            
            % get year, day of year, and second of day
            yyyy = [this.year]; ddd = [this.doy]; sss = [this.sod];
            
            % init number of days in year, leap years have 366 days
            ndays = ones(size(yyyy)).*365; ndays(rem(yyyy,4)==0) = 366;
            
            % compute fractional year 
            fy = yyyy + ( (ddd-1) + sss./86400 ) ./ ndays;
        end
        
        % helper function
        function fd = fjd(this)                       
            fd = this.fmjd + 2400000.5;
        end
    end
    
    % operator overloads
    methods (Access = 'public')                       
        
        % @Overload
        function newDateTime = plus(this,rhs)         
            
            % type check
            if ~isa(rhs,'double'); error('Must add num seconds to DateTime'); end

            % create new DateTime 
            newDateTime = DateTime.initWithSerialDate([this.serialDate] + rhs/86400);
        end
        
        % @Overload
        function result = minus(this,rhs)             
            
            % type check
            if isa(rhs,'double')
                result = DateTime.initWithSerialDate([this.serialDate] - rhs/86400);
            elseif isa(rhs,'DateTime')
                result = DateTime.truncate(([this.serialDate] - rhs.serialDate)*86400,DateTime.PRECISION);
            else
                error('must subtract length of time (time delta in seconds) or another date time');
            end
        end
        
        % @Overload
        function bool = eq(this,otherDate)            
            
            if ~ isa(otherDate,'DateTime'); error('can only compare DateTime objects'); end
            
            % Note that 0.001/86400 = 1.15740e-8
            bool = abs([this.serialDate] - [otherDate.serialDate]) <= 1.1574e-8;
        end
        
        % @Overload
        function bool = ne(this,otherDate)            
            
            if ~ isa(otherDate,'DateTime')
                error('can only compare DateTime objects');
            end
            
            bool = [this.serialDate] ~= [otherDate.serialDate];
        end
        
        % @Overload
        function bool = le(this,otherDate)            
            
            if ~ isa(otherDate,'DateTime')
                error('can only compare DateTime objects');
            end
            
            bool = [this.serialDate] <= [otherDate.serialDate];
        end
        
        % @Overload
        function bool = ge(this,otherDate)            
            
            if ~ isa(otherDate,'DateTime')
                error('can only compare DateTime objects');
            end
            
            bool = [this.serialDate] >= [otherDate.serialDate];
        end
        
        % @Overload
        function bool = lt(this,otherDate)            
            
            if ~ isa(otherDate,'DateTime')
                error('can only compare DateTime objects');
            end
            
            bool = [this.serialDate] < [otherDate.serialDate];
        end
        
        % @Overload
        function bool = gt(this,otherDate)            
            
            if ~ isa(otherDate,'DateTime')
                error('can only compare DateTime objects');
            end
            
            bool = [this.serialDate] > [otherDate.serialDate];
        end
        
        % @Overload
        function dt   = colon(a,d,b)                  
            
            if nargin == 3
                
                % type check first and third input
                if ~isa(a,'DateTime') || ~isa(b,'DateTime')
                    error('start and stop must be DateTime objects')
                end
                
                % build on the back of serial dates (watch for round off!)
                serialDates = a.serialDate:d/86400:b.serialDate;
                
            elseif nargin == 2
                
                % instead type check first and second input
                if ~isa(a,'DateTime') || ~isa(d,'DateTime')
                    error('start and stop must be DateTime objects')
                end
                
                % expand the dates
                serialDates = a.serialDate:1/86400:d.serialDate;
            end
            
            % mem alloc
            dt = DateTime.empty(0,numel(serialDates));
            
            % init each date
            for i = 1:numel(serialDates)
                dt(i) = DateTime(serialDates(i)); 
            end
            
        end
        
        function m    = max(this)                     
            
            % get index of largest date
            indx = [this.serialDate] == max([this.serialDate]);
            
            % return largest date
            m = this(indx);
        end
        
        function m    = min(this)                     
                        
            % get index of largest date
            indx = [this.serialDate] == min([this.serialDate]);
            
            % return largest date
            m = this(indx);
        end
        
        function dt   = sort(this)                    
            
            % sort the values
            [~,sortIndx] = sort([this.serialDate]);   
            
            % return sorted date time objects
            dt = this(sortIndx);
        end
        
        function dt = datetime(this)                  
            dt = datetime([this.serialDate],'ConvertFrom','datenum');
        end
        
        function dt = datevec(this)                   
            dt = datevec([this.serialDate]);
        end
        
        function dt = unique(this)                    
            [~,ix] = unique([this.serialDate]);  dt = this(ix);
        end
    end
    
    % time delta functions
    methods (Access = 'public')                       
        
       function days = elapsedDaysSince   (this,otherDate) 
            
             if ~ isa(otherDate,'DateTime')
                error('can only compute DateTime objects');
             end
            
             days = [this.serialDate] - [otherDate.serialDate];
            
        end
        
       function secs = elapsedSecondsSince(this,otherDate) 
            
            if ~ isa(otherDate,'DateTime')
                error('can only compute DateTime objects');
            end
            
            % compute days elapsed
            days = this.elapsedDays(otherDate);
            
            % convert to seconds
            secs = days * 86400;
       end 
       
    end
    
    % string functions
    methods (Access = 'public')                       
        
        function str   = doystr  (this)
            
            % mem alloc
            str = repmat(' ',numel(this),3);
            
            for i = 1:numel(this)
                
                % init the string for day of year
                tmp = num2str(this(i).doy);

                % pad with zeros
                str(i,:) = [repmat('0',1,max(0,3-numel(tmp))),tmp];
            end
            
            % only single string ?
            if numel(this)>1; str = cellstr(str); end
            
        end
        
        function str   = sodstr  (this)
            
            % mem alloc 
            str = repmat(' ',numel(this),5);
            
            % for each object
            for i = 1:numel(this)
                
                % init str representation
                tmp = num2str(floor(this(i).sod));
                
                % pad with zeros
                str(i,:) = [repmat('0',1,max(0,5-numel(tmp))),tmp];
            end
            
            % convert to cell array if array of objects
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = timestr (this)
            str = datestr([this.serialDate], 'HH:MM:SS.FFF');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = datestr (this,fmt)
            str = datestr([this.serialDate], fmt);
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = str     (this)
            str = datestr([this.serialDate], 'dd/mm/yyyy HH:MM:SS.FFF');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = gpsstr  (this)
            % mem alloc 
            str = repmat(' ',numel(this),5);
            
            % for each object
            for i = 1:numel(this)
                
                % init str representation
                tmp = [num2str(this(i).gpsWeek),num2str(this(i).gpsWeekDay)];
                
                % pad with zeros
                str(i,:) = [repmat('0',1,max(0,5-numel(tmp))),tmp];
            end
            
            % convert to cell array if array of objects
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = d       (this)
            str = datestr([this.serialDate], 'd');
            if size(str,1) > 1; str = cellstr(str); end
        end
        
        function str   = dd      (this)
            str = datestr([this.serialDate], 'dd');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = ddd     (this)
            str = datestr([this.serialDate], 'ddd');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = dddd    (this)
            str = datestr([this.serialDate], 'dddd');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = mm      (this)
            str = datestr([this.serialDate], 'mm');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = mmm     (this)
            str = datestr([this.serialDate], 'mmm');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = mmmm    (this)
            str = datestr([this.serialDate], 'mmmm');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = yy      (this)
            str = datestr([this.serialDate], 'yy');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = yyyy    (this)
            str = datestr([this.serialDate], 'yyyy');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = HH      (this)
            str = datestr([this.serialDate], 'HH');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = MM      (this)
            str = datestr([this.serialDate], 'MM');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = SS      (this)
            str = datestr([this.serialDate], 'SS');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = FFF     (this)
            str = datestr([this.serialDate], 'FFF');
            if numel(this)>1; str = cellstr(str); end
        end
        
        function str   = QQ      (this)
            str = datestr([this.serialDate], 'QQ');
            if numel(this)>1; str = cellstr(str); end
        end
    end
end