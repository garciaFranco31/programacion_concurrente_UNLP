# Parciales Semáforos

## Ejercicio 1) - 18 de diciembre, 2023 ✅

Se debe simular el uso de una máquina expendedora de gaseosas
con capacidad para 100 latas por parte de U usuarios. Además existe un repositor encargado de reponer las latas de la máquina. Los usuarios usan la máquina según el orden de llegada. Cuando les toca usarla, sacan una lata y luego se retiran. En el caso de que la máquina se quede sin latas, entonces le debe avisar al repositor para que cargue nuevamente la máquina en forma completa. Luego de la recarga, saca una lata y se retira.
**Nota: maximizar la concurrencia; mientras se reponen las latas se debe permitir que otros usuarios puedan agregarse a la fila.**

## Ejercicio 1) - 4 de diciembre, 2023 ✅

Un sistema debe validar un conjunto de 10000 transacciones que se encuentran disponibles en una estructura de datos. Para ello, el sistema dispone de 7 workers, los cuales trabajan colaborativamente validando de a 1 transacción por vez cada uno. Cada validación puede tomar un tiempo diferente y para realizarla los workers disponen de la función Validar(t), la cual retorna como resultado un número entero entre 0 al 9. Al finalizar el procesamiento, el último worker en terminar debe informar la cantidad de transacciones por cada resultado de la función de validación.
**Nota: maximizar la concurrencia.**

## Ejercicio 1) a) - 10 de octubre, 2023 ✅

En una estación de trenes, asisten P personas que deben realizar una carga de su tarjeta SUBE en la terminal disponible. La terminal es utilizada en forma exclusiva por cada persona de acuerdo con el orden de llegada. Implemente una solución utilizando sólo emplee procesos Persona.
**Nota: la función UsarTerminal() le permite cargar la SUBE en la terminal disponible.**

## Ejercicio 1) b) - 10 de octubre, 2023 ✅

Resuelva el mismo problema anterior pero ahora considerando que hay T terminales disponibles. Las personas realizan una única fila y la carga la realizan en la primera terminal que se libera. Recuerde que sólo debe emplear procesos Persona.
**Nota: la función UsarTerminal(t) le permite cargar la SUBE en la terminal t**

## Ejercicio 1) - Segundo recuperatorio 2022 ✅

En una planta verificadora de vehículos, existen 7 estaciones donde se dirigen 150 vehículos para ser verificados. Cuando un vehículo llega a la planta, el coordinador de la planta le indica a qué estación debe dirigirse. El coordinador selecciona la estación que tenga menos vehículos asignados en ese momento. Una vez que el vehículo sabe qué estación le fue asignada, se dirige a la misma y espera a que lo llamen para verificar. Luego de la revisión, la estación le entrega un comprobante que indica si pasó la revisión o no. Más allá del resultado, el vehículo se retira de la planta.
**Nota: maximizar la concurrencia.**

## - ✅

Existen 15 sensores de temperatura y 2 módulos centrales de procesamiento. Un sensor mide la temperatura cada cierto tiempo (función medir()), la envía al módulo central para que le indique qué acción debe hacer (un número del 1 al 10) (función determinar() para el módulo central) y la hace (función realizar()). Los módulos atienden las mediciones por orden de llegada.


## - ✅

Simular un exámen técnico para concursos Nodocentes en la Facultad, en el mismo participan 100 personas distribuidas en 4 concursos con un coordinador en cada una de ellos. Cada persona sabe en qué concurso participa. El coordinador de cada concurso espera hasta que lleguen las 25 personas correspondientes al mismo, les entrega el exámen a resolver (el mismo para todos los de ese concurso) y luego corrige los exámenes de esas 25 personas de acuerdo al orden en que van entregando. Cada persona al llegar debe esperar a que su coordinador (el de su concurso) le dé el exámen, lo resuelve, lo entrega para que su coordinador lo evalúe y espera hasta que le deje la nota para luego retirarse.
**Nota: maximizar la concurrencia; sólo usar procesos que representen a las personas y coordinadores; todos los procesos deben terminar.**

## - ✅

Un banco decide entregar promociones a sus clientes por medio de su agente de prensa, el cual lo hace de la siguiente manera: el agente debe entregar 50 premios entre los 1000 clientes, para esto, obtiene al azar un número de cliente y le entrega el premio, una vez que este lo toma continúa con la entrega.
**Notas: Cuando los 50 premios han sido entregados el agente y los clientes terminan su ejecución; No se puede utilizar una estructura de tipo arreglo para almacenar los premios de los clientes.**