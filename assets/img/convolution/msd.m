function [xdot,y] = msd(t,x, parameters)
%% Mass spring damper model
%{
---------------------- Description ----------------------------------------
Linear mass spring damper system model. Use this model file with a separate
simulation file that uses a solver such as ODE45, or Euler integration.

------------------------- Inputs ------------------------------------------
t          : Current time (s)
x          : States
            x1 : Velocity of mass (m/s)
            x2 : Spring compression (m)
            
parameters : List of parameters for the mass spring damper system -
            1. m : Mass (kg)
            2. b : Damping coefficient (N/m/s)
            3. k : Spring constant (N/m)
            4. g : Acceleration due to gravity (m/s^2)
            5. amp : Amplitude of input force (N)
            6. freq : Frequency of input force (Hz)

-------------------------- Outputs ----------------------------------------
xdot : State dynamics
y(1) : Spring force (N)
y(2) : Input force (N)

-------------------------- Versions ---------------------------------------
v1 : Suraj R Pawar, 7-10-2020
%}

% Access parameters
    m = parameters(1);
    b = parameters(2);
    k = parameters(3);
    g = parameters(4);
    amp = parameters(5);    
    freq = parameters(6);
    
% Generate Inputs
    F = amp*sin(2*pi*freq*t);
    
% Extract states
    v = x(1); 
    xk = x(2);     

% State equations
    vdot = (1/m)*(-k*xk - b*v + m*g + F);
    xkdot = v;    
    xdot = [vdot; xkdot];

% Outputs
    y(1) = k*xk; 
    y(2) = F;
end