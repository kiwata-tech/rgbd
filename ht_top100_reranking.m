%Note: It first rerank top100 original shortlist (ImgList_original) in accordance
%with the number of dense matching inliers. It then computes query
%candidate poses by using top10 database images. 

shortlist_topN = 100;

%% 

reranking_matname = fullfile(params.output.dir, 'densereranking_top100_shortlist.mat');
if exist(reranking_matname, 'file') ~= 2
    
    %dense feature extraction
    net = load('vd16_pitts30k_conv5_3_vlad_preL2_intra_white.mat');
    net = net.net;
    net= relja_simplenn_tidy(net);
    net= relja_cropToLayer(net, 'preL2');
    for ii = 1:1:length(ImgList_original)
        q_densefeat_matname = fullfile(params.input.feature.dir, params.data.q.dir, [ImgList_original(ii).queryname, params.input.feature.q_matformat]);
        if exist(q_densefeat_matname, 'file') ~= 2
            cnn = at_serialAllFeats_convfeat(net, query_dir, ImgList_original(ii).queryname, 'useGPU', true);
            cnn{1} = [];
            cnn{2} = [];
            [feat_path, ~, ~] = fileparts(q_densefeat_matname);
            if exist(feat_path, 'dir')~=7; mkdir(feat_path); end;
            save('-v6', q_densefeat_matname, 'cnn');
            fprintf('Dense feature extraction: %s done. \n', ImgList_original(ii).queryname);
        end
        
        for jj = 1:1:shortlist_topN
            db_densefeat_matname = fullfile(params.input.feature.dir, params.data.db.cutout.dir, ...
                [ImgList_original(ii).topNname{jj}, params.input.feature.db_matformat]);
            if exist(db_densefeat_matname, 'file') ~= 2
                cnn = at_serialAllFeats_convfeat(net, db_dir, ImgList_original(ii).topNname{jj}, 'useGPU', true);
                cnn{1} = [];
                cnn{2} = [];
                [feat_path, ~, ~] = fileparts(db_densefeat_matname);
                if exist(feat_path, 'dir')~=7; mkdir(feat_path); end;
                save('-v6', db_densefeat_matname, 'cnn');
                fprintf('Dense feature extraction: %s done. \n', ImgList_original(ii).topNname{jj});
            end
        end
    end
    
    %shortlist reranking
    ImgList = struct('queryname', {}, 'topNname', {}, 'topNscore', {}, 'P', {});
    for ii = 1:1:length(ImgList_original)
        ImgList(ii).queryname = ImgList_original(ii).queryname;
        ImgList(ii).topNname = ImgList_original(ii).topNname(1:shortlist_topN);
        
        %preload query feature
        qfname = fullfile(params.input.feature.dir, params.data.q.dir, [ImgList(ii).queryname, params.input.feature.q_matformat]);
        cnnq = load(qfname, 'cnn');cnnq = cnnq.cnn;
        
        parfor kk = 1:1:shortlist_topN
            parfor_denseGV( cnnq, ImgList(ii).queryname, ImgList(ii).topNname{kk}, params );
            fprintf('dense matching: %s vs %s DONE. \n', ImgList(ii).queryname, ImgList(ii).topNname{kk});
        end
        
        for jj = 1:1:shortlist_topN
            [~, dbbasename, ~] = fileparts(ImgList(ii).topNname{jj});
            this_gvresults = load(fullfile(params.output.gv_dense.dir, ImgList(ii).queryname, [dbbasename, params.output.gv_dense.matformat]));
            ImgList(ii).topNscore(jj) = ImgList_original(ii).topNscore(jj) + size(this_gvresults.inls12, 2);
        end
        
        [sorted_score, idx] = sort(ImgList(ii).topNscore, 'descend');
        ImgList(ii).topNname = ImgList(ii).topNname(idx);
        ImgList(ii).topNscore = ImgList(ii).topNscore(idx);

        fprintf('%s done. \n', ImgList(ii).queryname);
    end
    
    save('-v6', reranking_matname, 'ImgList');
    
else
    load(reranking_matname, 'ImgList');
end
ImgList_reranking = ImgList;
