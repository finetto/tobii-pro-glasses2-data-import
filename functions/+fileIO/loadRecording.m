function recordingData = loadRecording(recordingFolder)

% initialize output
recordingData = struct([]);

% make sure data folder exists
if ~exist(fullfile(recordingFolder,'segments'),'dir')
    return
end

% get all segments folders
segmentFolders = dir(fullfile(recordingFolder,'segments'));
segmentFolders(~[segmentFolders.isdir]) = [];
segmentFolders = {segmentFolders.name};
segmentFolders(strcmp(segmentFolders,'.')) = [];
segmentFolders(strcmp(segmentFolders,'..')) = [];

% load each segment
for is = 1:length(segmentFolders)
    
    % get segments folder
    segmentsFolder = fullfile(recordingFolder,'segments',segmentFolders{is});
    
    % make sure all data exists
    liveDataFile = fullfile(segmentsFolder,'livedata.json.gz');
    calibrationFile = fullfile(segmentsFolder,'calibration.json');
    segmentInfo = fullfile(segmentsFolder,'segment.json');
    videoFile = fullfile(segmentsFolder,'fullstream.mp4');
    
    if ~exist(liveDataFile,'file') || ~exist(calibrationFile,'file') || ~exist(segmentInfo,'file') %|| ~exist(videoFile,'file')
        continue
    end
    
    % load segment info
    txt = fileread(segmentInfo);
    seg_info = jsondecode(txt);
    
    % load calibration info
    txt = fileread(calibrationFile);
    cal_info = jsondecode(txt);
    
    % extract live data to tmp folder
    if ~exist('tmp','dir')
        mkdir('tmp')
    end
    gunzip(liveDataFile,'tmp');
    
    % initialize data structure
    data.gd.left.timestamp = [];
    data.gd.left.gidx = [];
    data.gd.left.value = [];
    data.gd.right = data.gd.left;
    
    data.pc = data.gd;
    data.pd = data.gd;
    
    data.gp.timestamp = [];
    data.gp.gidx = [];
    data.gp.value = [];
    data.gp.l = [];
    
    data.gp3.timestamp = [];
    data.gp3.gidx = [];
    data.gp3.value = [];
    
    data.pts.timestamp = [];
    data.pts.value = [];
    data.pts.pv = [];
    
    data.vts.timestamp = [];
    data.vts.value = [];
    
    data.ac.timestamp = [];
    data.ac.value = [];
    
    data.gy = data.ac;
    
    data.sync.in.timestamp = [];
    data.sync.in.value = [];
    data.sync.out = data.sync.in;
   
    % parse live data
    liveDataTxt = fileread(fullfile('tmp','livedata.json'));
    liveDataSamples = strsplit(liveDataTxt,'\n');
       
    for i = 1:length(liveDataSamples)
        
        % extract sample data
        sampleString = liveDataSamples{i};
        if isempty(sampleString) || (sampleString(1)~='{') || (sampleString(end)~='}')
            continue
        end
        
        sampleData = jsondecode(sampleString);
        
        % parse data
        if isfield(sampleData,'gd')
            side = sampleData.eye;
            data.gd.(side).timestamp = [data.gd.(side).timestamp; sampleData.ts];
            data.gd.(side).gidx = [data.gd.(side).gidx; sampleData.gidx];
            data.gd.(side).value = [data.gd.(side).value; sampleData.gd'];
        end
        
        if isfield(sampleData,'pc')
            side = sampleData.eye;
            data.pc.(side).timestamp = [data.pc.(side).timestamp; sampleData.ts];
            data.pc.(side).gidx = [data.pc.(side).gidx; sampleData.gidx];
            data.pc.(side).value = [data.pc.(side).value; sampleData.pc'];
        end
        
        if isfield(sampleData,'pd')
            side = sampleData.eye;
            data.pd.(side).timestamp = [data.pd.(side).timestamp; sampleData.ts];
            data.pd.(side).gidx = [data.pd.(side).gidx; sampleData.gidx];
            data.pd.(side).value = [data.pd.(side).value; sampleData.pd];
        end
        
        if isfield(sampleData,'gp')
            data.gp.timestamp = [data.gp.timestamp; sampleData.ts];
            data.gp.gidx = [data.gp.gidx; sampleData.gidx];
            data.gp.value = [data.gp.value; sampleData.gp'];
            data.gp.l = [data.gp.l; sampleData.l];
        end
        
        if isfield(sampleData,'gp3')
            data.gp3.timestamp = [data.gp3.timestamp; sampleData.ts];
            data.gp3.gidx = [data.gp3.gidx; sampleData.gidx];
            data.gp3.value = [data.gp3.value; sampleData.gp3'];
        end
        
        if isfield(sampleData,'pts')
            data.pts.timestamp = [data.pts.timestamp; sampleData.ts];
            data.pts.value = [data.pts.value; sampleData.pts];
            data.pts.pv = [data.pts.pv; sampleData.pv];
        end
        
        if isfield(sampleData,'vts')
            data.vts.timestamp = [data.vts.timestamp; sampleData.ts];
            data.vts.value = [data.vts.value; sampleData.vts];
        end
        
        if isfield(sampleData,'ac')
            data.ac.timestamp = [data.ac.timestamp; sampleData.ts];
            data.ac.value = [data.ac.value; sampleData.ac'];
        end
        
        if isfield(sampleData,'gy')
            data.gy.timestamp = [data.gy.timestamp; sampleData.ts];
            data.gy.value = [data.gy.value; sampleData.gy'];
        end
        
        if isfield(sampleData,'sig')
            direction = sampleData.dir;
            data.sync.(direction).timestamp = [data.sync.(direction).timestamp; sampleData.ts];
            data.sync.(direction).value = [data.sync.(direction).value; sampleData.sig];
        end
               
    end
    
    % compile data
    segmentData = [];
    segmentData.information = seg_info;
    segmentData.calibration = cal_info;
    segmentData.data = data;
    segmentData.videoFile = [];
    if exist(videoFile,'file')
        segmentData.videoFile = videoFile;
    end
    
    % add to output
    recordingData = [recordingData segmentData];
    
end