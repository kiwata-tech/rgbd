function [ params ] = setup_project_ht_WUSTL
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

params = struct();

%WUSTL dataset
%params.data.dir = '/mnt/RED6TB22/wustl_dataset';
params.data.dir = '/media/datagrid1/wusl-DB/InLoc_dataset-master';
%database
params.data.db.dir = 'database';
params.data.db.subsets_name = {'DUC1', 'DUC2', 'CSE3', 'CSE4', 'CSE5'};
params.data.db.subsets_header = {'DUC_', 'DUC_', 'cse_', 'cse_', 'cse_'};
%%scan
params.data.db.scan.dir = fullfile(params.data.db.dir, 'scans');
params.data.db.scan.header = strcat(params.data.db.subsets_header, 'scan_');
params.data.db.scan.imgformat = '.ptx.png';
params.data.db.scan.matformat = '.ptx.mat';
%%cutouts
params.data.db.cutout.dir = fullfile(params.data.db.dir, 'cutouts');
params.data.db.cutout.header = strcat(params.data.db.subsets_header, 'cutout_');
params.data.db.cutout.imgformat = '.jpg';
params.data.db.cutout.matformat = '.mat';
%%alignments
params.data.db.trans.dir = fullfile(params.data.db.dir, 'alignments');
params.data.db.trans.header = strcat(params.data.db.subsets_header, 'trans_');
%query
% params.data.q.dir = 'query/iphone7';
% params.data.q.imgformat = '.JPG';
% params.data.q.fl = 4032*28/36;
params.data.q.dir = 'query/rgbd';
params.data.q.imgformat = '.png';
fy = 1740.39193228149;
fx = 1743.44319528967;
cy = 980.880267341997;
cx = 540.977983486092;
params.data.q.K = [fx,  0, cx; 0, fy, cy; 0,  0,  1];
% params.data.q.fl = 4032*28/36;


%input
params.input.dir = 'inputs';
params.input.dblist_matname = fullfile(params.input.dir, 'db_cutout_names.mat');%string cell containing cutout image names
params.input.qlist_matname = fullfile(params.input.dir, 'query_rgbd_imgnames_all.mat');%string cell containing query image names
%params.input.score_matname = fullfile(params.input.dir, 'score_netvlad_1_50.mat');%retrieval score matrix
params.input.score_matname = fullfile(params.input.dir, 'ki_score_netvlad_wuslrgbd.mat');%retrieval score matrix
params.input.feature.dir = fullfile(params.input.dir, 'features');
params.input.feature.db_matformat = '.features.dense.mat';
params.input.feature.q_matformat = '.features.dense.mat';
params.input.feature.db_sps_matformat = '.features.sparse.mat';
params.input.feature.q_sps_matformat = '.features.sparse.mat';


%output
params.output.dir = 'outputs_rgbd2';

params.output.netvlad.dir = fullfile(params.output.dir, 'netvlad');
params.output.netvlad.qfeat_matname = 'qFeat.mat';
params.output.netvlad.dbfeat_matname = 'dbFeat.mat';

params.output.gv_dense.dir = fullfile(params.output.dir, 'gv_dense');%dense matching results (directory)
params.output.gv_dense.matformat = '.gv_dense.mat';%dense matching results (file extention)
params.output.gv_sparse.dir = fullfile(params.output.dir, 'gv_sparse');%sparse matching results (directory)
params.output.gv_sparse.matformat = '.gv_sparse.mat';%sparse matching results (file extention)

params.output.pnp_dense_inlier.dir = fullfile(params.output.dir, 'PnP_dense_inlier');%PnP results (directory)
params.output.pnp_dense.matformat = '.pnp_dense_inlier.mat';%PnP results (file extention)
params.output.pnp_sparse_inlier.dir = fullfile(params.output.dir, 'PnP_sparse_inlier');%PnP results (directory)
params.output.pnp_sparse_inlier.matformat = '.pnp_sparse_inlier.mat';%PnP results (file extention)

params.output.pnp_sparse_origin.dir = fullfile(params.output.dir, 'PnP_sparse_origin');%PnP results (directory)
params.output.pnp_sparse_origin.matformat = '.pnp_sparse_origin.mat';%PnP results (file extention)

params.output.synth.dir = fullfile(params.output.dir, 'synthesized');%View synthesis results (directory)
params.output.synth.matformat = '.synth.mat';%View synthesis results (file extention)

params.output.qualitative.dir = fullfile(params.output.dir, 'qualitatives');%Qualitatives (directory)
params.output.qualitative.imgformat = '.qual.png';%Qualitatives (file extention)


%groundtruth
params.gt.dir = 'Refposes';
params.gt.matname = 'DUC_refposes_all_rgbd_new_new_ki.mat';

end

