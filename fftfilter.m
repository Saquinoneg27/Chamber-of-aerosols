function [CH1_filtered] = fftfilter(CH1) 
%fftCH1 = fftshift(fft(CH1));
fftCH1 = fft(CH1);
%plot(abs(real(fftCH1)))
%fftCH2 = fftshift(fft(CH2));

% delete not desired frequencies 
fftCH1(60:end)=0;

% inverse Fast Fourier transform to obtain filtered signal
CH1_filtered = abs(real(ifft(fftCH1)));
%CH1_filtered = ifft(fftCH1);


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
end