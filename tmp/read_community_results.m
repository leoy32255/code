p='D:/Users/21449/Downloads/1-Channel/1-Channel/results_community';
o='D:/Repository/code/LATEX/Conmmunication/LinkBudget/figures';
a=load(fullfile(p,'step04_los.mat')); fprintf('Saved LOS: main=%d check=%d\n',a.mainLOS,a.checkLOS);
for tag=["step05_perfect_1R","step06_concrete_1R","step07_weather_1R","step08_weather_2R","step09_weather_2R1D"]
 a=load(fullfile(p,tag+'.mat')); rr=a.rays{1}; nd=zeros(1,numel(rr));
 for k=1:numel(rr), nd(k)=sum(string({rr(k).Interactions.Type})=="Diffraction"); end
 fprintf('%s: noDiff=%d Diff=%d delays=%.6f..%.6f ns\n',tag,sum(nd==0),sum(nd>0),min([rr.PropagationDelay])*1e9,max([rr.PropagationDelay])*1e9);
end
a=load(fullfile(p,'step11_coverage_2R1D.mat')); disp(rmfield(a.metadata,'MapText'));
a=load(fullfile(p,'community_CIR_positions.mat'));
disp(rmfield(a.metadata,'MapText')); fprintf('spacing=%.9f m\n',a.dme2);
fprintf('CIR1 nonzero magnitude: '); fprintf('%.6f ',abs(a.CIR1_geometry(abs(a.CIR1_geometry)>1e-12))); fprintf('\n');
fprintf('CIR2 nonzero magnitude: '); fprintf('%.6f ',abs(a.CIR2_geometry(abs(a.CIR2_geometry)>1e-12))); fprintf('\n');
% 仅用已存CIR重新绘图以移除导出工具栏；不调用任何传播计算。
f=figure('Visible','off','Color','w','Position',[100 100 1100 650]);
ax=axes(f,'Position',[.12 .15 .83 .76],'FontSize',12);
Ts=1/(2*a.metadata.Bandwidth_MHz*1e6);
stem(ax,(0:numel(a.CIR1_geometry)-1)*Ts*1e9,abs(a.CIR1_geometry),'o'); hold(ax,'on');
stem(ax,(0:numel(a.CIR2_geometry)-1)*Ts*1e9,abs(a.CIR2_geometry),'x');
grid(ax,'on'); xlabel(ax,'相对共同最早到达时刻的时延 (ns)'); ylabel(ax,'归一化CIR幅度 |h[n]|');
title(ax,'20 MHz，射线几何相位，无额外随机衰落'); legend(ax,'Rx1','Rx2','Location','best');
ax.Toolbar.Visible='off'; disableDefaultInteractivity(ax);
exportgraphics(f,fullfile(o,'community_CIR_position.png'),'Resolution',200);close(f);
disp('SAVED_RESULTS_READ_AND_FIGURE_EXPORTED');
