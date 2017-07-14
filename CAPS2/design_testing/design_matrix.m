function [X, r, vifs, XX] = design_matrix(ts, doplot)

% [X, r, vifs, XX] = design_matrix(ts, doplot)
% 
% example:
% ts = generate_ts_mpa1;
% [X, vifs] = design_matrix(ts, 1);

% rating_dur = random between 4 and 10
rating_dur = randi(10000,1,100000);
rating_dur = rating_dur(rating_dur>4000);
% clear onsets_*;
k = 0;
for i = 1:numel(ts)
    for j = 1:numel(ts{i})
        
        if j == 1
            ons = 1.959; % disdaq 17 images (= 8 seconds)
        end
        
        if str2double(ts{i}{j}{6}) ~= 0
            onsets_cue{i}(j,1) = ons;
            ons = ons + str2double(ts{i}{j}{6});
            onsets_cue_dur{i}(j,1) = str2double(ts{i}{j}{6});
        end
        
        if i < 5
            if strcmp(ts{i}{j}{1}, 'PP')
                onsets_stim.PP{i}(j,1) = ons;
                pmod_stim.PP{i}(j,1) = str2num(ts{i}{j}{2}(3));
            else
                onsets_stim.AU{i}(j,1) = ons;
                pmod_stim.AU{i}(j,1) = str2num(ts{i}{j}{2}(3));
            end
        else
            if strcmp(ts{i}{j}{9}, 'HOW BAD?')
                onsets_stim.BAD{i}(j,1) = ons;
            elseif strcmp(ts{i}{j}{9}, 'HOW MUCH PRESSURE?')
                onsets_stim.PRE{i}(j,1) = ons;
            else
                onsets_stim.PAS{i}(j,1) = ons;
            end
        end
        ons = ons + 10 + str2double(ts{i}{j}{7}); % jitter
        
        if i < 5
            onsets_rating{i}(j,1) = ons;
            k = k + 1;
            ons = ons + rating_dur(k)/1000 + str2double(ts{i}{j}{8}); % jitter
            onsets_rating_dur{i}(j,1) = rating_dur(k)/1000;
        else
            if ~strcmp(ts{i}{j}{9}, 'NO RATING')
                onsets_rating{i}(j,1) = ons;
                k = k + 1;
                ons = ons + rating_dur(k)/1000 + str2double(ts{i}{j}{8}); % jitter
                onsets_rating_dur{i}(j,1) = rating_dur(k)/1000;
            else
                ons = ons + str2double(ts{i}{j}{8}); % jitter
            end
        end
    end
end

f = fields(onsets_stim);
for i = 1:numel(f)
    eval(['temp = onsets_stim.' f{i} ';']);
    for j = 1:numel(temp)
        temp{j}(temp{j}==0) = [];
    end
    eval(['onsets_stim.' f{i} '= temp;']);
end

f = fields(pmod_stim);
for i = 1:numel(f)
    eval(['temp = pmod_stim.' f{i} ';']);
    for j = 1:numel(temp)
        temp{j}(temp{j}==0) = [];
    end
    eval(['pmod_stim.' f{i} '= temp;']);
end

for i = 1:numel(onsets_rating)
    onsets_rating{i}(onsets_rating{i}==0) = [];
    onsets_rating_dur{i}(onsets_rating_dur{i}==0) = [];
end

for i = 1:4
    X{i} = onsets2fmridesign_wani({[onsets_stim.PP{i} repmat(10,size(onsets_stim.PP{i}))] ...
        [onsets_stim.AU{i} repmat(10,size(onsets_stim.AU{i}))] ...
        [onsets_rating{i} onsets_rating_dur{i}]}, .475, (1036-17).*.475, spm_hrf(1), []);
    r{i} = corr(X{i}(:,1:3));
end

for i = 5:8
    X{i} = onsets2fmridesign_wani({[onsets_cue{i} onsets_cue_dur{i}] ...
        [onsets_stim.PRE{i} repmat(10,size(onsets_stim.PRE{i}))] ...
        [onsets_stim.BAD{i} repmat(10,size(onsets_stim.BAD{i}))] ...
        [onsets_stim.PAS{i} repmat(10,size(onsets_stim.PAS{i}))] ...
        [onsets_rating{i} onsets_rating_dur{i}]}, .475, (799-17).*.475, spm_hrf(1), []);
    r{i} = corr(X{i}(:,1:5));
end

XX = blkdiag(X{:});
XX = XX(:,[find(~any(XX==1)) find(any(XX==1))]);
vifs = getvif(XX, 0);
vifs = vifs(:,1:sum(~any(XX==1)));

if doplot
    % my version, but Tor's is much better
    %     figure('color', 'w');
    %     subplot(1,2,1);
    %     imagesc(XX);
    %     colormap gray;
    %     colorbar;
    %     title('design matrix', 'fontsize', 20);
    %     xlabel('regressors', 'fontsize', 20);
    %     ylabel('TRs', 'fontsize', 20);
    %
    %     subplot(1,2,2);
    %     plot(vifs, '-o');
    %     title('vifs', 'fontsize', 20);
    %     xlabel('regressors', 'fontsize', 20);
    %     ylabel('vifs', 'fontsize', 20);
    
    create_figure('VIFs', 1, 3);
    subplot(1, 3, 1);
    imagesc(zscore(XX)); set(gca, 'YDir', 'Reverse');
    colormap gray
    title('Full Design Matrix (zscored)');
    axis tight
    drawnow
    
    wh_cols = 1:32;
    
    subplot(1, 3, 2)
    imagesc(zscore(XX(:,1:32))); set(gca, 'YDir', 'Reverse');
    colormap gray
    title('Design Matrix: Of-interest (zscored)');
    axis tight
    drawnow
    
    allvifs = getvif(XX(:, wh_cols));
    
    subplot(1, 3, 3);
    plot(allvifs, 'ko', 'MarkerFaceColor', [1 .5 0]);
    ylabel('Variance inflation factor'); xlabel('Predictor number');
    plot_horizontal_line(1, 'k');
    plot_horizontal_line(2, 'b--');
    plot_horizontal_line(4, 'r--');
    plot_horizontal_line(8, 'r-');
    title('VIFs for ONLY of-interest regs');
end

end