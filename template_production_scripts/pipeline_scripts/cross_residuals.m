nfirst = 1369;
nlast = 1378;

% Options including whether to plot or not
dopts.nbrs = 0;
dopts.min_points = 3;
dopts.show_deformation_summary = 0;
dopts.dir_scratch = '/scratch/goinac';
dopts.xs_weight = 0.5;
dopts.min_points = 10;
dopts.max_points = 100;
dopts.number_of_cross_sections = 4;
dopts.plot_cross_section_residuals = true;
 
% Renderer collection
newrc.baseURL = 'http://10.37.5.60:8080/render-ws/v1';
newrc.owner = 'flyTEM';
newrc.project = 'FAFB00_beautification';
newrc.stack = ['Revised_slab_' num2str(nfirst) '_' num2str(nlast) '_fine'];
newrc.verbose = 1;
 
oldrc.baseURL = 'http://10.37.5.60:8080/render-ws/v1';
oldrc.owner = 'flyTEM';
oldrc.project = 'FAFB00';
oldrc.stack = 'v13_align';
oldrc.verbose = 1;

% Point match collection
pm1.server = 'http://10.40.3.162:8080/render-ws/v1';
pm1.owner = 'flyTEM';
pm1.match_collection = 'FAFB_pm_2';

pm2.server = 'http://10.40.3.162:8080/render-ws/v1';
pm2.owner = 'flyTEM';
pm2.match_collection = 'Beautification_cross_sift_00';

pm3.server = 'http://10.40.3.162:8080/render-ws/v1';
pm3.owner = 'flyTEM';
pm3.match_collection = 'Beautification_cross_sift_dist_4_00';

pms = [pm1 pm2];

generate_cross_section_point_match_residuals(oldrc, nfirst, nlast, pms, dopts);
generate_cross_section_point_match_residuals(newrc, nfirst, nlast, pms, dopts);
