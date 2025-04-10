function recordingInformation = scanRecordings(projectFolder)

% initialize output
recordingInformation = struct([]);

% make sure data folders exists
if ~exist(projectFolder,'dir')
    return
end
if ~exist(fullfile(projectFolder,'recordings'),'dir')
    return
end
% if ~exist(fullfile(projectFolder,'calibrations'),'dir')
%     return
% end
% if ~exist(fullfile(projectFolder,'participants'),'dir')
%     return
% end

% % make sure project information file exists
% if ~exist(fullfile(projectFolder,'project.json'),'file')
%     return
% end

% get all directories in data folder (except root directories)
recordingFolders = dir(fullfile(projectFolder,'recordings'));
recordingFolders(~[recordingFolders.isdir]) = [];
recordingFolders = {recordingFolders.name};
recordingFolders(strcmp(recordingFolders,'.')) = [];
recordingFolders(strcmp(recordingFolders,'..')) = [];

% get recording information
for i = 1:length(recordingFolders)
    
    % get recording folder
    recordingFolder = fullfile(projectFolder,'recordings',recordingFolders{i});
    
    % get recording info
    recordingInfoFile = fullfile(recordingFolder,'recording.json');
    if ~exist(recordingInfoFile,'file')
        continue
    end
    txt = fileread(recordingInfoFile);
    rec_info = jsondecode(txt);
    
    % get participant info
    participantInfoFile = fullfile(recordingFolder,'participant.json');
    if ~exist(participantInfoFile,'file')
        continue
    end
    txt = fileread(participantInfoFile);
    pa_info = jsondecode(txt);
    
    % get system info
    systemInfoFile = fullfile(recordingFolder,'sysinfo.json');
    if ~exist(systemInfoFile,'file')
        continue
    end
    txt = fileread(systemInfoFile);
    sys_info = jsondecode(txt);
    
    % make sure there is a segments folder
    segmentsFolder = fullfile(recordingFolder,'segments');
    if ~exist(segmentsFolder,'dir')
        continue
    end
    
    % compile data
    info = [];
    info.recordingName = rec_info.rec_info.Name;
    info.recordingID = rec_info.rec_id;
    info.participantName = pa_info.pa_info.Name;
    info.participantID = pa_info.pa_id;
    info.folder = recordingFolder;
    info.recording = rec_info;
    info.participant = pa_info;
    info.system = sys_info;
    
    % add to list
    recordingInformation = [recordingInformation info];    
    
end




