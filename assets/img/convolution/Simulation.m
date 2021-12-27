%% Simulation of mass spring damper system
%{
--------------------------- Description -----------------------------------
Simulation of linear mass spring damper system. Use the model file that
describes the state dynamics.

---------------------------- Versions -------------------------------------
v1 : Suraj R Pawar, 7-10-2020
%}

clear all; close all; clc;

% Parameters
    m = 0.5;    % Mass [kg]
    k = 10;      % Spring constant [N/m]
    g = 9.81;   % Acceleration due to gravity [m/s^2]
    b = 1;    % Damping coefficient [N/m/s]
    amp = 1;    % Input force amplitude (N)
    freq = 1;   % Input force frequency (Hz)
    parameters = [m; b; k; g; amp; freq];
    
% Simulate
    t0 = 0;
    dt = 0.001;
    tf = 5;
    t = [t0:dt:tf];
    x0 = [0; 1.1*m*g/k]; 
    
    % Homogenous response
    parameters(5) = 0;
    parameters(4) = 0;
    [t1,x1] = ode45(@(t,x) msd(t,x,parameters),t,x0);
    
    % Input response
    parameters(5) = amp;
    parameters(4) = g;
    [t2,x2] = ode45(@(t,x) msd(t,x,parameters),t,[0;0]);
    
    % Combined Solution
    [t3,x3] = ode45(@(t,x) msd(t,x,parameters),t,x0);

% Collect outputs
    steps = length(t1);
    f1 = zeros(steps,1);
    f2 = zeros(steps,1);
    f3 = zeros(steps,1);
    for i = 1:steps
        [xdottemp1, y1] = msd(t1(i), x1(i,:).', parameters);
        [xdottemp2, y2] = msd(t2(i), x2(i,:).', parameters);
        [xdottemp3, y3] = msd(t3(i), x3(i,:).', parameters);
        f1(i) = y1(2);
        f2(i) = y2(2);
        f3(i) = y3(2);
    end

% System Analysis
    A = [-b/m, -k/m;
          1  ,  0  ];
    B = [1, 1/m;
         0, 0];
    C = [0, 1];
    D = 0;
    msd_ss = ss(A, B, C, D);
    eig(A)
    
% Figures
    figure; 
    lwidths = 1;
    
    subplot(3,1,1);
    hold on;
    plot(t1,x1(:,1), 'LineWidth',lwidths);
    plot(t2,x2(:,1), 'LineWidth',lwidths);
    plot(t3,x3(:,1), 'LineWidth',lwidths);
    hold off; grid on;
    title('Velocity (m/s)'); legend('Homogenous', 'Input', 'Combined');
    
    subplot(3,1,2);
    hold on;
    plot(t1,x1(:,2), 'LineWidth',lwidths);
    plot(t2,x2(:,2), 'LineWidth',lwidths);
    plot(t3,x3(:,2), 'LineWidth',lwidths);
    hold off; grid on;
    title('Spring extension (m)'); legend('Homogenous', 'Input', 'Combined');
       
    subplot(3,1,3);        
    plot(t1,f1, 'LineWidth',lwidths); grid on;   
    title('Input force (N)');
    xlabel('Time [s]');
    