% =========================================================================
% RETO 3: Algoritmo de control y cargas - Micro-red Inteligente
% Autor: Andrea Carolina Solano Amaya
% Programa: Ingeniería de Electronica - UNAD
% Materia: Software para Ingeniería
% =========================================================================
clc; clear; close all;

% --- 1. PARÁMETROS INICIALES ---
Capacidad_bat = 100; % Capacidad en kWh
SOC = 50; % Estado de carga inicial en %

% Vectores de generación y demanda (Simulación de 24 horas)
Gen_Solar = [0 0 0 0 0 1 5 12 18 22 25 25 24 20 15 8 2 0 0 0 0 0 0 0];
Gen_Eolica = [5 6 5 4 5 6 7 8 8 7 6 5 6 7 8 9 8 7 6 5 5 4 5 6];
Dem_Escuela = [2 2 2 2 2 2 5 6 7 7 7 7 7 7 7 6 5 4 3 2 2 2 2 2];
Dem_Bombeo = [0 0 0 0 0 0 3 3 3 3 3 3 3 3 3 3 3 3 0 0 0 0 0 0];
Dem_Alumbrado = [3 3 3 3 3 2 0 0 0 0 0 0 0 0 0 0 0 1 3 3 3 3 3 3];

disp('=================================================================');
disp(' REPORTE DE OPERACIÓN DE LA MICRO-RED (CICLO DE 24 HORAS)');
disp('=================================================================');

% --- 2. CICLO DE EVALUACIÓN (24 HORAS) ---
for hora = 1:24
    % Cálculo del balance energético
    E_gen = Gen_Solar(hora) + Gen_Eolica(hora);
    E_dem = Dem_Escuela(hora) + Dem_Bombeo(hora) + Dem_Alumbrado(hora);
    Balance = E_gen - E_dem;

    % --- 3. ACTUALIZACIÓN DEL BANCO DE BATERÍAS ---
    if Balance >= 0 
        % Escenario de Superávit: Se carga la batería con el excedente
        SOC = SOC + (Balance / Capacidad_bat) * 100;
        if SOC > 100
            SOC = 100; % Límite superior de seguridad
        end
        Estado_Red = 'SUPERÁVIT';
    else
        % Escenario de Déficit: Se extrae el faltante de la batería
        SOC = SOC + (Balance / Capacidad_bat) * 100; % (El balance ya es un número negativo)
        if SOC < 0
            SOC = 0; % Límite inferior absoluto
        end
        Estado_Red = 'DÉFICIT  ';
    end

    % --- 4. PROTOCOLO DE DESCONEXIÓN DE CARGAS (LOAD SHEDDING) ---
    if SOC > 40
        % Ruta Segura: Todos los servicios activos
        Est_Escuela = 'ON ';
        Est_Bombeo = 'ON ';
        Est_Alum = 'ON ';
        Nivel_Alerta = 'SEGURA    ';
    elseif SOC > 20 && SOC <= 40
        % Ruta de Alerta: Se desconecta el alumbrado
        Est_Escuela = 'ON ';
        Est_Bombeo = 'ON ';
        Est_Alum = 'OFF';
        Nivel_Alerta = 'ALERTA    ';
    else
        % Ruta de Emergencia: Se desconecta alumbrado y bombeo
        Est_Escuela = 'ON ';
        Est_Bombeo = 'OFF';
        Est_Alum = 'OFF';
        Nivel_Alerta = 'EMERGENCIA';
    end

    % --- 5. IMPRESIÓN DEL REPORTE POR CONSOLA ---
    fprintf('Hora %02d | %s | SOC: %6.2f%% | %s | Escuela: %s | Bombeo: %s | Alumbrado: %s\n', ...
        hora, Estado_Red, SOC, Nivel_Alerta, Est_Escuela, Est_Bombeo, Est_Alum);
end

disp('=================================================================');
disp(' FIN DE LA SIMULACIÓN');
disp('=================================================================');