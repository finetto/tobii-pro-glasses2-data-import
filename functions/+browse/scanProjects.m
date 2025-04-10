function projectInformation = scanProjects(dataFolder)

% initialize output
projectInformation = struct([]);

% make sure data folder exists
if ~exist(dataFolder,'dir')
    return
end

% get all directories in data folder (except root directories)
projectFolders = dir(dataFolder);
projectFolders(~[projectFolders.isdir]) = [];
projectFolders = {projectFolders.name};
projectFolders(strcmp(projectFolders,'.')) = [];
projectFolders(strcmp(projectFolders,'..')) = [];

% get study information
for i = 1:length(projectFolders)
   
    % get project folder
    projectFolder = fullfile(dataFolder,projectFolders{i});
    
    % read project information file
    projectInfoFile = fullfile(projectFolder,'project.json');
    if ~exist(projectInfoFile,'file')
        continue
    end
    txt = fileread(projectInfoFile);
    info = jsondecode(txt);
    
    % compile project information
    pr_info = [];
    pr_info.name = info.pr_info.Name;
    pr_info.id = info.pr_id;
    pr_info.folder = projectFolder;
    pr_info.info = info;
    
    % add to list
    projectInformation = [projectInformation pr_info];    
end

