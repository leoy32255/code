from pathlib import Path
import shutil,re
root=Path(r'D:\Repository\code\LATEX\Conmmunication\LinkBudget')
r=Path(r'D:\Users\21449\Downloads\1-Channel\1-Channel\results_community')
for n in [3,5,6,8,9,10,11]:
    shutil.copy2(r/str(n),root/'figures'/f'community_step{n:02}.png')
shutil.copy2(r/'CIR_bandwidth.png',root/'figures'/'community_CIR_bandwidth.png')
p=root/'实验1信道模拟.tex'; s=p.read_text(encoding='utf-8-sig')
old='\\section{社区场景}\n待后续完成。'
assert old in s
new=r'''\clearpage
\section{社区场景}
\subsection{非视距链路、材质与天气}
社区场景选取玉泉北里住宅楼与商业中心之间的区域。发射点位于$(39.922250,116.245080)$，主接收点位于$(39.922540,116.244700)$（纬度、经度，单位为度）。保存的视线检查结果为主接收点LoS=0、近发射端检查点LoS=1。主链路由建筑遮挡，但周围墙面提供了间接传播通道。
\begin{table}[H]\centering\small
\caption{社区主接收点的链路结果}\label{tab:community-link}
\begin{tabular}{lccrrr}\toprule
条件 & 最大反射/衍射 & 角间隔 & 功率/dBm & 射线数 & 耗时/s\\\midrule
完美反射，无天气 & 1/0 & medium & $-63.028$ & 2 & 0.072\\
混凝土，无天气 & 1/0 & medium & $-70.995$ & 2 & 0.056\\
混凝土，含天气 & 1/0 & medium & $-72.089$ & 2 & 0.063\\
混凝土，含天气 & 2/0 & low & $-71.541$ & 6 & 0.128\\
混凝土，含天气 & 2/1 & low & $-71.134$ & 15 & 1.467\\\bottomrule
\end{tabular}
\smallskip\par\footnotesize 耗时口径同学校链路表，不含绘图；单次短任务计时不用于判断材质模型的计算复杂度。
\end{table}
\pair{community_step05.png}{社区：完美反射、最多一次反射}{community_step06.png}{社区：混凝土、最多一次反射}
更换材质后，两条路径的时延均保持为383.745 ns和714.679 ns，路损分别由102.608、108.010 dB增至110.554、116.025 dB，合成接收功率下降\textbf{7.967 dB}。路径几何不变，而材料反射损耗明显增加。

加入气体和降雨损耗后，功率进一步下降\textbf{1.095 dB}。两条路径分别增加0.876、1.631 dB路损，较长路径积累的天气衰减更大。这解释了社区链路的天气影响为何与学校链路不同，不能把天气损耗看作与路径长度无关的固定常数。

\clearpage
\subsection{反射与衍射路径}
\pair{community_step08.png}{社区：最多两次反射，含天气}{community_step09.png}{社区：最多两次反射、一次衍射，含天气}
最大反射数由1增至2、角间隔由medium改为low后，射线数由2增至6，合成接收功率增加0.548 dB。继续保持low并允许一次衍射后，共得到15条路径，其中\textbf{6条不含衍射、9条含一次衍射}，功率再增加0.408 dB，链路计算耗时约为原来的11.49倍。

加入衍射后，最早到达时延由383.745 ns提前到164.146 ns，说明绕过建筑边缘的路径可比原有反射绕行路线更短。但最早到达并不等于最强：衍射路径仍可能因较大损耗而较弱。路径的贡献需要同时看时延、幅度与相位，而不能只按路线长短或图中线条数量判断。

\subsection{相邻接收位置的CIR}
代码II保持混凝土、两反射一衍射、low角间隔，不叠加天气。Rx2位于$(39.922542,116.244700)$，与Rx1相距0.222069 m，约为20.741个波长。
\begin{table}[H]\centering\small
\caption{社区相邻接收点的实际结果}
\begin{tabular}{lrr}\toprule
接收点 & 接收功率/dBm & 几何射线数\\\midrule
Rx1 & $-69.868$ & 15\\
Rx2 & $-74.190$ & 15\\\bottomrule
\end{tabular}
\end{table}
\begin{figure}[H]\centering
\includegraphics[width=.76\linewidth]{figures/community_CIR_position.png}
\caption{社区相邻接收点的20 MHz CIR：射线几何相位}
\label{fig:community-cir}
\end{figure}
两点的射线数相同，主要抽头均位于相对首径约225、275和550 ns处，但Rx2接收功率比Rx1低\textbf{4.322 dB}。图\ref{fig:community-cir}在225 ns处的归一化幅度约为0.469和0.527，550 ns处约为0.570和0.568；这些按各位置逐径功率和归一化的幅度不能直接代表两点绝对接收功率。局部位移改变了逐径相位及合成结果，射线数量相同并不意味着信道相同。

\clearpage
\subsection{带宽影响}
固定Rx1的15条射线和同一组随机复系数，带宽对比如下。
\begin{table}[H]\centering\small
\caption{社区带宽对比结果}
\begin{tabular}{lrrr}\toprule
带宽$B$/MHz & 20 & 40 & 80\\\midrule
采样间隔$T_s$/ns & 25 & 12.5 & 6.25\\
分辨时间尺度$1/B$/ns & 50 & 25 & 12.5\\
几何射线数 & 15 & 15 & 15\\
占用时延格数 & 5 & 5 & 6\\\bottomrule
\end{tabular}
\end{table}
\begin{figure}[H]\centering
\includegraphics[width=.94\linewidth]{figures/community_CIR_bandwidth.png}
\caption{社区固定路径与随机系数时的20、40、80 MHz CIR}
\end{figure}
20 MHz增至40 MHz时，占用时延格仍为5个；增至80 MHz后才增加到6个。带宽变大使时延量化更细，但是否分离出新抽头取决于实际路径时延间隔及量化位置，\textbf{并非每次增加带宽都会增加抽头数量}。三个带宽下几何路径数均为15，变化发生在离散表示而非传播环境中。

三幅图使用相同的物理时延范围与纵轴范围，主抽头幅度的变化来自格内路径的重新组合，并非重新生成随机衰落。图中的零幅度采样点不属于有效占用格；占用格数与物理可分辨多径数的区别同学校实验。

\clearpage
\subsection{覆盖对比}
\begin{table}[H]\centering\small
\caption{社区三种覆盖计算的条件与耗时}
\begin{tabular}{lcccr}\toprule
条件 & 最大反射/衍射 & 角间隔 & 网格/m & 耗时/s\\\midrule
仅直射，完美反射材质，无天气 & 0/0 & medium & 3 & 11.291\\
混凝土，单次反射，含天气 & 1/0 & low & 2 & 109.105\\
混凝土，两反射一衍射，含天气 & 2/1 & high & 10 & 155.835\\\bottomrule
\end{tabular}
\end{table}
\pair{community_step03.png}{社区仅直射覆盖}{community_step10.png}{社区单次反射并计入天气的覆盖}
\begin{figure}[H]\centering
\includegraphics[width=.66\linewidth]{figures/community_step11.png}
\caption{社区两次反射、一次衍射并计入天气的覆盖}
\end{figure}
仅直射时，有色区域主要沿南北向空隙及部分楼间开口展开，住宅楼后方和商业中心背面存在明显阴影。单次反射增加了楼间通道的覆盖，并产生更明显的局部强弱变化；两反射一衍射条件下，更多楼后及商业中心另一侧出现蓝色弱信号区域，间接传播补充了原有阴影区。

三图采用相同的$[-120,-5]$ dBm色标和250 m范围。最后一图采用10 m粗网格与high角间隔，边界细节和局部起伏不宜与2 m网格逐像素比较；其计算仍耗时155.835 s，说明增加路径机制具有显著计算代价。由于网格、角间隔也改变，不能据此估计只增加衍射的覆盖计算耗时倍数或精确覆盖率增益。

\clearpage
\section{两场景对比与结论}
\begin{table}[H]\centering\small
\caption{学校与社区的主要结果对比}
\begin{tabular}{lrr}\toprule
指标 & 学校 & 社区\\\midrule
混凝土相对完美反射的附加损耗/dB & 7.602 & 7.967\\
单次反射链路的天气附加损耗/dB & 0.584 & 1.095\\
含天气、两反射一衍射接收功率/dBm & $-62.800$ & $-71.134$\\
同一条件下的几何射线数 & 23 & 15\\
增加衍射后的接收功率增量/dB & 1.080 & 0.408\\
20/40/80 MHz占用时延格数（无天气Rx1） & 6/7/8 & 5/5/6\\\bottomrule
\end{tabular}
\end{table}
两场景均表明，真实材质带来的约8 dB附加损耗比本次增加少量传播路径带来的功率增益更大。社区两条单反射路径的时延为383.745、714.679 ns，长于学校的236.797、278.868 ns；相同天气模型下，较长路径积累了更多衰减。

在两反射一衍射、含天气条件下，社区主链路比学校低8.334 dB。这是所选位置、遮挡、绕行距离、反射条件与相干叠加共同作用的结果，不能推广为整个社区的覆盖必然比学校差。学校较多的射线也没有在所有带宽下转化成同样比例的可区分抽头。

相邻天线实验进一步说明，距离相近或射线数量相同都不足以保证CIR一致；带宽实验说明，增大带宽改善时延区分能力，但不增加几何传播路径。覆盖分析则需要同时权衡传播机制、角间隔、网格精度与计算时间，不能把不同设置下的图像差异全部归因于反射或衍射次数。
'''
s=s.replace(old,new)
p.write_text(s,encoding='utf-8')
for name in re.findall(r'\{figures/([^}]+)\}',s):
    if '#' not in name: assert (root/'figures'/name).is_file(),name
labels=re.findall(r'\\label\{([^}]+)\}',s)
assert len(labels)==len(set(labels))
assert all(ref in labels for ref in re.findall(r'\\ref\{([^}]+)\}',s))
assert '待后续完成' not in s
print('Community section, comparison, and all image references completed.')
