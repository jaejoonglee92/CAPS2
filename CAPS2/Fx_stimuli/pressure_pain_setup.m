function PP_int = pressure_pain_setup

% pressure_pain_setup

global t r; % pressure device udp channel

PP_int = {'0004', '0005', '0006', '0007'}; % kg/cm2
delete(instrfindall); %clear out old channels

try
    t=udp('localhost',61557); % open udp channels
    r=udp('localhost',61158,'localport', 61556);
    
    fopen(t);
    fopen(r);
    fwrite(t, '0005,o'); % open the remote channel
catch err
    % ERROR
    disp(err);
    disp(err.stack(1));
    disp(err.stack(2));
    disp(err.stack(end));
    fclose(t);
    fclose(r);
    abort_error;
end
end

