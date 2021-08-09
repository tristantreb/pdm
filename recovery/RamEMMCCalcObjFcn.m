function [dist, count, hstg, vshift, isOutlier] = RamEMMCCalcObjFcn(meancurvemean, meancurvestd, amIntrCube, ...
    amHeldBackcube, vshift, isOutlier, outprior, measuresmask, measuresrange, normstd, hstg, currinter, ...
    curroffsetidx, offset, align_wind, nmeasures, update_histogram, sigmamethod, smoothingmethod, allowvshift, vshiftmax)

% amEMMCCalcObjFcn - calculates residual sum of squares distance for points in
% curve vs a given meancurve incorporating offset

dist = 0;
count = 0;
tempmean = zeros(align_wind + offset.span-1, nmeasures);
tempstd  = zeros(align_wind + offset.span-1, nmeasures);
offsetval = offset.down:offset.up;
curroffsetval = offsetval(curroffsetidx); % convert offsetidx to offsetval

if (update_histogram == 1)
    for m = 1:nmeasures
        hstg(1, m, currinter, curroffsetidx) = 0;
    end
end

% check right size
for m = 1:nmeasures
    if smoothingmethod == 2
        tempmean(:,m) = smooth(meancurvemean(1, :, m),5);
        tempstd(:,m) = smooth(meancurvestd(1, :, m),5);
    else
        tempmean(:,m) = meancurvemean(1, :, m);
        tempstd(:,m) = meancurvestd(1, :, m);
    end
end

%for m = 1:nmeasures
%    mdist = 0;
%    for i = 1:align_wind    
%        % distance calculation for an outlier point
%        outdist = -log(outprior) + log(measuresrange(m));
%        if (~isnan(amIntrCube(currinter, max_offset + align_wind - i, m)) && amHeldBackcube(currinter, max_offset + align_wind - i, m) == 0)
%            % distance calculation for a regular point
%            regdist = calcRegDist(tempmean(max_offset + align_wind - i - curroffset, m), ...
%                                  tempstd(max_offset + align_wind - i - curroffset, m), ...
%                                  normstd(currinter, m), ...
%                                  amIntrCube(currinter, max_offset + align_wind - i, m), ...
%                                  sigmamethod);
%            regdist = regdist - log(1 - outprior);
%
%            if regdist <= outdist
%                thisdist = regdist;
%                isOutlier(1, currinter, align_wind + 1 - i, m, curroffset + 1) = 0;
%            else
%                thisdist = outdist;
%                isOutlier(1, currinter, align_wind + 1 - i, m, curroffset + 1) = 1;
%            end
%            %fprintf('Measure %d, Point %d: Dist = %8.4f\n', m, max_offset + align_wind - i, thisdist);
%            
%            % only include desired measures in overall alignment
%            % optimisation
%            if measuresmask(m) == 1
%                dist = dist + thisdist;
%                count = count + 1;
%            end
%            if (update_histogram == 1)
%                hstg(1, m, currinter, curroffset + 1) = hstg(1, m, currinter, curroffset + 1) + thisdist;
%            end
%            mdist = mdist + thisdist;
%        end
%    end
%    %fprintf('Measure %d: Dist = %8.4f\n', m, mdist);
%end

% partially vectorised implementation for improved performance
for m = 1:nmeasures
    outdist = -log(outprior) + log(measuresrange(m));
    actidx = ~isnan(amIntrCube(currinter, abs(offset.down) + 1 : abs(offset.down) + align_wind, m)) & amHeldBackcube(currinter, abs(offset.down) + 1 : abs(offset.down) + align_wind, m) == 0;
    offsettempmean = tempmean(abs(offset.down) + 1 + curroffsetval : abs(offset.down) + align_wind + curroffsetval, m);
    intrdata       = amIntrCube(currinter, abs(offset.down) + 1 :  abs(offset.down) + align_wind, m);
    
    if allowvshift && sum(actidx) ~= 0
        vshift(1, currinter, m, curroffsetidx) = (sum(offsettempmean(actidx)) - sum(intrdata(actidx))) / sum(actidx);
        if vshift(1, currinter, m, curroffsetidx) > vshiftmax
            vshift(1, currinter, m, curroffsetidx) = vshiftmax;
        elseif vshift(1, currinter, m, curroffsetidx) < -vshiftmax
            vshift(1, currinter, m, curroffsetidx) = -vshiftmax;
        end
    end
    
    if sigmamethod == 4
        regdist = ((offsettempmean - intrdata' - vshift(1, currinter, m, curroffsetidx)) .^ 2) ...
                    ./ (2 * (tempstd(abs(offset.down) + 1 + curroffsetval : abs(offset.down) + align_wind + curroffsetval, m) .^ 2)) ...
                    + log(tempstd(abs(offset.down) + 1 + curroffsetval : abs(offset.down) + align_wind + curroffsetval, m)) ...
                    + log((2 * pi) ^ 0.5) ...
                    - log(1 - outprior);
    else
        regdist = ( (offsettempmean - intrdata' - vshift(1, currinter, m, curroffsetidx)) .^ 2) ...
                    / ( 2 * normstd(currinter, m) ) ...
                    + log(normstd(currinter, m)) ...
                    + log((2 * pi) ^ 0.5) ...
                    - log(1 - outprior);
    end
    
    %if sigmamethod == 4
    %    regdist = ((tempmean(max_offset - curroffset:max_offset + align_wind - 1 - curroffset, m) - amIntrCube(currinter, max_offset:(max_offset + align_wind - 1), m)') .^ 2) ...
    %                ./ (2 * (tempstd(max_offset - curroffset:max_offset + align_wind - 1 - curroffset, m) .^ 2)) ...
    %                + log(tempstd(max_offset - curroffset:max_offset + align_wind - 1 - curroffset, m)) ...
    %                + log((2 * pi) ^ 0.5) ...
    %                - log(1 - outprior);
    %else
    %    regdist = ( (tempmean(max_offset - curroffset:max_offset + align_wind - 1 - curroffset, m) - amIntrCube(currinter, max_offset:(max_offset + align_wind - 1), m)') .^ 2) ...
    %                / ( 2 * normstd(currinter, m) ) ...
    %                + log(normstd(currinter, m)) ...
    %                + log((2 * pi) ^ 0.5) ...
    %                - log(1 - outprior);
    %end

    regdist = regdist(actidx);
    outdist = outdist * ones(sum(actidx), 1);
    ptidx = regdist < outdist;
    totdist = sum(regdist(ptidx)) + sum(outdist(~ptidx));

    if measuresmask(m) == 1
        dist = dist + totdist;
        count = count + sum(actidx);
    end

    if (update_histogram == 1)
        hstg(1, m, currinter, curroffsetidx) = totdist;
    end

end

%fprintf('Intr %2d, Offset %2d: Dist: Old %8.4f, New %8.4f   Count: Old %3d New %3d\n', currinter, curroffset, dist, dist2, count, count2);

end
