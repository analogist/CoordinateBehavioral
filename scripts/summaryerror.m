 function [improvement, improvementnorm, runerror, meanerror, sderror, numruns] = summaryerror(error, rotation, runnum, target)
%SUMMARYERROR Summary of this function goes here
%   Detailed explanation goes here
    runlist = unique(runnum);
    runerror = nan(numel(runlist), 2);
    for i = 1:numel(runlist)
        runerror(i, 1) = sum(abs(error.angle(runnum == runlist(i))));
        runerror(i, 2) = mode(rotation(runnum == runlist(i)));
        runerror(i, 3) = numel(unique(target(runnum == runlist(i))));
    end
    % complete runs only
    runerror = runerror(runerror(:, 3) >= 12, :);
    
    rotlist = [0 45 90 180];
    improvement = nan(numel(rotlist), 1);
    improvementnorm = improvement;
    meanerror = improvement;
    sderror = improvement;
    numruns = zeros(numel(rotlist), 1);
    for i = 1:numel(rotlist)
        rot_oi = rotlist(i);
        run_oi = find(runerror(:, 2) == rot_oi);
        meanerror(i) = mean(runerror(run_oi, 1));
        sderror(i) = std(runerror(run_oi, 1)/sqrt(numel(run_oi)));
        coeffs = polyfit((1:length(run_oi))', runerror(run_oi, 1), 1);
        improvement(i) = coeffs(1);
        improvementnorm(i) = coeffs(1) / coeffs(2);
        numruns(i) = sum(runerror(run_oi, 3) >= 12);
    end
end

