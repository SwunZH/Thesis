close all;
clear all;

N = 16;
Pfa = 1e-4;
alpha = SO_CA_CFAR_Statistic(Pfa,N);
SNR_dB = 0:1:30;




Iterations = 1e6;


Reference_cells = zeros(N,Iterations);

for i = 1:N
    I = randn(1,Iterations);
    Q = randn(1,Iterations);
    Reference_cells(i,:) = (I + 1j*Q)/sqrt(2);
end


Reference_cells_AD = abs(Reference_cells).^2;





alpha_go_array = ones(1,Iterations)*alpha;

Pd = [];
Pd_sim = [];
for index = 1:length(SNR_dB)
    SNR = 10^(SNR_dB(index)/10);
    disp(SNR_dB(index));
    %Math for simulated values
    
    I_test = randn(Iterations,1);
    Q_test = randn(Iterations,1);
    Test_Signal = sqrt(SNR)*(I_test + 1j*Q_test)/sqrt(2);
    Test_AD = abs(Test_Signal).^2;
    
    
    Window_Front = Reference_cells_AD(1:N/2,:);
	Window_Back = Reference_cells_AD(N/2+1:end,:);
	
	Sum_Reference_cells = min(sum(Window_Front),sum(Window_Back));
	g = Sum_Reference_cells;
	T_CFAR = g.*alpha_go_array;
    
    
    Detections = ( Test_AD.'-T_CFAR )>0;
    
    Pd_sim = [Pd_sim; sum(Detections(:))/Iterations];
    
    
    % Math for expected values
    
    summation = 0;
    for k = 0:1:(N/2-1)
        summation = summation + nchoosek((N/2 -1 +k),k)*(2+alpha/(1+SNR))^(-k);
    end
    
    
    Pd = [Pd ; 2*(((2+ alpha/(1+SNR))^(-N/2) * summation))];

end

plot(SNR_dB,Pd);
hold on;
plot(SNR_dB,Pd_sim.');