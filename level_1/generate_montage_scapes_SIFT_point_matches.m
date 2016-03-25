function [Lin] = generate_montage_scapes_SIFT_point_matches(ms)
% Depends on : 
%               - spark installation at Janelia
%               - script (provided in "external" folder to generate montage scapes and calculate point-matches using spark 
%                 (code-base: Stephan Saalfeld, scritp/packaged Eric Trautman)
% Input:
%               - ms: a struct with fields specifying spark job and sift parameters. For example:
% ms.service_host                 = rctarget_montage.service_host;
% ms.owner                        = rctarget_montage.owner;
% ms.project                      = rctarget_montage.project;
% ms.stack                        = rctarget_montage.stack;
% ms.first                        = num2str(nfirst);
% ms.last                         = num2str(nlast);
% ms.fd_size                      = '8';
% ms.min_sift_scale               = '0.55';
% ms.max_sift_scale               = '1.0';
% ms.steps                        = '3';
% ms.scale                        = '0.05';
% ms.similarity_range             = '3';
% ms.skip_similarity_matrix       = 'y';
% ms.skip_aligned_image_generation= 'y';
% ms.base_output_dir              = '/nobackup/flyTEM/spark_montage';
% ms.run_dir                      = ['scale_' ms.scale];
% ms.script                       = '../external/generate_montage_scape_point_matches.sh';
%
%
% Author: Khaled Khairy: Janelia Research Campus. Copyright 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
check_input(ms);

%% clean up any previous jobs
dir_spark_work = [ms.base_output_dir '/' ms.project '/' ms.stack  '/' ms.run_dir];
kk_mkdir(dir_spark_work);
cmd_str = [ms.script ' ' ms.service_host ' ' ms.owner ' ' ms.project ' '...
           ms.stack ' ' ms.first ' ' ms.last ' ' ms.fd_size ' ' ...
           ms.min_sift_scale ' ' ms.max_sift_scale ' ' ms.steps ' ' ...
           ms.scale ' ' ms.similarity_range ' ' ms.skip_similarity_matrix ' ' ...
           ms.skip_aligned_image_generation ' ' ms.base_output_dir ' ' ...
           ms.run_dir];

[a, resp_str] = system(cmd_str);
disp(resp_str)
%% wait for files to finish generating
f = dir([dir_spark_work '/solver_*']);
dir_solver = [dir_spark_work '/' f.name];
fn_matches = [dir_solver '/matches.txt'];
while exist(fn_matches,'file')~=2
    f = dir([dir_spark_work '/solver_*']);
    dir_solver = [dir_spark_work '/' f.name];
    fn_matches = [dir_solver '/matches.txt'];
    if ~isempty(f), disp(['Waiting for file: ' dir_solver '/matches.txt']);
    else
        disp(['Waiting for file: ' dir_solver '*/matches.txt']);
    end
    pause(30);
end


fn_ids     = [dir_solver '/ids.txt'];

%% read montage-scape image metainformation from fn_ids and point-matches
disp('Reading data ...');tic
fid = fopen(fn_ids,'r');if fid==-1, error('Failed to open stack layout file.');end
IDS     = textscan(fid,'%u64%s', 'delimiter', '');
fclose(fid);
%%% typecast the uint64 to double to get actual z-values
z = typecast(IDS{1}, 'double');
IDS{1} = double(IDS{1});
%% read point matches
fid = fopen(fn_matches,'r');if fid==-1, error('Failed to open stack layout file.');end
MATCHES = textscan(fid,'%n%n%n%n%n%n', 'delimiter', '\t');
fclose(fid);

%% generate Msection object with one tile/layer. each tile is a montage scape

tiles = tile;
parfor tix = 1:numel(IDS{1})
    t = tile;
    t.z = tix;
    t.id = IDS{1}(tix);
    t.path = IDS{2}{tix};
    t.rot = 0;
    t.fetch_local = 1;
    tiles(tix) = t;
end
L = Msection(tiles);

%% generate point-matches--- pairs variable
delta = 0;
pairs = [ones(numel(MATCHES{1}),1) MATCHES{1}(:) MATCHES{2}(:)+delta MATCHES{3}(:)+delta ones(numel(MATCHES{1}),1) MATCHES{4}(:) MATCHES{5}(:)+delta MATCHES{6}(:)+delta];
options.verbose = 0;
options.minpmblock = 0;
options.minpmblock_cross = 0;

%% concatenate point_matches
[Lin] = pairs_to_pm(L, options, pairs);
%% add a weights vector to pm struct
w = [];
W = cell(size(Lin.pm.adj,1),1);
for ix = 1:length(W)
   w = 1/abs(z(Lin.pm.adj(ix,1))-z(Lin.pm.adj(ix,2))); 
   npoints = size(Lin.pm.M{ix,1},1);
   W{ix} = ones(npoints,1) * w;
end
Lin.pm.W = W;
%% reduce point-matches to next nb neighbors
delix = [];
counter = 1;
for pix = 1:size(Lin.pm.M,1)
    adj = Lin.pm.adj(pix,:);
    if abs(adj(1)-adj(2))>ms.similarity_range
        delix(counter) = pix;
        counter = counter + 1;
    end
end
Lin.pm.W(delix) = [];
Lin.pm.adj(delix,:) = [];
Lin.pm.M(delix,:) = [];
%Lin = update_adjacency(Lin);
pm = Lin.pm;


%% %%%%%%%%%%%%%%%%%%%%%%%%%
function check_input(ms)
if exist(ms.script, 'file')~=2, 
    error('Invalid script path');
end
























