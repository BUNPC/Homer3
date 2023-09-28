function [usable_bytes, total_bytes] = getFreeDiskSpace(drive)
%
% This code is based on the info from 
%  https://www.mathworks.com/matlabcentral/answers/312074-check-free-space-in-a-directory
% 
% Example code:
%
%     FileObj      = java.io.File(Folder);
%     free_bytes   = FileObj.getFreeSpace;
%     total_bytes  = FileObj.getTotalSpace;
%     usable_bytes = FileObj.getUsableSpace;
%
%

usable_bytes = [];
if ~exist('drive', 'var')
    drive = '.';
end
if exist(drive, 'dir') ~= 7
    return
end
FileObj      = java.io.File(drive);
usable_bytes = FileObj.getUsableSpace;
total_bytes  = FileObj.getTotalSpace;

