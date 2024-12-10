clc
clear all

folderPath = 'C:\Users\alejo\OneDrive\Desktop\ingeniería física\7mo\avanzado\CodesSQuiñonez_Osciloscopio\Taking Data';  % Cambia esta ruta a la carpeta correcta

% Carga las variables desde los archivos .mat AEROSOLES
data_ch1 = load(fullfile(folderPath, 'fP1_CaO_CH1_20240927.mat'));  % Canal 1 AEROSOLES
data_ch2 = load(fullfile(folderPath, 'fP1_CaO_CH2_20240927.mat'));  % Canal 2 AEROSOLES
tiempo = load('tiempo_27092024.mat');  % Cargar el archivo de tiempo
n_delta_90 = load("N_DELTA_20240927.mat");
n_delta_90= n_delta_90.mediaTotal_delta90;

% Obtener los archivos de RUIDO
noise_files_ch1 = dir(fullfile(folderPath, 'fR*_CH1_20240927.mat'));  % Canal 1 Noise
noise_files_ch2 = dir(fullfile(folderPath, 'fR*_CH2_20240927.mat'));  % Canal 2 Noise

% Inicializar matrices para almacenar los datos de ruido
all_noise_ch1 = [];
all_noise_ch2 = [];

% Cargar los archivos de ruido de CH1 y concatenar los datos
for i = 1:length(noise_files_ch1)
    noise_data_ch1 = load(fullfile(noise_files_ch1(i).folder, noise_files_ch1(i).name));
    all_noise_ch1 = [all_noise_ch1; noise_data_ch1.dataCh1_f];  % Asumiendo que la variable dentro del archivo se llama 'ruido'
end

% Cargar los archivos de ruido de CH2 y concatenar los datos
for i = 1:length(noise_files_ch2)
    noise_data_ch2 = load(fullfile(noise_files_ch2(i).folder, noise_files_ch2(i).name));
    all_noise_ch2 = [all_noise_ch2; noise_data_ch2.dataCh2_f];  % Asumiendo que la variable dentro del archivo se llama 'ruido'
end

% Promediar los datos de ruido
average_noise_ch1 = mean(all_noise_ch1, 1);  % Promedio a lo largo de las filas (archivos)
average_noise_ch2 = mean(all_noise_ch2, 1);

% Restar el promedio de ruido a las señales de AEROSOLES
signal_clean_ch1 = data_ch1.dataCh1_f - average_noise_ch1;  % Asumiendo que la señal se llama 'signal'
signal_clean_ch2 = data_ch2.dataCh2_f  - average_noise_ch2;

% Graficar las señales limpias
figure;
subplot(2,1,1);
plot(tiempo.timeStamps, signal_clean_ch1);
title('Señal limpia CH1');
xlabel('Tiempo (s)');
ylabel('Amplitud');

subplot(2,1,2);
plot(tiempo.timeStamps, signal_clean_ch2);
title('Señal limpia CH2');
xlabel('Tiempo (s)');
ylabel('Amplitud');


%% n DELTA 90
% Definir los rangos de tiempo donde quieres calcular CH2/CH1
rango_tiempo_inicio = 40;  % Ejemplo: tiempo inicial en segundos
rango_tiempo_fin = 120;     % Ejemplo: tiempo final en segundos

% Encontrar los índices que corresponden a esos rangos de tiempo
indices_rango = find(tiempo.timeStamps >= rango_tiempo_inicio & tiempo.timeStamps <= rango_tiempo_fin);
% Calcular CH2/CH1 solo en el rango de tiempo especificado
ratio_ch2_ch1 = signal_clean_ch2(indices_rango) ./ signal_clean_ch1(indices_rango);
delta_vn = ratio_ch2_ch1 * (1/n_delta_90);
delta_v = mean(delta_vn);

% Graficar la relación CH2/CH1 en el rango de tiempo especificado
figure;
plot(tiempo.timeStamps(indices_rango), delta_vn);
title('\delta_v vs tiempo');
xlabel('Tiempo (s)');
ylabel('\delta v');

% Agregar una línea horizontal en el valor de la media delta_v
yline(delta_v, '--r',  ['Media \delta_v = ', num2str(delta_v, '%.2f')], 'LabelHorizontalAlignment', 'left');



%% d_p
delta_m=0.0034; R=5.8;

delta_p= ((1+delta_m)*R*delta_v-(1+delta_v)*delta_m)./ ...
        ((1+delta_m)*R-(1+delta_v))
%%

%{
Tareas code:




  


%{
if strcmp(A,'Ruido de fondo')||strcmp(A,'RfondoSINHR')
    disp('Guardando señal de ruido')
    ch1=mean(cat(3,ch1_join{:}),3); % Se saca el promedio de las señales de ruido de todas las pruebas
    ch2=mean(cat(3,ch2_join{:}),3);
    save('CH1_'+(string(A)),'ch1'); % Se guardan la señal promedio filtrada
    save('CH2_'+(string(A)),'ch2');
end

% Se resta la señal de ruido de fondo para el cálculo del delta*
if strcmp(A,'aerosoles_seco11')||strcmp(A,'humedad')
    disp('Restando ruido')
    %importfile('CH1_Ruido de fondo.mat')
    %importfile('CH2_Ruido de fondo.mat')
    for k=1:n
        ch1_join{1,k}=ch1_join{1,k}-ch1;
        ch2_join{1,k}=ch2_join{1,k}-ch2;
    end
end
  

%}

ch1_join = datos_ch1.dataCh1;

ch2_join = datos_ch2.dataCh2;

k=1;

tiny= abs((ch1_join)*1e3)<1;    % Se evitan divisiones cercanas a 0
ch1_join(tiny)=[];
ch2_join(tiny)=[];
    
    if strcmp(A,'aerosoles_secos')||strcmp(A,'humedad')
    	delta=ch2_join./ch1_join;   % Señal Reflejada(CH2)/transmitida(CH1)
        neg= delta<0;
        delta(neg)=[];
        eta_values(1,k)= mean(delta)
    else
        eta =ch2_join./ch1_join;   % Señal Reflejada(CH2)/transmitida(CH1)
        neg= eta<0;
        eta(neg)=[];
        eta_values(1,k)=mean(eta)
    end      

if strcmp(A,'aerosoles_secos')||strcmp(A,'humedad')
    save('delta_'+string(A),'delta');
    a=delta;
else
    save('eta_'+string(A),'eta');
    a=eta;
end

%%
figure(2)

t2=linspace(0,90,length(a));
means=eta_values(1,k)*ones([1,length(t2)]);
    
nexttile
plot(t2,a)
hold on
plot(t2,means)
legend('delta '+string(A),'delta promedio')
title(sprintf('Prueba %d',k))
%xlim([0 90])
xlabel('[s]')


title('delta húmedo')
disp('Saving plot');
exportgraphics(gcf,'eta'+string(A)+'.eps');
pause(10)
movefile('eta'+string(A)+'.eps',fullfile(D,F,A));

%%


%}


