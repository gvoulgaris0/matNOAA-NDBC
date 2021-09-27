%% readNOAATides.m
function fname=readNOAATides(StationID,StartDate,EndDate,TimeZone,datum,Units)

% fname=readNOAATides(StationID,StartDate,EndDate,TimeZone,datum,Units)
%
% Function that downloads and saves as a mat file the tidal elevations from
% a station. Uses the noaa API.
% For information on API generator see:
% https://tidesandcurrents.noaa.gov/api-helper/url-generator.html
% https://api.tidesandcurrents.noaa.gov/api/prod/
%
%% Inputs
% StationID  : The tidal station ID
% StartDate  : Start of time series in format YYYYMMDD
% EndDate    : End of time seried in format YYYYMMDD
% TimeZone   : A string with the time zone ['GMT' 'LST' 'LST/LDT'], default 'GMT'
% Units      : 'english' or 'metric' - default 'metric'
% datum      : 'STND' - Station Datum   'MHHW' - Mean Higher High Water
%              'MHW'  - Mean High Water 'DTL'  - Diurnal Tide Level
%              'MTL'  - Mean Tide Level 'MSL'  - Mean Sea Level
%              'MLW'  - Mean Low Water  'MLLW' - Mean Lower Low Water
%              'NAVD' - North American Vertical Datum of 1988
%
%% Outputs
% fname     : filename of MAT file with the downloaded data
%
% The naming convension used is DATUM_StationID_YYYYMMDD_YYYYMMDD.mat
%
%% Copyright 2021, George Voulgaris, University of South Carolina
%
% This file is part of matNOAA-NDBC.
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
BaseAddress='https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?product=water_level&application=NOS.COOPS.TAC.WL';
% StartDate = 20210201; % in YYYYMMDD
% EndDate   = 20210212;
% StationID = 8661070;
if nargin<6 || isempty(Units)
    Units  = 'metric';
end
if nargin<5 || isempty(datum)
    datum  = 'NAVD';
end
if nargin<4 || isempty(TimeZone)
    TimeZone  = 'GMT';
end
%
period = ['&begin_date=',num2str(StartDate),'&end_date=',num2str(EndDate)];
params = ['&datum=',datum,'&station=',num2str(StationID),'&time_zone=',TimeZone,'&units=',Units,'&format=CSV'];
Link   = [BaseAddress,period,params];
fname  =[datum,'_',num2str(StationID),'_',num2str(StartDate),'_',num2str(EndDate),'.mat'];
www    = webread(Link);  % downloads the data and saves it in a file
time   = datenum(www.(1));
eta    = www.(2);
sigma  = www.(3);
qa     = cell2mat(www.(8));
save(fname,'time','eta','sigma','qa','StationID','Units','datum')
end
