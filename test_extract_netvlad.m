clear all;
close all;

[ params ] = setup_project_ht_WUSTL;


%% Load precomputed net
net = load('vd16_pitts30k_conv5_3_vlad_preL2_intra_white.mat');
net = net.net;
net= relja_simplenn_tidy(net);
% net= relja_cropToLayer(net, 'preL2');

%% netvlad extraction for query

%query list
if exist(params.input.qlist_matname, 'file') ~= 2
    query_imgnames_all = dir(fullfile(params.data.dir, params.data.q.dir, ['*', params.data.q.imgformat]));
    query_imgnames_all = {query_imgnames_all.name};
    save('-v6', params.input.qlist_matname, 'query_imgnames_all');
else
    load(params.input.qlist_matname, 'query_imgnames_all');
end

%extract netvlad
q_netvlad_matname = fullfile(params.output.netvlad.dir, params.output.netvlad.qfeat_matname);
if exist(q_netvlad_matname, 'file') ~= 2
    serialAllFeats_query(net, [fullfile(params.data.dir, params.data.q.dir), '/'], query_imgnames_all, q_netvlad_matname, 'batchSize', 1);
end

%% scoring
load(params.input.dblist_matname, 'cutout_imgnames_all');
db_netvlad_matname = fullfile(params.output.netvlad.dir, params.output.netvlad.dbfeat_matname);%precomputed

%load netvlad vector
nDims = 2^12;
if exist(params.input.score_matname, 'file') ~= 2
    qFeat = fread( fopen(q_netvlad_matname, 'rb'), [nDims, length(query_imgnames_all)], 'float32=>single');
    dbFeat = fread( fopen(db_netvlad_matname, 'rb'), [nDims, length(cutout_imgnames_all)], 'float32=>single');
    
    tic
    score = qFeat'*dbFeat;
    toc
    
    save('-v7.3', params.input.score_matname, 'score');
end





