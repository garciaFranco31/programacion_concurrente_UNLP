Procedure Puente1A is

    Task Puente is
        entry entrarAuto();
        entry entrarCamioneta();
        entry entrarCamion();
        entry salir(peso: IN integer);
    end Puente;

    Task body Puente is
        pesoActual: integer = 0;
    begin
        loop
            select
                when (pesoActual < 5) =>
                    accept entrarAuto() do
                        pesoAcutal:= pesoActual+1;
                    end entrarAuto;
                or
                when (pesoActual < 4) =>
                    accept entrarCamioneta() do
                        pesoAcutal:= pesoActual+2;
                    end entrarCamioneta;
                or
                when
                    when (pesoActual < 3) =>
                    accept entrarCamion() do
                        pesoAcutal:= pesoActual+3;
                    end entrarCamion;
                or
                accept salir(peso: IN integer) do
                    pesoActual:= pesoActual-peso;
                end salir;
            end select;
        end loop;
    end Puente;

    Task body Vehiculo is
        tipo: String;
    begin
        if(tipo = "Auto") then
            Puente.entrarAuto();
            Puente.salir(1);
        elsif (tipo = "Camioneta") then
            Puente.entrarCamioneta();
            Puente.salir(2);
        else
            Puente.entrarCamion();
            Puente.salir(3);
        end if;
    end Vehiculo;
    
    begin
        null;
end Puente1a;