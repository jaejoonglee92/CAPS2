%% RUN 1-4:

for kk = 1%:50
    ts = generate_ts_cps;
    
    t = zeros(1,4);
    for i = 1:4
        for j = 1:numel(ts{i})
            t(i) = t(i) + ...
                str2double(ts{i}{j}{3}) + str2double(ts{i}{j}{6}) + ...
                str2double(ts{i}{j}{7});
        end
    end
    
    t = t + 13;
    tr(kk) = max(ceil((t*1000)/473));
    tt(kk) = max(t/60);
    %fprintf('\n# TR = %d, Total time = %f minutes', tr, tt);
    
%     % RUN 5-8
%     
%     t2 = zeros(1,4);
%     for i = 5:8
%         for j = 1:numel(ts{i})
%             t2(i-4) = t2(i-4) + ...
%                 str2double(ts{i}{j}{3}) + str2double(ts{i}{j}{5}) + ...
%                 str2double(ts{i}{j}{6}) + str2double(ts{i}{j}{7}); 
%             
%         end
%     end
%     
%     t2 = t2 + 13;
%     %(t2*1000)/473
%     tr2(kk) = max(ceil((t2*1000)/473));
%     tt2(kk) = max(t2/60);
%     % fprintf('\n# TR = %d, Total time = %f minutes\n', tr2, tt2);
end

fprintf('\n# TR = %d, Total time = %f minutes', max(tr), max(tt));
fprintf('\n# TR = %d, Total time = %f minutes\n', max(tr2), max(tt2));
