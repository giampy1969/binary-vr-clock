function bvrclock(opt)

% Just type bvrclock at the command line to create and start
% this binary virtual reality clock. The function opens a window
% in a simple virtual world, where each of the 6 columns of
% appearing and disappearing golden balls is used to display
% the binary-coded value of each decimal digit of sexagesimal time.
% The highest position codes for a 2^3=8 and the lowest position
% codes for 2^0=1, therefore, for example, if a column has balls
% in positions #0 (the lowest one) and #1 (the medium-lower one)
% then the whole column represents a value of 2^0+2^1=1+2=3
% Additional explanation is available at this related wikipedia
% web site: http://en.wikipedia.org/wiki/Binary_clock
% Giampy 20-Dec-2008

% When called without arguments the function initializes the
% bclk structure (which contains the virtual world, the timer
% and the figure handle) and starts the clock.
% The timer then calls bvrclock(2) to update the positions
% of the balls each second. Closing the window automatically
% stops the clock and deletes the timer object

% create persistent structure
persistent bclk

if nargin < 1,  % startup

    % make sure version is at least 7
    vrs=version;
    if str2num(vrs([1 2]))<7, disp('Matlab version must be 7 or higher: exiting'), return, end

    % make sure java machine is running
    jvm=javachk('jvm');
    if size(jvm,1) > 0,
        if findstr(jvm.identifier,'NotAvailable'),
            disp('Java Machine is not running: exiting');
            return
        end
    end

    % check wether the virtual world file exists
    if ~exist('bvrclock.wrl'), disp('The file bvrclock.wrl is not in the path: exiting'), return, end

    % make sure virtual reality toolbox is installed
    if ~exist('vrworld'), disp('Virtual Reality toolbox is not installed: exiting'), return, end

    % initialize world
    bclk.world = vrworld('bvrclock.wrl');

    % prevents opening other figures
    if isfield(bclk,'fig'), return, end

    % open the world
    open(bclk.world)
    bclk.fig = view(bclk.world, '-internal');
    set(bclk.fig,'CameraDirection',[0 0.1 -0.9]);

    % set timer
    bclk.ht=timer;
    bclk.ht.TimerFcn='bvrclock(2)';
    bclk.ht.ExecutionMode='Fixedrate';
    bclk.ht.Period=1;

    % start timer
    start(bclk.ht);

    % set termination function
    set(bclk.fig,'DeleteFcn','bvrclock(9)');

elseif nargin == 1 & opt==2, % update

    % get time
    clk=clock;

    % form time string
    time=[num2str(fix(clk(4)/10)) num2str(mod(clk(4),10)) ':' num2str(fix(clk(5)/10)) num2str(mod(clk(5),10)) ':' num2str(fix(clk(6)/10)) num2str(fix(mod(clk(6),10)))];

    % set title
    set(bclk.fig,'Name',[' Binary VR Clock : ' date ' ' time]);

    % cycle trough hours, mins, secs and place balls
    for k=3:-1:1,

        % get bits for first column
        bits=dec2bin(fix(mod(clk(3+k),10)),4);

        % set first column
        for i=1:4,
            str=[ 'Ball-' num2str(k) '-01-0' num2str(2^(i-1))];  % form name of ball
            hball=vrnode(bclk.world,str);                % get ball handle
            hball.scale=0.5*[1 1 1]*str2num(bits(5-i));  % set ball scale
        end

        % get bits for second column
        bits=dec2bin(fix(clk(3+k)/10),4);

        % set second column
        for i=1:4,
            str=[ 'Ball-' num2str(k) '-10-0' num2str(2^(i-1))];  % form name of ball
            hball=vrnode(bclk.world,str);                % get ball handle
            hball.scale=0.5*[1 1 1]*str2num(bits(5-i));  % set ball scale
        end

    end

elseif nargin == 1 & opt==9,

    % stop and delete timer
    stop(bclk.ht);
    delete(bclk.ht);
    clear bclk;
    
else
    disp('Wrong number of arguments or incorrect option');
end

