% Agregar la ruta del archivo TekVISA
addpath('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TekVISA');

% Crear un objeto VISA-USB.
interfaceObj = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x0699::0x0368::C032873::0::INSTR', 'Tag', '');

% Crear el objeto VISA-USB si no existe, de lo contrario usar el objeto encontrado.
if isempty(interfaceObj)

    interfaceObj = visa('NI', 'USB0::0x0699::0x0368::C032873::0::INSTR');
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end

% Crear el objeto del dispositivo.
deviceObj = icdevice('tektronix_tds2024.mdd', interfaceObj);
% deviceObj = icdevice('tektronix_tbs1102b-edu.mdd', interfaceObj);

% Conectar el objeto del dispositivo al hardware.
connect(deviceObj);

% Ajustar el tiempo de espera a 10 segundos
set(interfaceObj, 'Timeout', 10);

% Configuración del osciloscopio
groupObj = get(deviceObj, 'Waveform');

% Adquisición de datos durante x minutos

n= input("Duración de la medición en minutos: ");
duration = n*60; 


dataCh1 = [];
dataCh2 = [];
timeStamps = [];

% Configurar tasa de muestreo
samplingRate = 100; % Hz (10 ms por muestra)
interval = 1 / samplingRate; % Intervalo de tiempo entre muestras

startTime = datetime('now');
sampleCount = 0;

while seconds(datetime('now') - startTime) < duration
    try
        % Limitar la cantidad de datos leídos por iteración para no saturar el búfer
        maxSamples = 500; % número máximo de muestras por iteración
        
        % Leer datos del canal 1
        [y1, x1] = invoke(groupObj, 'readwaveform', 'channel1');
        
        % Leer datos del canal 2
        [y2, x2] = invoke(groupObj, 'readwaveform', 'channel2');
        
        % Número de muestras leídas
        numSamples = min(length(y1), maxSamples);
        
        % Almacenar datos
        dataCh1 = [dataCh1; y1(1:numSamples)'];
        dataCh2 = [dataCh2; y2(1:numSamples)'];
        
        % Calcular el tiempo para cada muestra
        if sampleCount == 0
            newTimeStamps = (0:numSamples-1)' * interval;
        else
            newTimeStamps = (sampleCount:(sampleCount + numSamples - 1))' * interval;
        end
        timeStamps = [timeStamps; newTimeStamps];
        
        % Actualizar contador de muestras
        sampleCount = sampleCount + numSamples;
        
    catch ME
        warning('Error reading data: %s', ME.message);
    end
    
    % Pausa adecuada para evitar sobrecargar la adquisición
    pause(interval * maxSamples);
end

% Desconexión y limpieza
disconnect(deviceObj);
delete(deviceObj);
clear deviceObj;
delete(interfaceObj);
clear interfaceObj;
timeStamps = timeStamps/1.14;

% Preguntar el nombre para los archivos de datos
filenameCh1 = input('Nombre para el archivo de datos del Canal 1: ', 's');
filenameCh2 = input('Nombre para el archivo de datos del Canal 2: ', 's');

% Guardar los datos en archivos .mat
save([filenameCh1, '.mat'], 'dataCh1', 'timeStamps');
save([filenameCh2, '.mat'], 'dataCh2', 'timeStamps');

disp('Datos guardados exitosamente.');
%% Graficar los datos filtrados
% Cargar los datos del archivo .mat-
filenameCh1 = input('Nombre para el archivo de datos del Canal 1: ', 's');
filenameCh2 = input('Nombre para el archivo de datos del Canal 2: ', 's');

save('tiempo_02102024.mat', 'timeStamps');

dataCh1_struct = load(filenameCh1);3
dataCh2_struct = load(filenameCh2);


% Extraer las señales de los datos cargados
dataCh1 = dataCh1_struct.dataCh1;  % Asumiendo que los datos del canal 1 están guardados bajo la variable 'dataCh1'
dataCh2 = dataCh2_struct.dataCh2;  % Asumiendo que los datos del canal 2 están guardados bajo la variable 'dataCh2'

[dataCh1_f, dataCh2_f] = Copy_of_fftfilter(dataCh1, dataCh2);

[~, nameCh1, extCh1] = fileparts(filenameCh1);  % Extraer el nombre y la extensión del archivo
[~, nameCh2, extCh2] = fileparts(filenameCh2);  % Extraer el nombre y la extensión del archivo

% Crear los nombres de archivo con 'f' al inicio
filenameCh1_f = ['f', nameCh1, extCh1];
filenameCh2_f = ['f', nameCh2, extCh2];

% Guardar los datos filtrados en archivos .mat
save(filenameCh1_f, 'dataCh1_f');
save(filenameCh2_f, 'dataCh2_f');

disp(['Datos filtrados guardados como: ', filenameCh1_f, ' y ', filenameCh2_f]);

% Número total de datos
numDatos = length(dataCh1);

% Tiempo total de adquisición en segundos (1 minuto)
totalTime = duration;  % segundos

% Calcular el intervalo de tiempo entre cada muestra
samplingInterval = totalTime / numDatos;  % segundos

% Crear el vector de tiempos
timeStamps = (0:numDatos-1) * samplingInterval;
hold on;

% Crear la primera figura con datos sin filtrar
figure;
subplot(2,1,1);
hold on;
plot(timeStamps, dataCh1, 'b');
plot(timeStamps, dataCh2, 'r');
title('Señal medida sin filtrar');
xlabel('Tiempo (s)');
ylabel('Voltaje (V)');
legend('Canal 1', 'Canal 2');
hold off;

% Crear la segunda figura con datos filtrados
subplot(2,1,2);
hold on;
plot(timeStamps, dataCh1_f, 'b');
plot(timeStamps, dataCh2_f, 'r');
title('Señal medida filtrada (FFT)');
xlabel('Tiempo (s)');
ylabel('Voltaje (V)');
legend('Canal 1 Filtrado', 'Canal 2 Filtrado');
hold off;
% Agregar etiquetas para los canales
legend('Canal 1 ll', 'Canal 2');

hold off;

%% Mean data 
 % Directorio donde están los archivos
folderPath = 'C:\Users\alejo\OneDrive\Desktop\ingeniería física\7mo\avanzado\CodesSQuiñonez_Osciloscopio\Taking Data';  % Cambia esta ruta a la carpeta donde están los archivos

% Buscar todos los archivos que empiecen por 'fR' y sean del canal 1
%filesCh1 = dir(fullfile(folderPath, 'fR*_CH1_20241002.mat'));  % Asumiendo que el canal 1 tiene '_Ch1' en el nombre
%filesCh2 = dir(fullfile(folderPath, 'fR*_CH2_20241002.mat'));  % Asumiendo que el canal 2 tiene '_Ch2' en el nombre

filesCh1 = dir(fullfile(folderPath, 'f*eta45_CH1_20241002.mat'));  % Asumiendo que el canal 1 tiene '_Ch1' en el nombre
filesCh2 = dir(fullfile(folderPath, 'f*eta45_CH2_20241002.mat'));  % Asumiendo que el canal 2 tiene '_Ch2' en el nombre

% Inicializar vectores para almacenar las medias
mediasCh1 = [];
mediasCh2 = [];

% Procesar los archivos del canal 1
for i = 1:length(filesCh1)
    % Cargar el archivo
    filenameCh1 = fullfile(folderPath, filesCh1(i).name);
    dataCh1_struct = load(filenameCh1);
    
    % Asumimos que la señal está guardada bajo 'dataCh1_f'
    if isfield(dataCh1_struct, 'dataCh1_f')
        dataCh1_f = dataCh1_struct.dataCh1_f;
        
        % Calcular la media de la señal
        mediaCh1 = mean(dataCh1_f);
        
        % Guardar la media en el vector
        mediasCh1 = [mediasCh1, mediaCh1];
    else
        warning('No se encontró "dataCh1_f" en el archivo: %s', filenameCh1);
    end
end

% Procesar los archivos del canal 2
for i = 1:length(filesCh2)
    % Cargar el archivo
    filenameCh2 = fullfile(folderPath, filesCh2(i).name);
    dataCh2_struct = load(filenameCh2);
    
    % Asumimos que la señal está guardada bajo 'dataCh2_f'
    if isfield(dataCh2_struct, 'dataCh2_f')
        dataCh2_f = dataCh2_struct.dataCh2_f;
        
        % Calcular la media de la señal
        mediaCh2 = mean(dataCh2_f);
        
        % Guardar la media en el vector
        mediasCh2 = [mediasCh2, mediaCh2];
    else
        warning('No se encontró "dataCh2_f" en el archivo: %s', filenameCh2);
    end
end

%% Calcular la media y desviación estándar de las medias
% Canal 1
mediaTotalCh1 = mean(mediasCh1);
desviacionCh1 = std(mediasCh1);

% Canal 2
mediaTotalCh2 = mean(mediasCh2);
desviacionCh2 = std(mediasCh2);

% Mostrar los resultados
fprintf('Canal 1 - Media Total: %.4f, Desviación Estándar: %.4f\n', mediaTotalCh1, desviacionCh1);
fprintf('Canal 2 - Media Total: %.4f, Desviación Estándar: %.4f\n', mediaTotalCh2, desviacionCh2);

%% Guardar los datos, REVISAR QUE GUARDE AMBOS, 

