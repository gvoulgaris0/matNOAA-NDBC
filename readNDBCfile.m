%% readNDBCfile.m
function [pname, errID]=readNDBCfile(stationID,year,data1,data2)
%
% function for downloading NOAA/NDBC Historical Data into MATLAB®
%
%% Inputs
% stationID : The NOAA/NDBC station id as in NOAA homepage
% year      : Year historical data is requested for
% data1     : String #1 used in constructing the hyperlink as per NOAA/NDBC
% data2:    : String #2 used for ADCP data as per NOAA/NDBC
%
% Strings to be used for differnet type of data
% Description               data1   data2
%-----------------------------------------------
% For ADCP data           :  'a'   'adcp'
% For met data            :  'h'   'stdmet'
% For continuous wind data:  'c'   'cwind'
% For oceanographic datat :  'o'   'ocean'
% For Tsunami (DART) data :  't'   'dart'
% For wave density spectra:  'w'   'swden'
% For directional wave spectra
%                   ALPHA1:  'd'   'swdir'
%                   ALPHA2:  'i'   'swdir2'
%                       R1:  'j'   'swr1'
%                       R2:  'k'   'swr2'
%
%% Outputs
% pname     : string with the filename and position the file has been saved
%             at local computer
% errID     : =1 if file was found
%             =0 if no file was found
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
% a string in parameter NOAANDBC
NOAANDBC=('https://www.ndbc.noaa.gov/view_text_file.php?filename=');
if nargin<1
    stationID=41008;   % The station ID number
    year = 2009;       % The year historical data is required for
    data1='a';         % String #1 used in constructing the hyperlink as per NOAA/NDBC
    data2='adcp';      % String #2 used for ADCP data as per NOAA/NDBC
end
% fname is constructed using the information above and describes the file of interest
fname   =[num2str(stationID),data1,num2str(year),'.txt.gz&dir=data%2Fhistorical%2F'];
% location is the full hyperlink where the file is located on the NOAA server
location=[NOAANDBC,fname,data2,'%2F'];
%%
% Check if the file exists
request = matlab.net.http.RequestMessage;
uri     = matlab.net.URI(location);
r       = send(request,uri);
%%
errID = 0;
if strcmp(r.StatusCode,'OK')             % File was found
    localname = [data2,'_',num2str(stationID),'_',num2str(year),'.txt'];
    pname     = websave(localname,location);  % downloads the data and saves it in a file
    errID     = 1;
else
    disp('File does not exist') % File was not found, or site is down or internet is down etc.
    errID = 0;
    pname = [];
end
end