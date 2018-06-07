function [inls, dist] = ki_matchCheck_3D(query3D, database3D, thre, codyPoints)

%inputs : query3D   : 3xN matrix
%         database3D: 3xN matrix
%         thre      : threshold(default:1.0)
%         codyPoints: 1x3 matrix (1 - N)
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
        codyPoints = [1,2,3];
    end
    if length(codyPoints) ~= 3
        disp('matchCheck_3D[4th input is wrong!]');
        return;
    end
    if size(query3D,1)~=size(database3D,1) || size(query3D,2)~=size(database3D,2)
        disp('matchCheck_3D[2nd input must be same size with 1st input!]');
        return;
    end
    if size(query3D,1)~=3
        disp('matchCheck_3D[Size of 1st input must be 3xN.]');
        return;
    end
    if max(codyPoints)>length(query3D) || min(codyPoints)<1
        disp('matchCheck_3D[4th input is wrong!]');
        return;
    end

%coordinate system
    vd1 = database3D(:,codyPoints(2))-database3D(:,codyPoints(1));
    vd2 = database3D(:,codyPoints(3))-database3D(:,codyPoints(1));
    vd3 = (cross(vd1',vd2'))';
    vq1 = query3D(:,codyPoints(2))-query3D(:,codyPoints(1));
    vq2 = query3D(:,codyPoints(3))-query3D(:,codyPoints(1));
    vq3 = (cross(vq1',vq2'))' / (norm(vq1)/norm(vd1));
    q3D = query3D    - query3D(:,codyPoints(1)); 
    Q = [vq1,vq2,vq3];
    D = [vd1,vd2,vd3];
    if sum(sum(isinf(Q))) > 0 || sum(sum(isnan(Q))) > 0
        return;
    end
    q3D = pinv(Q) * q3D;
    
    q3D2d3D = D * q3D + database3D(:,codyPoints(1));
    dist = sqrt(sum((q3D2d3D - database3D).^2));
    inls = (dist <= thre);
    
end
