function [t, r] = pressure_pain_setup

% pressure_pain_setup

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

