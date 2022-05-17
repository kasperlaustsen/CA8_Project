% This script tests for lyapunov stability of the system given the state
% reduced matrix (A), the kalman reduced system (A11) and the controlled
% system with observer

clc;close all;
yalmip('clear')
% Dimension of A
sizeA = size(A)
n = sizeA(1);

% Define yalmip variable
P = sdpvar(n,n);
% Constraint matrix
F = [P >= 0, A'*P+P*A <= 0];

% Run optimization
optimize(F);

% Check F
check(F)


%% Kalman decomposition version of A (A11)
yalmip('clear')
% Dimension of A11
sizeA = size(A11)
n = sizeA(1);

% Define yalmip variable
P = sdpvar(n,n);
% Constraint matrix
F = [P >= 0, A11'*P+P*A11 <= 0];

% Run optimization
optimize(F);

% Check F
check(F)


%% Controller and observer (Afull)
yalmip('clear')


Afull = [A11	B1*K
		-L*C1	A11-B1*K-L*C1];

% Poles of Afull
eig(Afull)

% Dimension of controlled observer matrix
sizeA = size(Afull)
n = sizeA(1);

% Define yalmip variable
P = sdpvar(n,n);
% Constraint matrix
F = [P >= 0, Afull'*P+P*Afull <= 0];

% Run optimization
optimize(F);

% Check F
check(F)
