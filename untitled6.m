disp('a')
close all
clear all

pth = '/media/datagrid1/wusl-DB/InLoc_dataset-master/query/rgbd/';

q3D_dir = dir([pth '*.mat']);

for ii = 1:1:length(q3D_dir)
    
    loadName = [q3D_dir(ii).folder '/' q3D_dir(ii).name];
    
    load(loadName,'img','D','X');%X(1,:) are x. X(3,:) are z.
    
    pc = nan(size(img));
    
%     fig = figure; set(fig, 'Position', [100 400 480 640]);
%     figure(fig); 
%     imshow(img); hold on; 
%     scatter(D(1,:), D(2,:), 10, D(3,:), 'filled');
    
    cnt = 0;
    for kk = 1:1:length(D)
        yy = round(D(2,kk));
        xx = round(D(1,kk));
        if yy>= 1 && yy <= size(pc,1) && xx >= 1 && xx <= size(pc,2)
            pc(yy, xx,1) = X(1,kk);
            pc(yy, xx,2) = X(2,kk);
            pc(yy, xx,3) = X(3,kk);
            cnt = cnt + 1;
        end
    end
    
    [~,saveName,~] = fileparts(q3D_dir(ii).name);
    saveName = [saveName '.3d.mat'];

    %save([pth saveName], 'pc');
    disp(cnt);
end





