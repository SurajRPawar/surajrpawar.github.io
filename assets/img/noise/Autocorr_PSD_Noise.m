%--------------------------------------------------------------------------
% Calculating the Autocorrelation and Power spectral density of white noise
% and colored noise (first order Markov process)
%
% Useful links -> https://www.gaussianwaves.com/2013/11/simulation-and-analysis-of-white-noise-in-matlab/
%--------------------------------------------------------------------------

close all; clear all; clc;

%% ---------------------- User Inputs -------------------------------------
    % White noise characteristics
        Q = 2;          % White noise strength
        tf = 5;         % Length of signal in terms of seconds
        
    % First order Markov Process
        T = 0.02;       % Exponential time constant
        
    % Frequency
        dt = 0.001;     % Step time for euler integration of first order Guass
                        % markov process dynamics (s)    
                            
%--------------------------------------------------------------------------

%% Common parameters
    Fs = 1/dt;                                % Sampling frequency (Hz)
    L = floor(tf/dt);                         % Number of samples     
    t = [0:dt:tf-dt];                            % Time vector (s)
    fprintf('Desired 1/e point for colored noise is %.2f Hz\n',(1/T));
    
%% White noise    
    wn = sqrt(Q)*randn(1,L);                  % Generate white noise sequence
    [c_wn,lags_wn] = xcorr(wn,'biased');      % Autocorrelation of white noise sequence 
    N = numel(c_wn);                          % Number of samples in autocorrelation
    fft_c_wn = fft(c_wn);                     % FFT of biased autocorrelation
    fft_c_wn = fftshift(fft_c_wn);            % Centered FFT
    psd_wn = abs(fft_c_wn);                   % Power Spectral Density
    freq = Fs*[-N/2: N/2 - 1]./N;             % Frequency scale (Hz)
    mean_psd = mean(psd_wn);                  % Mean value of PSD. Should be Q (White noise strength)
    
    figure;
    sgtitle('White Noise');
    subplot(3,1,1);
    plot(t,wn);
    ylabel('wn'); xlabel('Time (s)');
    legend('White Noise');
    
    subplot(3,1,2);
    plot(lags_wn*dt,c_wn,'.--');    
    legend('Autocorrelation');
    ylabel('Quantity^2'); xlabel('Lag (s)');
    
    subplot(3,1,3);
    hold on;
    plot(freq,psd_wn,'.');
    plot(freq,mean_psd*ones(size(psd_wn)),'LineWidth',2);
    hold off;
    legend('Power Spectrum','Mean');    
    ylabel('Quantity^2/Hz'); xlabel('Freq (Hz)');
       
%% Exponentially correlated noise
    
    % Brownian motion
        dbeta = sqrt(Q*dt)*randn(1,L);

    % Simulation
    % Euler integration to get exponentially correlated noise, 'M'
        M = zeros(1,L);
        fprintf('Beginning Euler (Ito) integration\n'); tic;
        for i = 2:L
            dM = (-M(i-1)/T)*dt + dbeta(i-1);
            M(i) = M(i-1) + dM;
        end
        fprintf('Completed Euler (Ito) integration in %.2f sec\n',toc);     
    
    % Noise characteristics
        sigma2 = Q*T/2;
        
    % Theoretical Autocorrelation
        lags_exp_thr = [-tf:dt:tf];
        c_exp_thr = sigma2*exp(-abs(lags_exp_thr)/T);   % Autocorrelation
        
    % Theoretical Power Spectral Density
        w_Hz = [-500:0.1:500];   % (Hz)
        w_rad = 2*pi*w_Hz;       % {rad}
        psd_exp_thr = 2*sigma2*T./((T*w_rad).^2 + 1);   % Power spectral density (Quantity^2)/Hz
        
    % Numerical autocorrelation and PSD   
        [c_exp,lags_exp] = xcorr(M,'biased');           % Autocorrelation
        N = numel(c_exp);                               % Number of samples in autocorrelation
        fft_c_exp = fftshift(fft(c_exp))./Fs;           % Centered fft of autocorrelation,
                                                        % Scale by Fs
        psd_exp = abs(fft_c_exp);                       % Power Spectral Density                
        freq_exp = Fs*[-N/2: N/2 - 1]./N;               % Frequency scale (Hz)
        
    % Figures
        figure;
        sgtitle('Exponentially correlated noise');
        subplot(3,1,1);
        plot(t,M);
        ylabel('M'); xlabel('Time (s)');
        
        subplot(3,1,2);
        hold on;
        plot(lags_exp*dt,c_exp,'.');
        plot(lags_exp_thr,c_exp_thr,'-','LineWidth',1);
        hold off;
        legend('Numerical Autocorrelation','Theoretical Autocorrelation');        
        ylabel('Quantity^2'); xlabel('Lag (s)');

        subplot(3,1,3);
        hold on;
        plot(freq_exp,psd_exp,'.');
        plot(w_Hz,psd_exp_thr,'LineWidth',1);
        hold off;
        xlim([-100 100]);
        legend('Numerical PSD','Theoretical PSD');        
        ylabel('Quantity^2/Hz'); xlabel('Freq (Hz)');
    
