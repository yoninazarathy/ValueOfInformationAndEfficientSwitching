function [E_W,E_R,E_N,g] = average_reward_renewal_reward(cost,tau)
lambda = 1;
gamma = 0.4;
mu = lambda/gamma-lambda;
b = gamma*(1-exp(-tau*lambda/gamma));
bb = gamma + (1-gamma)*exp(-tau*lambda/gamma);

E_W0 = tau+b/mu;
E_W1 = tau+bb/mu;

E_I0 = (1-b)*b + b * gamma * (lambda + b*mu)/(lambda+gamma*mu);

E_I1 = (1-bb)*b + bb * gamma * (lambda + b*mu)/(lambda+gamma*mu);

E_R0 = gamma*(tau-b/lambda)+b/mu;
E_R1 = gamma * (1-bb+lambda*tau)/lambda +bb/mu;


E_W = E_W0 + E_I0 / (1-E_I1)*E_W1;
E_R = E_R0 + E_I0 / (1-E_I1)*E_R1;
E_N = 1 + E_I0 / (1-E_I1);
g = (E_R - cost * E_N)/E_W;