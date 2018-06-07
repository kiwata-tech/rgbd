function ki_parfor_denseGV( cnnq, qname, dbname, params )
%qname(ex.)  : '20170214-15_14_59.png'
%dbname(ex.) : 'DUC2/029/DUC_cutout_029_30_30.jpg'
coarselayerlevel = 4;
finelayerlevel = 3;

[~, dbbasename, ~] = fileparts(dbname);
this_densegv_matname = fullfile(params.output.gv_dense.dir, qname, [dbbasename, params.output.gv_dense.matformat]);

if exist(this_densegv_matname, 'file') ~= 2
    
%     old_densegv_matname = fullfile('/media/datagrid1/WUSTL_demo-query-rgbd/outputs_rgbd/gv_dense',qname, [dbbasename, params.output.gv_dense.matformat]);
%     if exist(old_densegv_matname, 'file') ~= 2
    
    %load input feature
    dbfname = fullfile(params.input.feature.dir, params.data.db.cutout.dir, [dbname, params.input.feature.db_matformat]);
    cnndb = load(dbfname, 'cnn');cnndb = cnndb.cnn;
    disp(cnndb)
    
    
    %coarse-to-fine matching
    cnnfeat1size = size(cnnq{finelayerlevel}.x);
    cnnfeat2size = size(cnndb{finelayerlevel}.x);
        
    [match12,f1,f2,cnnfeat1,cnnfeat2] = at_coarse2fine_matching(cnnq,cnndb,coarselayerlevel,finelayerlevel);
    [inls12] = at_denseransac(f1,f2,match12,2);
    
%     else
%         load(old_densegv_matname);
%     end
    
  %ki_edit[start]
    
    %load 3Dpoints(query)
    [~,query3Dname,~] = fileparts(qname);
    query3Dname = [query3Dname '.mat'];
    load(fullfile(params.data.dir, params.data.q.dir, query3Dname),'img','D','X');%X(1,:) are x. X(3,:) are z.
    
    %load 3Dpoints(database)
    load(['/media/datagrid1/wusl-DB/InLoc_dataset-master/database/cutouts/' dbname '.mat'],'XYZcut');
     
    [qH, qW, ~] = size(img);
    eqH = cnnfeat1size(1) / qH;
    eqW = cnnfeat1size(2) / qW;
    qX = D(1,:) * eqW;
    qY = D(2,:) * eqH;
    qc = [qX; qY];%after resize(2xN)
    d = pdist2(qc',f1');%(qc x f1)
    [dis,idx] = sort(d);
    dis = dis(1,:);
    idx = idx(1,:);
    q3D = nan(3,length(f1));
    for qq = 1:1:length(f1)
         q3D(1,qq) = X(1,idx(qq));
         q3D(2,qq) = X(2,idx(qq));
         q3D(3,qq) = X(3,idx(qq));
    end
    
    [dbH, dbW, ~] = size(XYZcut);
    edH = dbH / cnnfeat2size(1);
    edW = dbW / cnnfeat2size(2);
    dbc = round([f2(1,:)*edW; f2(2,:)*edH]);%after resize
    db3D = nan(3,length(dbc));
    for dd = 1:1:length(dbc)
        db3D(1,dd) = XYZcut(dbc(2,dd),dbc(1,dd),1);
        db3D(2,dd) = XYZcut(dbc(2,dd),dbc(1,dd),2);
        db3D(3,dd) = XYZcut(dbc(2,dd),dbc(1,dd),3);
    end
    
    f1_hoge = f1(:, inls12(1,:));
    f2_hoge = f2(:, inls12(2,:));
    q3D =  q3D(:, inls12(1,:));
    db3D= db3D(:, inls12(1,:));
    nanChk = ~(isnan(db3D(1,:)));
    f1_hoge = f1_hoge(:,nanChk);
    f2_hoge = f2_hoge(:,nanChk);
    q3D =  q3D(:, nanChk);
    db3D= db3D(:, nanChk);
    nanChk = ~(isnan(q3D(1,:)));
    f1_hoge = f1_hoge(:,nanChk);
    f2_hoge = f2_hoge(:,nanChk);
    q3D =  q3D(:, nanChk);
    db3D= db3D(:, nanChk);
    if size(q3D,2)>=4
        [inls12_hoge,distchk] = ki_matchCheck_3D_RANSAC(q3D, db3D, 0.2);
        f1 = f1_hoge;
        f2 = f2_hoge;
        match12 = inls12;
        inls12 = [inls12_hoge;inls12_hoge];
    else
        inls12_hoge = zeros(1,size(f1_hoge,2));
        dist = 0;
    end
  %ki_edit[end]
    
    if exist(fullfile(params.output.gv_dense.dir, qname), 'dir') ~= 7
        mkdir(fullfile(params.output.gv_dense.dir, qname));
    end
    save('-v6', this_densegv_matname, 'cnnfeat1size', 'cnnfeat2size', 'f1', 'f2', 'inls12', 'match12');
    
    
%     %debug
%     im1 = imresize(imread(fullfile(params.data.dir, params.data.q.dir, qname)), cnnfeat1size(1:2));
%     im2 = imresize(imread(fullfile(params.data.dir, params.data.db.cutout.dir, dbname)), cnnfeat2size(1:2));
%     disp(qname);%ki
%     disp(dbname);%ki
%     figure();
%     ultimateSubplot ( 2, 1, 1, 1, 0.01, 0.05 );
%     imshow(rgb2gray(im1));hold on;
%     plot(f1(1,match12(1,:)),f1(2,match12(1,:)),'b.');
%     plot(f1(1,inls12(1,:)),f1(2,inls12(1,:)),'g.');
%     plot(f1_hoge(1,inls12_hoge(1,:)),f1_hoge(2,inls12_hoge(1,:)),'r.');%ki
%     ultimateSubplot ( 2, 1, 2, 1, 0.01, 0.05 );
%     imshow(rgb2gray(im2));hold on;
%     plot(f2(1,match12(2,:)),f2(2,match12(2,:)),'b.');
%     plot(f2(1,inls12(2,:)),f2(2,inls12(2,:)),'g.');
%     plot(f2_hoge(1,inls12_hoge(1,:)),f2_hoge(2,inls12_hoge(1,:)),'r.');%ki
%     keyboard;
end

end

