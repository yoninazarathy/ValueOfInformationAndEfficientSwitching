% c = 0.04;
% c = 0.08;
% c = 0.12;
% c = 0.16;
gRecordS =[];
gTrue= [];
cList = [0.04 0.08 0.12 0.16];
gammaTrue = 0.4;
for indc = 1:length(cList)
    c = cList(indc);

    s1 =0; s2 = gammaTrue*(-log(1-(gammaTrue-0.001)/gammaTrue));
    s = (s1+s2)/2;
    while (s2-s1 > 10^(-6))
    if OptimalTauD(s, gammaTrue, c) > 0
        s1 = s;
    else
        s2 = s;
    end
    s = (s1+s2)/2;
    end
    [E_W,E_R,E_N,g] = average_reward_renewal_reward(c,s);
    gTrue = [gTrue; g];

    gammaList = 0:0.01:1;
    gRecord = [];
    tauRecord= [];
    for ind = 1:length(gammaList)

    gamma = gammaList(ind);

    if gamma < sqrt(c)
        g = gammaTrue;
        tau = Inf;
    else
        s1 =0; s2 = gamma*(-log(1-(gamma-0.001)/gamma));
        s = (s1+s2)/2;
        while (s2-s1 > 10^(-6))
            if OptimalTauD(s, gamma, c) > 0
                s1 = s;
            else
                s2 = s;
            end
            s = (s1+s2)/2;
        end
        tau = s;
        [E_W,E_R,E_N,g] = average_reward_renewal_reward(c,tau);
    end
    gRecord = [gRecord, g];
    tauRecord =[tauRecord, tau];
    end
    gRecordS = [gRecordS;gRecord];
end
gTrue = repmat(gTrue,1,length(gRecord));
plot(gammaList, gRecordS./gTrue);
hold on

% plot([gammaTrue,gammaTrue],[0.75,1.05],'k--')
plot([gammaTrue,gammaTrue],[0.75,1.00],'k--')
ylim([0.75,1.05])
xlabel('$\hat{\gamma}$','FontSize',22,'FontWeight','bold','Interpreter','latex')
ylabel('$\hat{g}/g$','FontSize',22,'FontWeight','bold','Interpreter','latex');
legend('c = 0.04','c = 0.08','c = 0.12','c = 0.16')
% figure
% plot(gRecord,tauRecord)