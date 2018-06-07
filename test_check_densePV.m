clear all;
close all;

[ params ] = setup_project_ht_WUSTL;

%image dir
query_dir = fullfile(params.data.dir, params.data.q.dir);
db_dir = fullfile(params.data.dir, params.data.db.cutout.dir);

%shortlist
% top100_matname = fullfile(params.output.dir, 'original_top100_shortlist.mat');
% load(top100_matname, 'ImgList');
% reranking_matname = fullfile(params.output.dir, 'densereranking_top100_shortlist.mat');
% load(reranking_matname, 'ImgList');
densepv_description = 'densePV_top10';
densepv_matname = fullfile(params.output.dir, sprintf('%s_shortlist.mat', densepv_description));
load(densepv_matname, 'ImgList');

% h1 = figure();set(h1, 'Position', [0 0 1600 600]);


for ii = 1:1:length(ImgList)
    
    this_qname = ImgList(ii).queryname;
    
    
    h1 = figure('Visible', 'off');set(h1, 'Position', [0 0 1600 600]);
%     figure(h1);
    Iq = imread(fullfile(query_dir, this_qname));
    ultimateSubplot(6, 3, 1, 1, 0.1, 0.1);imshow(Iq);
    title('query');
    ultimateSubplot(6, 3, 1, 2, 0.1, 0.1);imshow(Iq);
    title('query');
    ultimateSubplot(6, 3, 1, 3, 0.1, 0.1);imshow(Iq);
    title('query');
    drawnow;
    
    %db
    for jj = 1:1:5
        this_dbname = ImgList(ii).topNname{jj};
        Idb = imread(fullfile(db_dir, this_dbname));
        ultimateSubplot(6, 3, jj+1, 1, 0.1, 0.1);imshow(Idb);
        title(sprintf('score %.4f', ImgList(ii).topNscore(jj)));
        drawnow;
    end
    
    %synthesized view
    for jj = 1:1:5
        [~, this_dbbasename, ~] = fileparts(ImgList(ii).topNname{jj});
        this_synth_matname = fullfile(params.output.synth.dir, this_qname, [this_dbbasename, params.output.synth.matformat]);
        this_synth_results = load(this_synth_matname);
        
        ultimateSubplot(6, 3, jj+1, 2, 0.1, 0.1);imshow(this_synth_results.RGBpersp);
        title(sprintf('top %d synthesized', jj));drawnow;
        
        ultimateSubplot(6, 3, jj+1, 3, 0.1, 0.1);imagesc(this_synth_results.errmap);colormap('jet');axis image off;drawnow;
    end
    
    %savefig
    this_figdir = fullfile(params.output.qualitative.dir, densepv_description);
    if exist(this_figdir, 'dir') ~= 7
        mkdir(this_figdir);
    end
    this_figname = fullfile(this_figdir, [this_qname, params.output.qualitative.imgformat]);
    
    h1.PaperPositionMode = 'auto';
    saveas(h1, this_figname);
    close(h1);
    
    
end
