%% readNDBCadcp2.m
function [Z,U,V,W,Err,GD,EI,CM]=readNDBCadcp2(stationID,year)
%
%   Function that downloads directly ocean current adcp (expanded format) data 
%   from NOAA/NDBC stations and converts them to east and north flow components.
%
%   [z,u,v]=readNDBCadcp(stationID,year)
%
%% Inputs
% stationID = the NOAA/NDBC Station ID as appears on their homesite(e.g., 41001)
% year      = year data are required for (e.g., 2015)
% plt       = 1 if a plot is required (default no plot)
%
%% Outputs
% time      = Time in MATLAB format
% Z         = The distance from the sea surface to the middle of the depth cells (m)
% U         = [time, East flow component (m/s)
% V         = North flow component (m/s)
%
%% Uses
% readNDBCfile.m
%
%% Copyright 2021, George Voulgaris, University of South Carolina
%
% This file is part of matNOOA-NDBC.
%
% matNOAA-NDBC is free software: you can redistribute it and/or modify
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
[ADCDname, errID]=readNDBCfile(stationID,year,'a','adcp2');
%% Case ADCP data - Expanded format
if errID==1
    DELIM=' ';  % Delimiter between values
    NHEAD=2;    % No of headers
    adcpdata = importdata(ADCPname,DELIM,NHEAD); % structure the data are saved in
    time     = datenum([adcpdata.data(:,1:5),adcpdata.data(:,1)*0]); % Time in matlab format
    % #YY  MM DD hh mm I Bin   Depth Dir Speed ErrVl VerVl %Good3 %Good4 %GoodE   EI1   EI2   EI3   EI4   CM1   CM2   CM3   CM4 Flags
    % #yr  mo dy hr mn -   -     m  degT  cm/s  cm/s  cm/s      %      %      %     -     -     -     -     -     -     -     - -
    % 2014 09 11 17 46 1   1    69.4 117  63.2  -0.7  -1.2      0    100      0   171   166   177   170   234   231   233   230 393333330
    % 2014 09 11 17 46 1   2   101.4 122  63.1  -1.0  -3.7      0    100      0   147   145   154   150   236   236   235   237 393333330
    % 2014 09 11 17 46 1   3   133.4 120  54.1   4.2  -3.4      0    100      0   142   134   142   140   225   238   236   238 393333330
    I   = adcp2data.data(:,6);         % Instrument No (in case more than 1 ADCPs)
    bin = adcp2data.data(:,7);         % Bin No
    z   = adcp2data.data(:,8);         % Depth below sea surface (m)
    Dir = adcpdata2.data(:,9);         % Direction in degs
    Uz  = adcpdata2.data(:,10)/100;    % Horizontal Current Speed (m/s)
    u   = Uz.*sind(Dir);               % East current component
    v   = Uz.*cosd(Dir);               % North current component
    w   = adcpdata2.data(:,12)/100;    % Verical Current velocity (m/s)
    Bins=max(bin);
    for i=1:Bins
        Z(i,:)=z(bin==i);
        U(i,:)=u(bin==i);
        V(i,:)=v(bin==i);
        W(i,:)=w(bin==i);% Error Velocity (m/s)
        Err(i,:,:)=adcpdata2.data(:,11)/100;
        GD(i,:,:)=adcpdata2.data(bin==i,13:15);     % Percentage of 3-beam, 4-beam good and transformations rejected
        EI(i,:,:)=adcpdata2.data(bin==i,16:19)*0.44; % Acoustic Intensity per beam (in dB)
        CM(i,:,:)=adcpdata2.data(bin==i,20:23);  % 0-255 Correlation magnitude
    end
else
    time=[]; Z=[];  U=[];  V=[];  W=[];
    I=[];  Err=[]; GD=[]; EI=[]; CM=[];
    disp('No data were found')
end
end