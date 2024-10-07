1. Resolver con Monitores el siguiente problema.
En un parque hay un juego para ser usado por N personas de a una a la vez y de acuerdo al orden en que llegan para solicitar su uso. Además hya un empleado encargado de desinfectar el juego durante 10 minutos antes de que una persona lo use. Cada persona al llegar espera hasta que el empleado le avisa que puede usar el juego, lo usa por un tiempo y luego lo devuelve.
**Nota: suponga que la persona tiene una función Usar_juego() que simula su trabajo.**

2. Resolver con Semáforos el siguiente problema. 
En una clínica hay un médico que debe atender a 20 pacientes de acuerdo al turno de cada uno de ellos (no puede atender al paciente con turno i+1 si aún no ha atendido al que tiene turno i). Cada paciente ya conoce su turno al comenzar (valor entero entre 0 y 19 o 1 y 20), al llegar espera hasta que el médico lo llame para ser atendido, se dirige al consultorio y luego espera hasta que el médico lo termine de atender para retirarse.
**Nota: los únicos procesos que se pueden usar son los que representen a los pacientes y al médico; se debe asegurar que nunca haya más de un paciente en el consultorio; no se puede usar el ID del proceso como turno.**

```cpp
    sem espera[20] = ([20],0)
    sem entrada = 0; listo= 0; salida=0;

    Process Medico(){
        int turno;

        for (turno=0; turno<20; turno++){
            V(espera[turno]);
            P(entrada);
            Atender_paciente();
            V(listo);
            P(salida);
        }
    }

    Process Paciente[id:0..19]{
        int miTurno = obtenerTurno();

        P(espera[miTurno]);
        V(entrada);
        //es atendido por el médico
        P(listo);
        V(salida);
    }

```