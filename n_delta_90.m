% Directorio donde están los archivos
folderPath = 'C:\Users\alejo\OneDrive\Desktop\ingeniería física\7mo\avanzado\CodesSQuiñonez_Osciloscopio\Taking Data';  % Cambia esta ruta a la carpeta correcta

% Buscar todos los archivos para eta0 y eta90
filesCh1_eta0 = dir(fullfile(folderPath, 'f*eta0_CH1_20241002.mat'));  % Canal 1 eta0
filesCh2_eta0 = dir(fullfile(folderPath, 'f*eta0_CH2_20241002.mat'));  % Canal 2 eta0
filesCh1_eta90 = dir(fullfile(folderPath, 'f*eta90_CH1_20241002.mat')); % Canal 1 eta90
filesCh2_eta90 = dir(fullfile(folderPath, 'f*eta90_CH2_20241002.mat')); % Canal 2 eta90

% Inicializar vector para almacenar medias de eta90
medias_delta90 = [];

totalTime = 3 * 60;

for i = 1:length(filesCh1_eta0)
    % Cargar archivos para eta0
    filenameCh1_eta0 = fullfile(folderPath, filesCh1_eta0(i).name);
    filenameCh2_eta0 = fullfile(folderPath, filesCh2_eta0(i).name);
    dataCh1_eta0_struct = load(filenameCh1_eta0);
    dataCh2_eta0_struct = load(filenameCh2_eta0);
    
    % Cargar archivos para eta90
    filenameCh1_eta90 = fullfile(folderPath, filesCh1_eta90(i).name);
    filenameCh2_eta90 = fullfile(folderPath, filesCh2_eta90(i).name);
    dataCh1_eta90_struct = load(filenameCh1_eta90);
    dataCh2_eta90_struct = load(filenameCh2_eta90);
    
    % Extraer los datos de los archivos
    dataCh1_eta0 = dataCh1_eta0_struct.dataCh1_f;  % Asumiendo que están guardados como dataCh1_f
    dataCh2_eta0 = dataCh2_eta0_struct.dataCh2_f;
    
    dataCh1_eta90 = dataCh1_eta90_struct.dataCh1_f;
    dataCh2_eta90 = dataCh2_eta90_struct.dataCh2_f;
    
    % Calcular eta0 y eta90
    eta0 = dataCh2_eta0 ./ dataCh1_eta0;
    eta90 = dataCh2_eta90 ./ dataCh1_eta90;
    
    % Calcular delta90
    delta90 = sqrt(eta0 .* eta90);
    
    % Calcular la media de eta90 y almacenarla
    media_delta90 = mean(delta90);
    medias_delta90 = [medias_delta90, media_delta90];

     % Calcular el vector de tiempos
    numDatos = length(eta0);  % Suponiendo que el número de puntos en eta0 y eta90 es el mismo
    samplingInterval = totalTime / numDatos;  % Intervalo de tiempo entre cada muestra
    timeStamps = (0:numDatos-1) * samplingInterval;  % Vector de tiempo en segundos
    
    % Graficar eta0, eta90 y delta90
    figure;
    hold on;
    plot(timeStamps,eta0, 'b', 'DisplayName', '\eta(0^\circ)');
    plot(timeStamps,eta90, 'r', 'DisplayName', '\eta(90^\circ)');
    plot(timeStamps,delta90, 'y', 'DisplayName', '\Delta90');
    
    % Añadir una línea horizontal para la media de η(90°)
    % Añadir una línea horizontal para la media de delta90
    yline(media_delta90, '--k', 'Label', ['Media \delta(90^\circ) = ', num2str(media_delta90, '%.2f')], ...
      'LabelHorizontalAlignment', 'right', 'DisplayName', 'Media \delta(90^\circ)');
    % Configurar título, etiquetas y leyenda
    title('Valores de Calibración', 'Interpreter', 'tex');
    xlabel('Tiempo (s)', 'Interpreter', 'tex');
    ylabel('Valores de Calibración', 'Interpreter', 'tex');
    legend('show', 'Location', 'best');
    hold off;
end

% Calcular la media y desviación estándar de las medias eta90
mediaTotal_delta90 = mean(medias_delta90);
desviacion_delta90 = std(medias_delta90);

% Mostrar resultados finales en la consola sin problemas de secuencias de escape
fprintf('Media total de eta(90°): %.4f\n', mediaTotal_delta90);
fprintf('Desviación estándar de eta(90°): %.4f\n', desviacion_delta90);

save('N_DELTA_20240927.mat', 'mediaTotal_delta90');


