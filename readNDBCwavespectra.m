%% readNDBCwavespectra.m
function [time,f,E,theta,EDir]=readNDBCwavespectra(stationID,year,plt)
%
%   [time,f,E,theta,EDir]=readNDBCdirw1(stationID,year, plt)
%
%   Function that downloads directly spectra wave data from NOAA/NDBC
%   buoy stations and creates the directional spectra if available.
%
%   [time,f,E,theta,EDir]=readNDBCdirw1; 
%   
%   It would run a demo for StationID 41001, year 2015)
%
%% Inputs
% stationID = the NOAA/NDBC Station ID as appears on (e.g., 41001)
% year      = year data are required for (e.g., 2015)
% plt       = 1 if a plot is required (default no plot)
%
%% Outputs
% time      = Time in MATLAB format
% f         = Frequency array (Hz)
% E         = Wave spectral energy (m2/Hz)
% theta     = Direction array (Degrees) - If directional data are available
% EDir      = Directional wave spectra (E(f,theta)) (m2/Hz/deg) - if directional data are available
%
%% Uses
% readNDBCfile.m
%
%% Copyright 2021, George Voulgaris, University of South Carolina
%
% This file is part of matNOOA-NDBC.
%
% matNOOA-NDBC is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
%
% If you find an error please notify G. Voulgaris at gvoulgaris@geol.sc.edu
%
if nargin<3
    plt=0;
end
% Run a demo
if nargin<2
    stationID=41001;
    year = 2015;
    plt=1;
end
%
%% Download and read spectral density data (wave spectra, 'w'-'swden')
%
[SWname, errID] = readNDBCfile(stationID,year,'w','swden');
if errID==1
    x  = importdata(SWname,' ',1);
    %%
    % Once the data are imported to our workspace then the parsing of the values
    % commence. The frequency values are part of the header line, starting after comumn
    % 5 (at column 6), so:
    f   =str2double(cellstr(x.textdata(1,6:end)));    % Frequency (Hz)
    % Columns 1 to 5 in the x.data contain the date information
    yyyy = x.data(:,1);    % Year
    mo   = x.data(:,2);    % month
    dd   = x.data(:,3);    % Day
    hh   = x.data(:,4);    % hour
    mi   = x.data(:,5);    % minute
    time = datenum(yyyy,mo,dd,hh,mi,mi*0);   % Converting time to MATLAB format
    %% the remaining columns contain the spectral energy values for each frequency bin:
    E         = x.data(:,6:end);   % Spectral Energy Density (m2/Hz)
    E(E==999) = NaN;               % Identify bad data
    if plt==1
        %%  Plotting results as Frequency and Direction time-stack plots
        figure
        subplot(211)
        pcolor(time,f,E')   % Energy vs fr
        title('Wave Energy vs Frequency')
        ylabel('Frequency (Hz)')
        shading flat
        datetick('x','mm-dd','keeplimits')
        c = colorbar;
        c.Label.String = 'E(f) (m^2/Hz)';
        hold on
    end
else
    disp('No file was found')
    time=[]; f=[]; E=[]; theta=[]; EDir=[];
    return
end
%% Check if there is Directional Information 
%
%% For the ALPHA1 values ('d', 'swdir')
[ALPHA1name, errIDA1]=readNDBCfile(stationID,year,'d','swdir');
if errIDA1==1
    x1  = importdata(ALPHA1name,' ',1);
    A1  = x1.data(:,6:end);
    %% For the ALPHA2 values ('i', 'swdir2')
    [ALPHA2name,~]=readNDBCfile(stationID,year,'i','swdir2');
    x2  = importdata(ALPHA2name,' ',1);
    A2  = x2.data(:,6:end);       % A2 values
    %% For the R1 values ('j', 'swr1')
    [R1name, ~]=readNDBCfile(stationID,year,'j','swr1');
    x3  = importdata(R1name,' ',1);
    R1  = x3.data(:,6:end)*0.01;  % R1 Values
    %% For the R2 values ('k', 'swr2')
    [R2name, ~]=readNDBCfile(stationID,year,'k','swr2');
    x4  = importdata(R2name,' ',1);
    R2  = x4.data(:,6:end)*0.01;  % R2 Values
    %% Combining all parameters from the five different files requires:|
    dtheta = 2;                      % Desired resolution of directional array (in degs)
    theta = -180:dtheta:180-dtheta;  % Defining the directions with the desired resolution (in degs)
    n=length(theta);
    [k,j]=size(A1);
    EDir(k,j,n)=NaN;                  % Directional spectrum array EDir(time,f,theta)
    for i=1:n %for each direction
        %EDir(:,:,i) = (dtheta/180)*(0.5+R1.*cosd(theta(i)-A1)+R2.*cosd(2*(theta(i)-A2))).*E;
        EDir(:,:,i) = (dtheta/180)*(0.5+(2/3)*R1.*cosd(theta(i)-A1)+(1/6)*R2.*cosd(2*(theta(i)-A2))).*E;
    end
    Ef     = squeeze(sum(EDir,3));
    Etheta = squeeze(sum(EDir,2));
    if plt==1
        %%  Plotting results as Frequency and Direction time-stack plots
%         figure
         subplot(211)
%         pcolor(time,f,Ef')   % Energy vs fr
%         shading interp
%         hold on
         plot(time,sum(Ef,2)/1200+0.2,'w.');
%         title('Wave Energy vs Frequency')
%         ylabel('Frequency (Hz)')
%         shading interp
%         datetick('x','mm-dd','keeplimits')
%         c = colorbar;
%         c.Label.String = 'E(f) (m^2/Hz)';
        %
        subplot(212)
        pcolor(time,theta,squeeze(sum(EDir,2))')   % Energy per direction
        shading flat
        hold on
        plot(time,sum(Etheta,2)-45,'w.');
        ylabel('Direction From (^oN)')
        xlabel('Time')
        title('Wave Energy vs Direction')
        datetick('x','mm-dd','keeplimits')
        c = colorbar;
        c.Label.String = 'E(\theta) (m^2/deg)';
    end
else
    disp('No Directional information is available')
    theta=[]; EDir=[];
end
end