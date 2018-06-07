clear all;
close all;

[ params ] = setup_project_ht_WUSTL;

%image dir
query_dir = fullfile(params.data.dir, params.data.q.dir);
db_dir = fullfile(params.data.dir, params.data.db.cutout.dir);

%shortlist
 top100_matname = fullfile(params.output.dir, 'original_top100_shortlist.mat');
 load(top100_matname, 'ImgList');
% reranking_matname = fullfile(params.output.dir, 'densereranking_top100_shortlist.mat');
% load(reranking_matname, 'ImgList');
densepv_matname = fullfile(params.output.dir, 'densePV_top10_shortlist.mat');


for ii = 1:1:length(ImgList)
    
    this_qname = ImgList(ii).queryname;
    
    h1 = figure();set(h1, 'Position', [0 0 1600 400]);
    
    Iq = imread(fullfile(query_dir, this_qname));
    ultimateSubplot(6, 2, 1, 1, 0.1, 0.1);imshow(Iq);
    title('query');
    
    for jj = 1:1:10
        this_dbname = ImgList(ii).topNname{jj};
        Idb = imread(fullfile(db_dir, this_dbname));
        ultimateSubplot(6, 2, rem(jj-1, 5)+2, floor((jj-1)/5)+1, 0.1, 0.1);imshow(Idb);
        title(sprintf('score %.4f', ImgList(ii).topNscore(jj)));
    end
    
    keyboard;
end
