% fine-align the slab

nfirst = 1369;
nlast = 1378;

% configure rough
rcrough.stack          = ['Revised_slab_' num2str(nfirst) '_' num2str(nlast) '_rough'];
rcrough.owner          ='flyTEM';
rcrough.project        = 'FAFB00_beautification';
rcrough.service_host   = '10.40.3.162:8080';
rcrough.baseURL        = ['http://' rcrough.service_host '/render-ws/v1'];
rcrough.verbose        = 1;

% configure fine alignment
rcfine.stack          = ['Revised_slab_' num2str(nfirst) '_' num2str(nlast) '_fine'];
rcfine.owner          ='flyTEM';
rcfine.project        = 'FAFB00_beautification';
rcfine.service_host   = '10.40.3.162:8080';
rcfine.baseURL        = ['http://' rcrough.service_host '/render-ws/v1'];
rcfine.verbose        = 1;

pm1.server = 'http://10.40.3.162:8080/render-ws/v1';
pm1.owner = 'flyTEM';
pm1.match_collection = 'FAFB_pm_2';

pm2.server = 'http://10.40.3.162:8080/render-ws/v1';
pm2.owner = 'flyTEM';
pm2.match_collection = 'Beautification_cross_sift_00';

pm3.server = 'http://10.40.3.162:8080/render-ws/v1';
pm3.owner = 'flyTEM';
pm3.match_collection = 'Beautification_cross_sift_dist_4_00';

pms = {pm1 pm2};

%% solve
% configure solver
opts.min_tiles = 25; % minimum number of tiles that constitute a cluster to be solved. Below this, no modification happens
opts.degree = 1;    % 1 = affine, 2 = second order polynomial, maximum is 3
opts.outlier_lambda = 1e2;  % large numbers result in fewer tiles excluded
opts.solver = 'backslash';%'pastix';%%'gmres';%'backslash';'pastix';

opts.pastix.ncpus = 8;
opts.pastix.parms_fn = '/nrs/flyTEM/khairy/FAFB00v13/matlab_production_scripts/params_file.txt';
opts.pastix.split = 1; % set to either 0 (no split) or 1

opts.matrix_only = 0;   % 0 = solve , 1 = only generate the matrix
opts.distribute_A = 1;  % # shards of A
opts.dir_scratch = '/scratch/goinac';

opts.min_points = 10;
opts.max_points = 100;
opts.nbrs = 5;
opts.xs_weight = 0.1;
opts.stvec_flag = 1;   % 0 = regularization against rigid model (i.e.; starting value is not supplied by rc)
opts.distributed = 0;

opts.lambda = 10.^(2);
opts.edge_lambda = 10^(2);
opts.A = [];
opts.b = [];
opts.W = [];

% % configure point-match filter
opts.filter_point_matches = 1;
opts.pmopts.NumRandomSamplingsMethod = 'Desired confidence';
opts.pmopts.MaximumRandomSamples = 3000;
opts.pmopts.DesiredConfidence = 99.8;
opts.pmopts.PixelDistanceThreshold = .1;

opts.verbose = 1;
opts.debug = 0;

[mL, err] = system_solve(nfirst, nlast, rcrough, pms, opts, rcfine);
disp(err);
