function [ output ] = evolution_RT_TT_inBlock
global S

output = struct;


%% Shortcut

data = S.TaskData.OutRecorder.Data;
NrAngles = length(S.TaskData.Parameters.TargetAngles);


%% Make stats for each NrAngles

for block = 1 : 3
    
    % Fetch data in the current block
    data_in_block = data( data(:,1)==block , : );
    
    % Adjust number of chunks if necessary, be thow a warning
    NrChuncks = size(data_in_block,1)/NrAngles;
    if NrChuncks ~= round(NrChuncks)
        warning('chunk error : not an integer, in block #%d', block)
    end
    NrChuncks = floor(NrChuncks);
    
    % Pre-allocation
    RTmean = zeros(1,NrChuncks);
    RTstd  = RTmean;
    TTmean = RTmean;
    TTstd  = RTmean;
    
    for chunk = 1 : NrChuncks
        
        idx = NrAngles * (chunk-1) + 1   :   NrAngles * chunk;
        
        RTmean(chunk) = mean(data_in_block(idx,9));
        RTstd (chunk) =  std(data_in_block(idx,9));
        
        TTmean(chunk) = mean(data_in_block(idx,10));
        TTstd (chunk) =  std(data_in_block(idx,10));
        
    end % chunk
    
    s = struct;
    s.RTmean = RTmean;
    s.RTstd  = RTstd ;
    s.TTmean = TTmean;
    s.TTstd  = TTstd ;
    
    % Block name
    switch block
        case 1
            name = 'Direct_Pre';
        case 2
            name = 'Deviaton';
        case 3
            name = 'Direct_Post';
        otherwise
            error('block ?')
    end % switch
    
    output.(name)  = s;
    output.content = mfilename;
    
end % block


end % function