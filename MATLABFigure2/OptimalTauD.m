function y = OptimalTauD(x, gamma, c)

% FOC equation

lambda = 1;

y = -gamma^3 + c * gamma * lambda ...
    + exp(2*x*lambda/gamma)*(-2+gamma)*(gamma^2-c*lambda)...
    -2*exp(x*lambda/gamma)*gamma*(-gamma+x*(-1+gamma)*lambda);