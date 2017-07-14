%% NEW START

ts = generate_ts_mpa1_testaudio;
data = mpa1_main(ts, 'fmri', 'biopac');

%% START without practice part

% ts = generate_ts_mpa1;
% data = mpa1_main(ts, 'fmri', 'biopac');
