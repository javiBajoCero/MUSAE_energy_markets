% F.-Javier Heredia f.javier.heredia(at)upc.edu http://gnom.upc.edu/heredia
% Code under Creative Commons Attribution-NonCommercial-NoDerivs
% 3.0 Unported License http://creativecommons.org/licenses/by-nc-nd/3.0/
% 
% Script to plot the market clearing from the GAMS files or the SPA model.
% The input files are created by the SPA2M.gms GAMS script.
%

clear;
lbgAcc = importdata('SPA_lbg.dat');
pbgAcc = importdata('SPA_pbg.dat');
PGAcc = importdata('SPA_PG.dat');

pbgAcc = pbgAcc';
lbgAcc = lbgAcc';
PGAcc = PGAcc';

[nbg,tp] = size(lbgAcc);
[lbgAcc_s,IXg] = sort(lbgAcc);

for t = 1:tp
    pbgAcc_s(:,t) = pbgAcc(IXg(:,t),t); 
    PGAcc_s(:,t) = PGAcc(IXg(:,t),t); 
end
xg = zeros(nbg+2,tp); yg = zeros(nbg+2,tp);

for t = 1:tp
    for j = 2:nbg+1
        yg(j,t) = lbgAcc_s(j-1,t);
        if j==2
            xg(j,t) = 0;
        else
            xg(j,t) = xg(j-1,t) + pbgAcc_s(j-2,t);
        end
    end
    xg(nbg+2,t) = xg(nbg+1,t) + pbgAcc_s(nbg,t);
    yg(nbg+2,t) = yg(nbg+1,t);
end

xmg = zeros(nbg+2,tp); ymg = zeros(nbg+2,tp);
for t = 1:tp
    pmgAcc_s = PGAcc_s(PGAcc_s(:,t)>0,t);
    lmgAcc_s = lbgAcc_s(PGAcc_s(:,t)>0,t);
    [nmg,tpm] = size(lmgAcc_s);
    for j = 2:nmg+1
        ymg(j,t) = lmgAcc_s(j-1);
        if j==2
            xmg(j,t) = 0;
        else
            xmg(j,t) = xmg(j-1,t) + pmgAcc_s(j-2);
        end
    end
    xmg(nmg+2:nbg+2,t) = xmg(nmg+1,t) + pmgAcc_s(nmg);
    ymg(nmg+2:nbg+2,t) = ymg(nmg+1,t);
end

lbdAcc = importdata('SPA_lbd.dat');
pbdAcc = importdata('SPA_pbd.dat');
PDAcc = importdata('SPA_PD.dat');

pbdAcc = pbdAcc';
lbdAcc = lbdAcc';
PDAcc = PDAcc';

[nbd,tp] = size(lbdAcc);
[lbdAcc_s,IXd] = sort(lbdAcc, 'descend');
for t = 1:tp
    pbdAcc_s(:,t) = pbdAcc(IXd(:,t),t); 
    PDAcc_s(:,t) = PDAcc(IXd(:,t),t); 
end

xd = zeros(nbd+2,tp); yd = zeros(nbd+2,tp);
for t = 1:tp
    yd(1,t)=lbdAcc_s(1,t);
    for j = 2:nbd+1
        yd(j,t) = lbdAcc_s(j-1,t);
        if j==2
            xd(j,t) = 0; 
        else
            xd(j,t) = xd(j-1,t) + pbdAcc_s(j-2,t);
        end
    end
    xd(nbd+2,t) = xd(nbd+1,t) + pbdAcc_s(nbd,t);
    yd(nbd+2,t) = yd(nbd+1,t);
end

xmd = zeros(nbd+2,tp); ymd = zeros(nbd+2,tp);
for t = 1:tp
    pmdAcc_s = PDAcc_s(PDAcc_s(:,t)>0,t);
    lmdAcc_s = lbdAcc_s(PDAcc_s(:,t)>0,t);
    [nmd,tpm] = size(lmdAcc_s);
    ymd(1,t)=lmdAcc_s(1);
    for j = 2:nmd+1
        ymd(j,t) = lmdAcc_s(j-1);
        if j==2
            xmd(j,t) = 0;
        else
            xmd(j,t) = xmd(j-1,t) + pmdAcc_s(j-2);
        end
    end
    xmd(nmd+2:nbd+2,t) = xmd(nmd+1,t) + pmdAcc_s(nmd);
    ymd(nmd+2:nbd+2,t) = ymd(nmd+1,t);
end

MPA_eq = importdata('SPA_eq.dat');
MPA_eq = MPA_eq';

SWT = 0;
ncol = 1;
for t=1:tp
    energy = MPA_eq(1,t);
    price = MPA_eq(2,t);
   xprice = 0:.01:energy;
    yprice = price;
    xenergy = energy;
    yenergy = 0:.01:price;
    SW = MPA_eq(3,t);
    SWT = SWT + SW;
    subplot(ceil(tp/ncol),ncol,t)
    hold on;
    
    box on;
    title({['\fontname{arial}{\bf Single Period Auction }'];['{\it\lambda}^*=',num2str(price),', {\itP }^*=',num2str(energy),', {\itSW ^*}= ',num2str(SW)]},'FontName','Cambria Math','Fontsize',20,'FontWeight','bold');
    ylabel('{\it\lambda} [€/MWh]','Fontname','Cambria Math','Fontsize',20)
    xlabel('{\itP} [MW]','Fontname','Cambria Math','Fontsize',20)
    set(gcf,'Color','w'); set(gca,'Fontsize',20);
    maxenergy = max(xg(nbg+2),xd(nbd+2))+1;
    maxprice = max(yg(nbg+2),yd(1))+1;
    axis ([0 maxenergy 0 maxprice]);
    stairs(xg(:,t),yg(:,t),'-','Color',[.26,.26,0.8],'LineWidth',2)
    stairs(xmg(:,t),ymg(:,t),'-','Color',[.26,.26,0.8],'LineWidth',8)
    stairs(xd(:,t),yd(:,t),'-','Color',[.6,.6,.0],'LineWidth',2)
    stairs(xmd(:,t),ymd(:,t),'-','Color',[0.6,.6,.0],'LineWidth',8)
    plot(xprice,yprice,'LineWidth',6)
    plot(xenergy,yenergy,':k','LineWidth',6)
    plot([0;energy],[price;price],':k','LineWidth',3);
    plot([energy;energy],[price;0],':k','LineWidth',3);
    plot([energy;energy],[price;price],'xr','MarkerSize',20,'LineWidth',10);
    hold off;
end
%subplot (ceil(tp/ncol),ncol,tp-1);
%text(maxenergy/2, -8, ['\bf{\it SW ^*} = ',num2str(SWT)],'Fontname','Cambria Math','Fontsize',20);



