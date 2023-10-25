clear; 
close all;
clc;

% cantidad de cargas positivas y negativas, puede ser modificado
cargasPos = 100;
cargasNeg = 200;

% posiciones en Y antes del cero para calculos:
% si el residuo de la division no es cero, es decir el numero no es par,
% se toma el valor de las cargas entre 2 mas 0.5 para poder graficar la
% misma cantidad de cargas en el lado positivo y el negativo de el plano
% cartesiano
if mod(cargasPos, 2) == 0
    antCeroPos = cargasPos / 2;
elseif mod(cargasPos, 2) ~= 0
    antCeroPos = (cargasPos / 2) + 0.5;
end
if mod(cargasNeg, 2) == 0
    antCeroNeg = cargasNeg / 2;
elseif mod(cargasNeg, 2) ~= 0
    antCeroNeg = (cargasNeg / 2) + 0.5;
end


% posicion de las cargas postitivas, las cargas en Y se incializan como un
% vector vacio del tamaño de la cantidad de cargas, variando si son
% positivas o negativas, la posicion en x puede ser modificada
xCarPos = 3.5; yCarPos = zeros(1, cargasPos);
% posicion de las cargas negativas
xCarNeg = 7.5; yCarNeg = zeros(1, cargasNeg);

% distancia entre cargas positivas y negativas, puede ser modificado
disPos = 0.01;
disNeg = 0.01;

% generamos las posiciones en Y negativas y positivas, aqui se utiliza la
% variable antCero definida en las lineas 14 - 23 para generar la misma
% cantidad de cargas en ambos lados del eje Y (positivo y negativo) el
% ciclo for a continuacion asigna una posicion a cada punto del vector de
% posicion de Y previamente incializado en ceros
for i = 1:cargasPos
    yCarPos(i) = (yCarPos(i) + (disPos * i)) - (disPos * antCeroPos);
end
for i = 1:cargasNeg
    yCarNeg(i) = (yCarNeg(i) + (disNeg * i)) - (disNeg * antCeroNeg);
end

% en un vector almacenamos las posiciones de las cargas, esto para poder
% graficar mas adelante con la funcion scatter
xPos = repmat(xCarPos, cargasPos, 1);
yPos = reshape(yCarPos, cargasPos, 1);
xyPos = [xPos, yPos]; % concatenamos las matrices

% repetimos para las negativas
xNeg = repmat(xCarNeg, cargasNeg, 1);
yNeg = reshape(yCarNeg, cargasNeg, 1);
xyNeg = [xNeg, yNeg]; % concatenamos las matrices

% crear malla de puntos usando linspace y meshgrid para calcular distancias
% y graficar el campo, asimismo definimos un vector de limites para los
% ejes de la grafica
x = linspace(-8, 8, 100);
y = linspace(-12, 12, 100);
[xMalla, yMalla] = meshgrid(x,y);
lims = [x(1,1), x(1,end), y(1,1), y(1,end)];

% definimos la constante de coulumb
ke = 8.9877e+09;
% magnitud de las cargas, pueden ser modificadas, sin embargo la carga qPos
% siempre debe ser un numero positivo, y qNeg siempre uno negativo, de otra
% manera se generaran errores en el campo electrico
qPos = 10;
qNeg = -20;

% calculo de las componentes en X y Y positivas, inciamos una matriz donde
% guardaremos las matrices con las componentes de cada una de las cargas
mExPos = {};
mEyPos = {};
for i = 1:cargasPos
    % primero sacamos la distancia entre la posicion en X y la posicion en
    % X de cada uno de los puntos de la malla
    rxPos = xMalla - xCarPos;
    ryPos = yMalla - yCarPos(i);
    % aplicamos teorema de pitagoras
    rPos = sqrt(rxPos.^2 + ryPos.^2);
    % calculamos las componentes en X de acuerdo a la ley de coulumb
    exPos = (ke * qPos * rxPos) ./ rPos;
    eyPos = (ke * qPos * ryPos) ./ rPos;
    % actualizamos las matrices de matrices cada ciclo
    mExPos{i} = exPos;
    mEyPos{i} = eyPos;
end

% calculo de las componentes en X y Y negativas, se repite el proceso
% anterior, pero esta vez con las cargas negativas
mExNeg = {};
mEyNeg = {};
for i = 1:cargasNeg
    rxNeg = xMalla - xCarNeg;
    ryNeg = yMalla - yCarNeg(i);
    rNeg = sqrt(rxNeg.^2 + ryNeg.^2);
    exNeg = (ke * qNeg * rxNeg) ./ rNeg;
    eyNeg = (ke * qNeg * ryNeg) ./ rNeg;
    mExNeg{i} = exNeg;
    mEyNeg{i} = eyNeg;
end

% calculo del campo electrico total en cada punto de la malla, para esto
% sumamos las matrices de X negativas y positivas y las matices de Y
% positivas y negativas una por una, el resultado va a ser una matriz con
% la suma total de los componentes
eX = zeros(size(xMalla));
eY = zeros(size(yMalla));
for i = 1:cargasPos
    eX = eX + mExPos{i};
    eY = eY + mEyPos{i};
end
for i = 1:cargasNeg
    eX = eX + mExNeg{i};
    eY = eY + mEyNeg{i};
end

% calculamos la magnitud del campo electrico
e = sqrt((eX).^2 + (eY).^2);

% Graficamos el campo eléctrico con quiver
figure(1);
hold on
quiver(xMalla, yMalla, eX, eY)
% scatter nos ayuda a graficar las cargas en la posicion que le asignamos,
% las positivas son verdes y las negativas azules
scatter(xPos(:,1), yPos(:,1), 50, 'g', 'filled', 'o');
scatter(xNeg(:,1), yNeg(:,1), 50, 'b', 'filled', 'o');
axis(lims)
hold off


% Graficamos el campo electrico con streamslice
figure(2);
hold on
streamslice(xMalla, yMalla, eX, eY)
scatter(xPos(:,1), yPos(:,1), 50, 'g', 'filled', 'o');
scatter(xNeg(:,1), yNeg(:,1), 50, 'b', 'filled', 'o');
axis(lims)
hold off

% Graficamos con Quiver y pcolor
figure(3);
hold on
% añadimos color con pcolor, esto nos va a dar un mapa de color que nos
% muestra la magnitud del campo en el plano cartesiano.
pcolor(xMalla, yMalla, e); colormap jet; shading interp;
graf = quiver(xMalla, yMalla, eX, eY);
scatter(xPos(:,1), yPos(:,1), 50, 'g', 'filled', 'o');
scatter(xNeg(:,1), yNeg(:,1), 50, 'b', 'filled', 'o');
set(graf, "color", [1,1,1]);
set(graf, "LineWidth", 1.5)
xlabel("eje-x")
ylabel("eje-y")
axis(lims)
hold off

% Graficamos con streamslice y pcolor
figure(4);
hold on
pcolor(xMalla, yMalla, e); colormap jet; shading interp;
graf = streamslice(xMalla, yMalla, eX, eY);
scatter(xPos(:,1), yPos(:,1), 50, 'g', 'filled', 'o');
scatter(xNeg(:,1), yNeg(:,1), 50, 'b', 'filled', 'o');
set(graf, "color", [1,1,1]);
set(graf, "LineWidth", 1.5)
xlabel("eje-x")
ylabel("eje-y")
axis(lims)
hold off