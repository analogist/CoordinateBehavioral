function [ startidxtdt, stopidxtdt ] = behavior_sync( behaviorcells, pickuplocs, butndata, butnfs, behaviortable )
%BEHAVIOR Summary of this function goes here
%   Detailed explanation goes here
%COMPUTE_BUTNALIGN Summary of this function goes here
%   Detailed explanation goes here

    if(~exist('butndata', 'var'))
        butndata = [];
    end
    col.time = 1;
    col.pos = [2 4];
    col.vel = [5 6];
    col.button = 10;
    col.pickup = 11;

    unity_struct = unitycsvextract(behaviorcells, col);
    position = cell2mat(behaviorcells(:, col.pos));
    controlVel = cell2mat(behaviorcells(:, col.vel));

    rotationraw = unity_struct.events(:, 1);
    
    rotation = rotationraw;
    rotation(rotation >= 2000 | rotation < 1000) = 0;
    rotation = rotation - 1000;
    rotation(1) = 0;
    
    runnum = zeros(size(rotationraw));
    runnum(1) = 1;
    
    target = ones(size(unity_struct.events(:, 2)));

    for i = 2:length(rotationraw)
        if(rotation(i) == -1000)
            rotation(i) = rotation(i-1);
        end
        if(rotationraw(i) == 2000)
            runnum(i) = runnum(i-1)+1;
            target(i) = 1;
        else
            runnum(i) = runnum(i-1);
        end
        if(unity_struct.events(i, 2) ~= 0)
            target(i) = unity_struct.events(i, 2)+1;
            if(target(i) > 12)
                target(i) = 0;
            end
        else
            target(i) = target(i-1);
        end
            
    end

    controlPol = nan(size(controlVel));
    [controlPol(:, 1), controlPol(:, 2)] = ...
        cart2pol(controlVel(:, 1), controlVel(:, 2));
    
    error = struct();
    error.angle = zeros(size(rotationraw));
    for i = 1:length(rotationraw)
        if(controlPol(i, 2) > 0 && target(i) > 0)
            targetcoord = pickuplocs(target(i), :);
            error.angle(i) = ...
                acos(dot(targetcoord-position(i, :), controlVel(i, :)) / ...
                (norm(targetcoord-position(i, :)) * norm(controlVel(i, :))));
        end
    end
    
    if(~isempty(butndata))
        [~, butnlocs] = findpeaks(abs(butndata), 'MinPeakProminence', 0.5, 'MinPeakDistance', butnfs*0.036);
        unitylocs = unity_struct.clock(find(unity_struct.events(:, 1)));
        usenum = min(length(butnlocs), length(unitylocs(2:end)));
        offset = mean(butnlocs(end-usenum+1:end)/butnfs - unitylocs(end-usenum+1:end) + 0.0539);
        
        unity_correct_clock = unity_struct.clock + offset;
        tdt_clock = (0:length(butndata)-1)'/butnfs;
        
        starttime = unity_correct_clock(behaviortable.start);
        stoptime = unity_correct_clock(behaviortable.stop);
        
        startidxtdt = zeros(size(starttime));
        stopidxtdt = zeros(size(stoptime));
        
        for i = 1:length(startidxtdt)
            startidxtdt(i) = findclosest(starttime(i), tdt_clock);
            stopidxtdt(i) = findclosest(stoptime(i), tdt_clock);
        end
        
        
    end
    
end

