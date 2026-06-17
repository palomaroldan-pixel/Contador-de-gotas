# Contador-de-gotas

*Asignatura:* Electrónica Digital II - Universidad Nacional de Córdoba

*Integrantes:*

*Perotti, Josefina

*Roldan, Paloma

*Villafañe, Maria Dolores

*Profesor: Blasco, Marcos Javier*

1. Descripción General del Proyecto
   
El proyecto consiste en el desarrollo de  un sistema capaz de monitorear y regular el caudal de goteo de una solución intravenosa para pacientes en UTI (Unidad de Terapia Intensiva). En un principio, desde la computadora, el usuario deberá elegir entre dos valores posibles de caudales: 20 gotas para aquellos pacientes que se encuentren más estables, y 30 para aquellos que se encuentren más graves. 
Mediante un sensor infrarrojo, el microcontrolador PIC16F887 detecta el paso de las gotas y, a partir de esta información, muestra en dos displays la cantidad de gotas por minuto. Luego, el usuario deberá comparar el valor mostrado en los displays con el valor seteado deseado y con esa información, dependiendo si el goteo fue mayor o menor a lo esperado, podrá decidir con dos botones, si abrir o cerrar el canal del gotero.

1.1. Alcances del proyecto

El sistema es capaz de:

*Detectar el paso de gotas utilizando un sensor infrarrojo.

*Convertir la señal del sensor mediante el ADC interno del PIC16F887.

*Contabilizar la cantidad de gotas detectadas.

*Mostrar el conteo en dos displays de siete segmentos multiplexados.

*Recibir comandos desde una computadora mediante UART.

*Controlar el sentido de giro de un motor paso a paso.

*Configurar objetivos de conteo mediante comunicación serie.

Fuera de alcance

*Regulación automática cerrada del caudal.

*Almacenamiento histórico de datos.

*Conectividad inalámbrica (WiFi/Bluetooth).

*Interfaz gráfica dedicada.

*Alarmas clínicas certificadas.

*Validación clínica en pacientes.

1.2. Posibles etapas futuras

Como trabajo futuro, el sistema podría incorporar un lazo de control automático que permita ajustar el motor paso a paso de manera autónoma para mantener el caudal deseado. De esta forma, el equipo sería capaz de corregir variaciones en el flujo sin intervención del usuario.
Asimismo, podrían añadirse alarmas sonoras y visuales para alertar sobre fallas o desvíos del caudal programado. También sería posible desarrollar una interfaz gráfica con comunicación inalámbrica para realizar el monitoreo remoto del sistema en tiempo real.
Finalmente, se podrían incorporar funciones de almacenamiento de datos y cálculo automático de parámetros como las gotas por minuto y el volumen total infundido, brindando un seguimiento más completo del tratamiento.

2. Arquitectura del Sistema
2.1. Hardware e Interconexión
Diagrama de bloques:

Imágen 1: Diagrama de bloques

Esquema del circuito:

Imágen 2: Esquemático del circuito

Descripción del circuito

El sensor infrarrojo se conecta al canal analógico AN0 del PIC16F887. La señal generada por el sensor es digitalizada mediante el ADC interno. Los displays de siete segmentos son controlados mediante multiplexado utilizando PORTD para los segmentos y PORTB para la selección de cada display. La comunicación con la computadora se realiza mediante el módulo EUSART del microcontrolador utilizando los pines RC6 (TX) y RC7 (RX). El motor paso a paso 28BYJ-48 es accionado mediante un módulo ULN2003 conectado al PORTC.

2.2. Arquitectura de Software

El firmware se basa en una arquitectura de interrupciones.

Las principales tareas son:

Multiplexado de displays mediante Timer0.

Detección de gotas mediante interrupciones del ADC.

Recepción de comandos UART.

Control de movimiento del motor paso a paso.

Conversión del conteo de gotas para visualización decimal.

Imágen 3: Diagrama de flujo


3. Especificaciones eléctricas, alimentación y entorno.

3.1. Parámetros de alimentación y consumo.

3.1.1. Tensión de operación del sistema: 5V

3.1.2. Método de alimentación: para el PIC16F887, se decidió alimentarlo con USB, mientras que para los sensores infrarrojos y motor paso a paso, se utilizó una fuente de alimentación externa de 5V.

3.1.3. Consumo estimado: 

Modo activo: aproximadamente 200 mA a 300 mA (dependiendo del motor).
PIC únicamente: aproximadamente 10 mA.

3.2. Herramientas de software: MPLAB X IDE [v5.35] y compilador XC8 [v5.87]

3.3. Hardware de Programación/Depuración: Pickit 3.

3.4. Configuración de bits:

Oscilador: INTRC (Oscilador interno)

Watchdog Timer: OFF

Master Clear: ON

3.5. Periféricos utilizados:

ADC
Timer0
EUSART
Interrupciones externas
Puertos digitales

3.6. Gestión de interrupciones
El PIC16F887 posee un único vector de interrupción ubicado en la dirección 0x0004.
La prioridad se implementa mediante software evaluando secuencialmente las banderas:
Timer0
ADC
UART

Timer0 se verifica primero porque garantiza el correcto refresco de los displays y evita parpadeos perceptibles. Luego, se tiene en cuenta la conversión del ADC realizada por el sensor IR al momento de detección de gotas, y por último, el envío de caracteres por medio del USB/UART.


4. Proceso de Integración y Desarrollo

Etapa 1: Configuración inicial del microcontrolador.

Oscilador interno.

Configuración de puertos.

Encendido de LEDs de prueba.

Etapa 2: Implementación del ADC.

Lectura del sensor infrarrojo.

Ajuste de umbrales de detección.

Conteo básico de gotas.

Etapa 3: Implementación de displays.

Conversión decimal.

Multiplexado mediante Timer0.

Etapa 4: Implementación de UART.

Recepción de comandos.

Envío de mensajes de estado.

Etapa 5: Implementación del motor paso a paso.

Giro horario.

Giro antihorario.

Integración con comandos UART.

Etapa 6: Integración completa.

Sensor.

Displays.

UART.

Motor.

Interrupciones.

5. Ensayo, pruebas y resultados.

El ensayo más importante que consideramos fue el del sensor: queríamos saber si era capaz de detectar o no la gota de agua proveniente del suero. Para que lo hiciera de manera correcta, lo que hicimos fue perforar el perfus del suero para introducir por allí el sensor, y que de esta manera solo sea capaz de detectar el agua, y no las paredes del recipiente. 

Imágen 4: Parte del perfus perforada.


Imágen 5: Sensor IR colocado en el perfus.


Para el motor, primero se comprobó su correcto funcionamiento programando un código para que éste girara sin parar. Luego, se programó para que girara una cierta cantidad de grados en sentido horario y luego en sentido antihorario, nuevamente sin parar. Después, se colocaron dos botones de forma temporaria para introducir en el código la posibilidad de hacer que gire hacia un lado una cantidad definida de grados, y con el otro botón, hacia el lado contrario. Por último, se eliminaron los botones y se coordinó el sentido de giro por medio de comunicación serie.


Imágen 6: Motor paso a paso 28byj-48

Por último, se testeó la conexión bidireccional del PIC con la PC usando el programa de visualización Tera Term. Se probó cada comando en orden para verificar que la conexión sea satisfactoria.

Imágen 7: comunicación serie usando Tera Term.

Las pruebas realizadas validaron el correcto funcionamiento del código y del circuito tanto en la simulación en Proteus como en la realidad.


Imágen 8: Circuito final.

7. Conclusiones.
   
En este trabajo se desarrolló un prototipo de control y monitoreo de goteo basado en el microcontrolador PIC16F887. El sistema permite detectar el paso de gotas mediante un sensor infrarrojo, visualizar el conteo en displays de siete segmentos, comunicarse con una computadora a través de UART y accionar un motor paso a paso para regular el caudal. De esta manera, se integraron conceptos de conversión analógica-digital, manejo de interrupciones, multiplexado de displays, comunicación serial y control de actuadores.


9. Bibliografía
   
Datasheet de sensor IR HW 201: https://www.handsontec.com/dataspecs/sensor/IR%20Obstacle%20Detector.pdf
Datasheet motor paso a paso 28BYJ-48: https://www.alldatasheet.com/datasheet-pdf/pdf/1132391/ETC1/28BYJ-48.html
