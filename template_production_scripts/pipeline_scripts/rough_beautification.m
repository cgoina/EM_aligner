function rough_beautification(nfirst, nlast)

if ischar(nfirst)
    nfirst = str2double(nfirst);
end
if ischar(nlast)
    nlast = str2double(nlast);
end

% configure source
rcsource.stack          = 'v12_acquire_merged';
rcsource.owner          ='flyTEM';
rcsource.project        = 'FAFB00';
rcsource.service_host   = '10.40.3.162:8080';
rcsource.baseURL        = ['http://' rcsource.service_host '/render-ws/v1'];
rcsource.verbose        = 1;

% configure rough
%rcmontage.stack          = ['Revised_slab_' num2str(nfirst) '_' num2str(nlast) '_montage'];
%rcmontage.owner          ='flyTEM';
%rcmontage.project        = 'FAFB00_beautification';
%rcmontage.service_host   = '10.40.3.162:8080';
%rcmontage.baseURL        = ['http://' rcmontage.service_host '/render-ws/v1'];
%rcmontage.verbose        = 1;

rcmontage.stack          = 'Revised_slab_5639_5647_x_80000_193000_y_0_84000';
rcmontage.owner          ='flyTEM';
rcmontage.project        = 'goinac_test';
rcmontage.service_host   = '10.40.3.162:8080';
rcmontage.baseURL        = ['http://' rcmontage.service_host '/render-ws/v1'];
rcmontage.verbose        = 1;

% configure rough
%rcrough.stack          = ['Revised_slab_' num2str(nfirst) '_' num2str(nlast) '_rough'];
%rcrough.owner          ='flyTEM';
%rcrough.project        = 'FAFB00_beautification';

rcrough.stack          = ['Revised_slab_' num2str(nfirst) '_' num2str(nlast) '_x_80000_193000_y_0_84000_rough'];
rcrough.owner          ='flyTEM';
rcrough.project        = 'FAFB00_beautification';
rcrough.service_host   = '10.40.3.162:8080';
rcrough.baseURL        = ['http://' rcrough.service_host '/render-ws/v1'];
rcrough.verbose        = 1;

dir_rough_intermediate_store = '/nrs/flyTEM/khairy/FAFB00v13/montage_scape_pms';% intermediate storage of files
dir_store_rough_slab = '/nrs/flyTEM/khairy/FAFB00v13/matlab_slab_rough_aligned';
scale  = 0.05;

finescale = 0.4;
nbrs = 3;
point_pair_thresh    = 5;

%% generate rough alignment
% configure montage-scape point-match generation
ms.service_host                 = rcmontage.service_host;
ms.owner                        = rcmontage.owner;
ms.project                      = rcmontage.project;
ms.stack                        = rcmontage.stack;
ms.fd_size                      = '10'; % '8'
ms.min_sift_scale               = '0.2';%'0.55';
ms.max_sift_scale               = '1.0';
ms.steps                        = '3';
ms.similarity_range             = '15';
ms.skip_similarity_matrix       = 'y';
ms.skip_aligned_image_generation= 'y';
ms.base_output_dir              = '/nrs/flyTEM/spark_montage/beautification';
ms.script                       = '/groups/flyTEM/home/khairyk/EM_aligner/renderer_api/generate_montage_scape_point_matches.sh';%'../unit_tests/generate_montage_scape_point_matches_stub.sh'; %
ms.number_of_spark_nodes        = '2.0';
ms.first                        = num2str(nfirst);
ms.last                         = num2str(nlast);
ms.scale                        = num2str(scale);
ms.run_dir                      = ['Slab_' ms.first '_' ms.last '_scale_' ms.scale];

[L2, needs_correction, pmfn, zsetd, zrange, t, dir_spark_work, cmd_str, fn_ids, ...
    target_solver_path, target_ids, target_matches, target_layer_images] =  ...
    ...
    solve_rough_slab(dir_store_rough_slab, rcmontage, ...
    rcmontage, rcrough, ms, nfirst,...
    nlast, dir_rough_intermediate_store, ...
    1);
