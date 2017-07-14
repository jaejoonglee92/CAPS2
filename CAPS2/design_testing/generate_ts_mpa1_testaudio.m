function ts = generate_ts_mpa1_testaudio

% ts = generate_ts_mpa1_testaudio

rng('shuffle');

S1{1} = repmat({'AU'}, 8, 1);
S1{2} = repmat({'LV1'; 'LV2'; 'LV3'; 'LV4'}, 2, 1);
S1{3} = repmat({'0010'}, 8, 1);
S1{4} = repmat({'overall_avoidance'}, 8, 1);
S1{5} = repmat({'linear_avoidance'}, 8, 1);
S1{6} = repmat({'0'}, 8, 1);
S1{7} = repmat({'3', '7'; '5', '5'; '7', '3'}, 3, 1);

for k = 1:numel(S1)
    for i = 1 %:4
        if k < 7
            temp = S1{k}(randperm(8));
            for j = 1:8
                ts{i}{j}(k) = temp(j);
            end
        else
            temp = S1{k}(randperm(8),:);
            for j = 1:8
                ts{i}{j}(k) = temp(j,1);
                ts{i}{j}(k+1) = temp(j,2);
            end
        end
    end
end

end