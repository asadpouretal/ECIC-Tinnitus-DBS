function [info, ch] = ImportStreamData(file_fullpath)
%% STREAM Data

% % Enter the file location of eBridge.dll (located in eProbe file location)
NET.addAssembly('C:\RubyMind\eProbe\eBridge.dll');

% main_path = 'C:\Users\assad\OneDrive - Ulster University\Research projects\Bimarestan Rasoul\Akbarnejad Single\New Device\22-08-2023';
% 
% file_name = 'Case 2 T first record before stmu.Stream';
% file_fullpath = fullfile(main_path, file_name);
% % Enter your Stream Data file location
info = char(eBridge.File.GetProperty(file_fullpath)); %recording info % pathway of saved file
ch = double(eBridge.File.OpenStream(file_fullpath));

%% .sbd Data

% % Enter the file location of eBridge.dll (located in eProbe file location)
% cls=NET.addAssembly('C:\RubyMind\eProbe\eBridge.dll'); 

% % Enter your sbd Data file location
% info3 = char(eBridge.File.GetProperty('D:\Desktop\My Life\Job\Bimarestan Rasoul\Akbarnejad Single\DefaultSaveFile.sbd')); %recording info % pathway of saved file
% ch3 = double(eBridge.File.Open('D:\Desktop\My Life\Job\Bimarestan Rasoul\Akbarnejad Single\DefaultSaveFile.sbd',0)); %n=channel number; 0=ch1

end