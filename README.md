# InLoc demo on WUSTL

This toolkit provides scalable indoor visual localization (InLoc) demo on WUSTL dataset and evaluation with our manually annotated reference poses. 
Please send bug reports and suggestions to <htaira@ctrl.titech.ac.jp>, <torii@sc.e.titech.ac.jp> . 

## Installation

* Install dependencies

    * Inpaint nans (<https://jp.mathworks.com/matlabcentral/fileexchange/4551-inpaint-nans?requestedDomain=www.mathworks.com>)
    * vlfeat (<http://www.vlfeat.org/>)
    * matconvnet (<http://www.vlfeat.org/matconvnet/>)
    * yael (<http://yael.gforge.inria.fr/#>)

    Install all dependencies and modify `` startup.m `` to add path to them. 

* Compile mex function
    
    First, install ceres solver: 

    ```
    git clone https://ceres-solver.googlesource.com/ceres-solver
    cd ceres-solver
    mkdir build
    cd build
    cmake .. 
    make
    sudo make install
    ```

    Then modify paths in `` functions/ht_pnp_function/make_PnP_mex.m `` and execute it in Matlab. 

## Quick Start

* Download WUSTL dataset

* Download pre-trained CNN model from <http://www.di.ens.fr/willow/research/netvlad/>

* Modify `` setup_project_ht_WUSTL.m ``
    * line 8: `` params.data.dir = '/path/to/dataset'; ``

* Execute `` startup `` and `` inloc_demo `` in Matlab

## Details: Run InLoc with your own features and image retrieval

* Prepare your own features, image lists, and retrieval scores

    The toolkit requires multiple .mat files 
    containing list of database / query images, initial image retireval scores, and dense features for each image  as input. 
    All of them should be in one directory such as `` inputs ``. 

    * Image list

        `` query_imgnames_all.mat `` contains string cell array named `` query_imgnames_all `` that consists of image names of queries. 

        ```
        query imgnames_all = 
        {'IMG_0731.JPG', 
        'IMG_0732.JPG', 
        ...
        'IMG_1113.JPG', 
        'IMG_1114.JPG'};
        ```

        Similary, `` cutout_imgnames_all.mat `` contains string cell array named `` cutout_imgnames_all ``. 
        It consists of paths of cutout images from `` database/cutouts/ `` directory in WUSTL dataset. 

        ```
        cutout_imgnames_all = 
        {'CSE3/000/cse_cutout_000_0_0.jpg',
        'CSE3/000/cse_cutout_000_0_30.jpg', 
        ...
        };
        ```

    * Image retireval scores

        `` scores.mat `` contains single numeric array named `` score ``. 
        It contains the similarity score between query in each row and database in each column. 
        Indices of queries and database should follow indices defined by image lists. 

    * Features

        Dense features for queries and databases are in ``inputs/features/query/iphone7/XXX.features.dense.mat `` and `` inputs/features/database/cutouts/XXX.features.dense.mat ``.  
        "XXX" is the image name or path in image list. 
        Each file contains 1x5 cell array named `` cnn `` that consists of multiple-level CNN intermediate feature map for each cell. 
        We use 3rd and 5th layers for our coarse-to-fine matching, so we recommend to keep the other cells empty to eliminate loading time. 
        If there are no pre-computed features, our tool computes dense features by using model pre-trained as the part of NetVLAD. 

* Modify `` setup_project_ht_WUSTL.m ``

    In our demo, `` setup_project_ht_WUSTL.m `` is firstly called and defines all paths and file name formats. 
    If you want to change input/output directories or file names format, modify description in the function. 

    setup_project_ht_WUSTL.m line 32-49: 

    ```
    %input
    params.input.dir = 'inputs';
    params.input.dblist_matname = fullfile(params.input.dir, 'cutout_imgnames_all.mat');%string cell containing cutout image names
    params.input.qlist_matname = fullfile(params.input.dir, 'query_imgnames_all.mat');%string cell containing query image names
    params.input.score_matname = fullfile(params.input.dir, 'scores.mat');%retrieval score matrix
    params.input.feature.dir = fullfile(params.input.dir, 'features');
    params.input.feature.db_matformat = '.features.dense.mat';
    params.input.feature.q_matformat = '.features.dense.mat';


    %output
    params.output.dir = 'outputs';
    params.output.gv_dense.dir = fullfile(params.output.dir, 'gv_dense');%dense matching results (directory)
    params.output.gv_dense.matformat = '.gv_dense.mat';%dense matching results (file extention)
    params.output.pnp_dense_inlier.dir = fullfile(params.output.dir, 'PnP_dense_inlier');%PnP results (directory)
    params.output.pnp_dense.matformat = '.pnp_dense_inlier.mat';%PnP results (file extention)
    params.output.synth.dir = fullfile(params.output.dir, 'synthesized');%View synthesis results (directory)
    params.output.synth.matformat = '.synth.mat';%View synthesis results (file extention)

    ```