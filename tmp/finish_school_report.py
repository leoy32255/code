from pathlib import Path
import shutil
p=Path(r'D:\Repository\code\LATEX\Conmmunication\LinkBudget')
results=Path(r'D:\Users\21449\Downloads\1-Channel\1-Channel\results_school')
for name in ['CIR_position_rayphase.png','CIR_bandwidth.png']:
    shutil.copy2(results/name,p/'figures'/name)
shutil.copy2(results/'学校-11',p/'figures'/'school_step11.png')
tex=p/'实验1信道模拟.tex'
s=tex.read_text(encoding='utf-8-sig')
start=s.index(r'\section{相邻接收位置与带宽的影响}')
end=s.index(r'\section{学校覆盖对比}',start)
s=s[:start]+r'''\clearpage
\section{相邻接收位置与带宽的影响}
\subsection{相邻接收天线的CIR}
两接收点仅相距0.222075 m，但在28 GHz下已相隔20.741个波长。基础代码采用混凝土、最多两次反射和一次衍射、low角间隔，不叠加天气损耗；其功率不应与前述含天气的链路直接混为同一条件。
\begin{table}[H]\centering\small
\caption{相邻接收点的实际仿真结果}
\begin{tabular}{lrr}\toprule
接收点 & 接收功率/dBm & 几何射线数\\\midrule
Rx1 & $-62.189$ & 23\\
Rx2 & $-59.687$ & 24\\\bottomrule
\end{tabular}
\end{table}
\begin{figure}[H]\centering
\includegraphics[width=.91\linewidth]{figures/CIR_position_rayphase.png}
\caption{相邻接收点的20 MHz CIR：使用射线几何相位}
\label{fig:cir-position}
\end{figure}
图\ref{fig:cir-position}的横轴为相对两个位置共同最早到达时刻的时延，单位为ns；纵轴为按各位置逐径功率和归一化后的复系数模值，不是dBm。两点的主抽头位置相近，均在约75 ns处出现最大幅度，但25、50和75 ns附近的幅度明显不同；Rx2的总接收功率比Rx1高\textbf{2.502 dB}。因此，相邻位置具有相似的主要时延结构，但射线路径、逐径相位及相干叠加结果并不相同。

基础代码还生成了独立复高斯随机系数下的CIR。该随机实现会改变抽头幅度及主峰位置，但两点的随机系数独立，未包含空间相关模型，不能把其全部差异归因于接收位置。几何相位CIR更直接地反映本次射线追踪得到的位置差异；两图均按逐径功率和归一化，不代表瞬时CIR总能量必为1。

\clearpage
\subsection{带宽对可分辨多径的影响}
固定Rx1的23条射线及同一组逐径随机复系数，仅改变带宽，得到表\ref{tab:bw}和图\ref{fig:bw}。
\begin{table}[H]\centering\small
\caption{带宽对比的实际结果与时延尺度}\label{tab:bw}
\begin{tabular}{lrrr}\toprule
带宽$B$/MHz & 20 & 40 & 80\\\midrule
采样间隔$T_s=1/(2B)$/ns & 25 & 12.5 & 6.25\\
分辨时间尺度$1/B$/ns & 50 & 25 & 12.5\\
几何射线数 & 23 & 23 & 23\\
占用时延格数 & 6 & 7 & 8\\\bottomrule
\end{tabular}
\end{table}
\begin{figure}[H]\centering
\includegraphics[width=.94\linewidth]{figures/CIR_bandwidth.png}
\caption{固定路径和随机系数时的20、40、80 MHz CIR对比}
\label{fig:bw}
\end{figure}
带宽增加后，时延网格变细，占用时延格由\textbf{6个增至7个、8个}。例如，20 MHz下约75 ns处的合成抽头，在80 MHz下可见约62.5 ns和68.75 ns附近的分离抽头。原本量化到同一格内的路径可被分配到不同抽头，其相干叠加方式也随之改变；这里并未新增几何传播路径。

因此，增大带宽通常有助于分离时延接近的多径。本基础模型使用四舍五入量化和格内复振幅求和，未包含完整的带限脉冲成形与检测过程；\textbf{占用时延格数不等同于物理可分辨多径数}，不能把$T_s=1/(2B)$直接当作物理分辨率。图中零幅度采样点也不算新增路径。
\clearpage
'''+s[end:]
marker=r'\section{社区场景}'
insert=r'''\clearpage
\subsection{两次反射与一次衍射的预计算覆盖}
\begin{figure}[H]\centering
\includegraphics[width=.87\linewidth]{figures/school_step11.png}
\caption{步骤11：已有两次反射、一次衍射预计算覆盖结果的重绘}
\label{fig:coverage11}
\end{figure}
图\ref{fig:coverage11}由已有的\texttt{coverageResultsTwoRefOneDiff.mat}功率表加载绘制，共含1822个采样点，本轮未重新计算覆盖。与仅直射及单次反射图相比，主道路仍保持较强信号，更多建筑周边和遮挡区域出现蓝色弱信号区域，体现了更多间接传播通道对覆盖的补充作用。

三幅图采用一致的dBm色标。此处对预计算图作定性比较，不据图面着色面积推算覆盖率，也不把加载绘图耗时当作射线追踪计算耗时；已有功率表本身不提供可用于严格同条件比较的完整模型记录。

\subsection{学校实验结论}
本次非视距链路中，改用混凝土引入7.602 dB的额外损耗，天气进一步引入0.584 dB损耗；扩大路径搜索后，更多反射、衍射路径改善了本次链路的合成接收功率，同时增加计算耗时。相邻接收点虽在空间上接近，仍可有不同射线数和CIR幅度。增大带宽使原有路径分布到更多离散时延格，改善时延区分能力，但不改变几何射线总数。

'''
s=s.replace(marker,insert+marker)
tex.write_text(s,encoding='utf-8')
assert s.count(r'\begin{figure}')==s.count(r'\end{figure}')
assert s.count(r'\begin{table}')==s.count(r'\end{table}')
import re
for n in re.findall(r'\{figures/([^}]+)\}',s):
    if '#' not in n: assert (p/'figures'/n).is_file(),n
print('Report source and image references checked.')
