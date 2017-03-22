function solve_montages(start_z, end_z, fn)
% Intended for deployment: solve matrix system based on json input provided by fn

% read json input
sl = loadjson(fileread(fn));

if sl.verbose,
    kk_clock();
    disp(['Using input file: ' fn]);
    disp('Using solver options:');disp(sl.solver_options);
    disp('Using source collection:');disp(sl.source_collection);
    disp('Using target collection:');disp(sl.target_collection);
    disp('Using point-match collection:');disp(sl.source_point_match_collection);
end

if ~isfield(sl, 'disableValidation'), sl.disableValidation = 0;end

if sl.target_collection.initialize,
    if sl.verbose, disp('Initializing collection / Deleting existing');end
    delete_renderer_stack(sl.target_collection);  % delete existing collection if present
end

if ischar(start_z)
    start_z = str2double(start_z);
end
if ischar(end_z)
    end_z = str2double(end_z);
end

for z = start_z:end_z
    disp(z);
    sl.section_number = z; % same thing but messed up variable names later

    if sl.solver_options.use_peg
        if sl.verbose, disp('Solving montage using pegs');end


        tic;if sl.verbose, disp('-- Loading point matches');end
        [L, tIds, PM, pm_mx, sectionId_load, z_load]  = ...
            load_point_matches(sl.section_number,sl.section_number, sl.source_collection, ...
            sl.source_point_match_collection, 0, sl.solver_options.min_points, 0, sl.solver_options.max_points); % 
        toc
        if sl.filter_point_matches
            tic;if sl.verbose, disp('-- Filtering point matches');end
            pmfopts.NumRandomSamplingsMethod = 'Desired confidence';
            pmfopts.MaximumRandomSamples = 1000;
            pmfopts.DesiredConfidence = 99.9;
            pmfopts.PixelDistanceThreshold = 0.1;
            if sl.verbose, 
                disp('using point-match filter:');
                disp(pmfopts);
            end
            L.pm = filter_pm(L.pm, pmfopts);
            toc
        end

        tic;if sl.verbose, disp('-- Adding pegs');end
        L = add_translation_peggs(L, sl.solver_options.peg_npoints, sl.solver_options.peg_weight);
        toc
        tic;if sl.verbose, disp('-- Asserting one connected component');end
        [L, ntiles] = reduce_to_connected_components(L);
        L = L(1);
        toc
        tic;if sl.verbose, disp('-- Solving for rigid approximation');end
        sl.solver_options.distributed = 0;
        [Lr, errR, mL, is, it, Res]  = get_rigid_approximation(L, sl.solver_options.solver, sl.solver_options);
        toc
        tic;if sl.verbose, disp('-- Removing pegs');end
        %%% remove peggs and last tile
        last_tile = numel(Lr.tiles);
        del_ix = find(Lr.pm.adj(:,2)==last_tile);
        Lr.pm.M(del_ix,:)  = [];
        Lr.pm.adj(del_ix,:) = [];
        Lr.pm.W(del_ix) = [];
        Lr.pm.np(del_ix) = [];
        Lr.tiles(end) = [];
        Lr = update_adjacency(Lr);
        toc
        tic;if sl.verbose, disp('-- Solving for affine');end

        [mL, err1, Res1, A, b, B, d, W, K, Lm, xout, LL2, U2, tB, td,...
          invalid] = solve_affine_explicit_region(Lr, sl.solver_options);
        toc  

    else
        tic;if sl.verbose, disp('Solving slab without pegs --- each connected component by itself');end
        [mL, pm_mx, err, R, ~, ntiles, PM, sectionId_load, z_load] = ...
            solve_slab(sl.source_collection, sl.source_point_match_collection, ...
            sl.section_number, sl.section_number, [], sl.solver_options);
        toc

    end
    if sl.verbose, disp('-- Ingesting section into collection');end
    resp = ingest_section_into_LOADING_collection(mL, sl.target_collection,...
        sl.source_collection, sl.temp_dir, 1, sl.disableValidation); % ingest
end
if sl.target_collection.complete,
    if sl.verbose, disp('Completing collection');end
    resp = set_renderer_stack_state_complete(sl.target_collection);  % set to state COMPLETE
end

if sl.verbose
    disp(resp);
    disp('Finished:');
    kk_clock();
end






%% ingest into Renderer database (optional);
