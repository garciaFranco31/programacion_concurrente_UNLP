procedure Puente1B () is
    
    task Puente is
        entry entrarAuto();
        entry entrarCamioneta();
        entry entrarCamion();
        entry salir(peso: IN integer);
    end Puente;

    task body Puente is
        pesoActual: integer = 0;
    begin
        loop
            select
                when (pesoActual < 5) and (entrarCamion'count = 0)
                    accept entrarAuto() do
                        pesoActual:= pesoActual +1;
                    end entrarAuto;
            or
                when (pesoActual < 4) and (entrarCamion'count = 0)
                    accept entrarCamioneta() do
                        pesoActual:= pesoActual +2;
                    end entrarCamioneta;
            or
                when (pesoActual < 3) and (entrarCamion'count = 0)
                    accept entrarCamion() do
                        pesoActual:= pesoActual +3;
                    end entrarCamion;
            or
                accept salir(peso: IN integer) do
                    pesoActual:= pesoActual - peso;
                end salir;   
            end select;
        end loop;
    end Puente;

    task body Vehiculo is
        tipo: string;
    begin
        if(tipo = "Auto") do
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
end Puente1B;