function [CH1_filtered, CH2_filtered] = Copy_of_fftfilter(CH1, CH2)
    % En lugar de usar la FFT, aplicamos el filtrado directo en el dominio del tiempo.
    
    % Parámetros de filtrado (puedes ajustarlos según los resultados)
    windowSize = 5;  % Tamaño de la ventana del filtro de mediana
    polyOrder = 3;   % Orden del polinomio para Savitzky-Golay
    
    % 1. Aplicar filtro de mediana para eliminar picos impulsivos
    CH1_median_filtered = medfilt1(CH1, windowSize);
    CH2_median_filtered = medfilt1(CH2, windowSize);
    
    % 2. Aplicar filtro de Savitzky-Golay para suavizar la señal
    % El filtro de Savitzky-Golay suaviza los datos y mantiene las características de la señal.
    CH1_filtered = sgolayfilt(CH1_median_filtered, polyOrder, 2*windowSize+1);  % Filtro de Savitzky-Golay para CH1
    CH2_filtered = sgolayfilt(CH2_median_filtered, polyOrder, 2*windowSize+1);  % Filtro de Savitzky-Golay para CH2

    % 3. Asegurar que los voltajes sean positivos
    CH1_filtered = abs(CH1_filtered);
    CH2_filtered = abs(CH2_filtered);
    
end
% %plot(abs(fft(CH1)))
% % hold on
% figure(4)
% plot(abs(CH1_filtered))
% hold on 
% plot(abs(CH2_filtered))
% % hold on
% % plot(CH1)
% hold on
% % plot(CH2)
% % plot((abs(CH2_filtered))./(abs(CH1_filtered)))
% legend('trans','refle')
% title('Señal filtrada')
