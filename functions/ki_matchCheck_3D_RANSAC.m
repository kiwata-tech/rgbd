function [inls, dist] = ki_matchCheck_3D_RANSAC(query3D, database3D, thre, iterMax)

%inputs : query3D   : 3xN matrix
%         database3D: 3xN matrix
%         thre      : threshold(default:1.0)
%         iterMax   : max of iteration(default:500)
%output : inls      : inliers 1xN logical

%K.Iwata 2018.04

inls = nan;
dist = nan;

%inputs check
    if nargin < 2
        return;
    end
    if nargin < 3
        thre = 1.0;
    end
    if nargin < 4
        iterMax = 500;
    end
    if size(query3D,1)~=size(database3D,1) || size(query3D,2)~=size(database3D,2)
        disp('matchCheck_3D[2nd input must be same size with 1st input!]');
        return;
    end
    if size(query3D,1)~=3
        disp('matchCheck_3D[Size of 1st input must be 3xN.]');
        return;
    end
    
%
    sumInls = 0;
    iter = 0;
    while iter < iterMax
        iter = iter + 1;
        codyPoints = randperm(length(query3D),3);
        [inls_cand, dist_cand] = ki_matchCheck_3D(query3D, database3D, thre, codyPoints);
        if sum(inls_cand) > sumInls
            sumInls = sum(inls_cand);
            inls = inls_cand;
            dist = dist_cand;
            disp([num2str(iter) ' : inls = ' num2str(sumInls) '.']);
        end
    end
    
end
