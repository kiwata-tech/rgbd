clear all;
close all;

[ params ] = setup_project_ht_WUSTL;

%1. retrieval
ht_retrieval;

%2. reranking by dense feature matching
ht_top100_reranking;



