function export_montage_MET_poly(mL, fn)
% input is an Msection object with all tiles transformed using second or third-order
% polynomials
% exports the full set in one file to be ingested by the Renderer
% ordered list assumed by the Renderer:
% Ordered List of Polynomial Terms for each dimension for the RENDERER
% 
%     1
%     x
%     y (end of 1st order)
%     x2
%     xy
%     y2 (end of 2nd order)
% first u and then v comma-separated need to be exported
% HOWEVER: for MATLAB the definition is
% u = a1 + a2 * x + a3 * y + a4 * xy + a5 * x^2 + a6 * y^2
% i.e. we need to be careful to switch A(4) and A(5)
% Author: Khaled Khairy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% mL = get_bounding_box(mL);
% dx = mL.box(1);
% dy = mL.box(3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% do the actual export here
%%% pay attention to the polynomial convention of Matlab's polynomial vs
%%% the one the Renderer uses (below) from this Website (http://bishopw.loni.ucla.edu/AIR5/2Dnonlinear.html#default):
% 1
% x
% y (end of 1st order)
% x2
% xy
% y2 (end of 2nd order)
% x3
% x2y
% xy2
% y3 (end of 3rd order)
% x4
% x3y
% x2y2
% xy3
% y4 (end of 4th order)
err = 0;
fid = fopen(fn,'w');
for tix = 1:numel(mL.tiles)
    if strcmp(class(mL.tiles(tix).tform), 'images.geotrans.PolynomialTransformation2D')
        if mL.tiles(tix).state>=1
            if mL.tiles(tix).tform.Degree==2
                fprintf(fid,'%d\t%s\t%d\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\n',...
                    mL.tiles(tix).z,...
                    mL.tiles(tix).renderer_id, ...
                    12, ...
                    ...
                    mL.tiles(tix).tform.A(1), ...
                    mL.tiles(tix).tform.A(2), ...
                    mL.tiles(tix).tform.A(3), ...
                    mL.tiles(tix).tform.A(5), ...
                    mL.tiles(tix).tform.A(4), ...
                    mL.tiles(tix).tform.A(6), ...
                    ...
                    mL.tiles(tix).tform.B(1), ...
                    mL.tiles(tix).tform.B(2), ...
                    mL.tiles(tix).tform.B(3), ...
                    mL.tiles(tix).tform.B(5), ...
                    mL.tiles(tix).tform.B(4), ...
                    mL.tiles(tix).tform.B(6));
            elseif mL.tiles(tix).tform.Degree==3
                fprintf(fid,'%d\t%s\t%d\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\n',...
                    mL.tiles(tix).z,...
                    mL.tiles(tix).renderer_id, ...
                    20, ...
                    ...
                    mL.tiles(tix).tform.A(1), ...
                    mL.tiles(tix).tform.A(2), ...
                    mL.tiles(tix).tform.A(3), ...
                    mL.tiles(tix).tform.A(5), ...
                    mL.tiles(tix).tform.A(4), ...
                    mL.tiles(tix).tform.A(6), ...
                    mL.tiles(tix).tform.A(9), ...    % x^3
                    mL.tiles(tix).tform.A(7), ...    % x^2 y
                    mL.tiles(tix).tform.A(8), ...    % x   y^2
                    mL.tiles(tix).tform.A(10), ...   %     y^3
                    ...
                    mL.tiles(tix).tform.B(1), ...
                    mL.tiles(tix).tform.B(2), ...
                    mL.tiles(tix).tform.B(3), ...
                    mL.tiles(tix).tform.B(5), ...
                    mL.tiles(tix).tform.B(4), ...
                    mL.tiles(tix).tform.B(6), ...
                    mL.tiles(tix).tform.B(9), ...    % x^3
                    mL.tiles(tix).tform.B(7), ...
                    mL.tiles(tix).tform.B(8), ...
                    mL.tiles(tix).tform.B(10));
                
            end
        end
    else
        err = err+1;
    end
end
fclose(fid);
if err,
    warning( [num2str(err) ' tiles do not have polynomial transformation ---- affine?']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % fid = fopen(fn,'w');
% % for tix = 1:numel(mL.tiles)
% %     if mL.tiles(tix).state>=1
% %         if mL.tiles(tix).tform.Degree==2
% %         fprintf(fid,'%d\t%s\t%d\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%d\t%d\t%d\t%s\t%d\n',...
% %             mL.tiles(tix).z,...
% %             mL.tiles(tix).renderer_id, ...
% %             1, ...
% %             ...
% %             mL.tiles(tix).tform.A(1), ...
% %             mL.tiles(tix).tform.A(2), ...
% %             mL.tiles(tix).tform.A(3), ...
% %             mL.tiles(tix).tform.A(5), ...
% %             mL.tiles(tix).tform.A(4), ...
% %             mL.tiles(tix).tform.A(6), ...
% %             ...
% %             mL.tiles(tix).tform.B(1), ...
% %             mL.tiles(tix).tform.B(2), ...
% %             mL.tiles(tix).tform.B(3), ...
% %             mL.tiles(tix).tform.B(5), ...
% %             mL.tiles(tix).tform.B(4), ...
% %             mL.tiles(tix).tform.B(6), ...
% %             ...
% %             mL.tiles(tix).col, ...
% %             mL.tiles(tix).row, ...
% %             mL.tiles(tix).cam, ...
% %             mL.tiles(tix).path,...
% %             mL.tiles(tix).temca_conf );
% %         elseif mL.tiles(tix).tform.Degree==3
% %             fprintf(fid,'%d\t%s\t%d\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%d\t%d\t%d\t%s\t%d\n',...
% %             mL.tiles(tix).z,...
% %             mL.tiles(tix).renderer_id, ...
% %             1, ...
% %             ...
% %             mL.tiles(tix).tform.A(1), ...
% %             mL.tiles(tix).tform.A(2), ...
% %             mL.tiles(tix).tform.A(3), ...
% %             mL.tiles(tix).tform.A(5), ...
% %             mL.tiles(tix).tform.A(4), ...
% %             mL.tiles(tix).tform.A(6), ...
% %             mL.tiles(tix).tform.A(9), ...    % x^3
% %             mL.tiles(tix).tform.A(7), ...    % x^2 y
% %             mL.tiles(tix).tform.A(8), ...    % x   y^2
% %             mL.tiles(tix).tform.A(10), ...   %     y^3
% %             ...
% %             mL.tiles(tix).tform.B(1), ...
% %             mL.tiles(tix).tform.B(2), ...
% %             mL.tiles(tix).tform.B(3), ...
% %             mL.tiles(tix).tform.B(5), ...
% %             mL.tiles(tix).tform.B(4), ...
% %             mL.tiles(tix).tform.B(6), ...
% %             mL.tiles(tix).tform.B(9), ...    % x^3
% %             mL.tiles(tix).tform.B(7), ...
% %             mL.tiles(tix).tform.B(8), ...
% %             mL.tiles(tix).tform.B(10), ...
% %             ...
% %             mL.tiles(tix).col, ...
% %             mL.tiles(tix).row, ...
% %             mL.tiles(tix).cam, ...
% %             mL.tiles(tix).path,...
% %             mL.tiles(tix).temca_conf );
% % 
% %         end
% %     end
% % end
% % fclose(fid);
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

