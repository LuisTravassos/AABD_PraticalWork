
--------------------------------------------------------
--  DDL for Function B_CUSTO_DA_CHAMADA
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SQL_Project"."B_CUSTO_DA_CHAMADA" (
  idChamada number
) return float is

  cursor c1 is
    select 
      ct.id_contrato as ctID,
      
      ta.ID_TARIFARIO as taID, 
      ta.VALORUNIDADE as taValorUn,
      ta.tipo as taTipo,
      ta.ESTADO as taEstado,

      ch.tipo as chTipo,

      nt.MIN_GASTOS as ntMin,
      nt.SMS_GASTOS as ntSms,
      nt.saldo as ntSaldo,

      pps.ID_PLANO as ppsId,
      pps.estado as ppsEstado,
      pps.VALOR_SERVICO as ppsValSer,
      pps.NOME as ppsNome
      
    from
      chamada ch
      join num_telefone nt on ch.numero = nt.numero
      join contrato ct on nt.numero = ct.numero
      left join tarifario ta on ct.id_tarifario = ta.id_tarifario
      
      left join associado ass on ct.ID_CONTRATO = ass.ID_CONTRATO
      left join plano_pospago_simples pps on ass.ID_PLANO = pps.ID_PLANO
      
      join aplicavel ap on ta.ID_TARIFARIO = ap.ID_TARIFARIO
      and pps.ID_PLANO = ap.ID_PLANO
      
    where
      ch.id_chamada = idChamada
      and ta.ESTADO = 1
      and pps.ESTADO = 1;
      
  cursor c2 is
    select 
      carr.id_carregamento as carrId,
      carr.data_carreg as carrData,
      carr.valor as carrValor
    from
      chamada ch
      join num_telefone nt on ch.numero = nt.numero
      left join carregamento carr on ch.numero = carr.numero
    where
      ch.id_chamada = idChamada;

  helper number;
  duracao number;
  dados boolean := false;
  tarifarioValue number;
  total float := 0;
  planosMin number;
  planosSms number;
  ntMin number;
  ntSms number;
  preTime number;
  carregamentos boolean := false;
  nDays number;
  
begin
  select count(id_chamada) 
  into helper
  from chamada
  where ID_CHAMADA = idChamada;
  
  if (helper <= 0) then
    raise_application_error(-20514, 'Inv�lido Identificador de chamada: '||idChamada);
  end if;
 
  for i in c1 loop
    dados := true;

    if(upper(i.taTipo) = upper(i.chTipo)) then

      if (upper(i.chTipo) = 'VOZ') then
        select extract(minute from (chv.data_fim - chv.data_inicio)) into duracao
        from chamada_voz chv
        where chv.id_chamada = idChamada;
        
        tarifarioValue := i.taValorUn * duracao;
      
      elsif (upper(i.chTipo) = 'SMS') then
        tarifarioValue := i.taValorUn;
        
      elsif (upper(i.chTipo) = 'OUTRO') then
        select extract(minute from (cho.data_fim - cho.data_inicio)) into duracao
        from outras_chamadas cho
        where cho.id_chamada = idChamada;
        
        tarifarioValue := i.taValorUn * duracao;
      end if;
      
    else 
      raise_application_error(-20531, 'Contrato: '|| i.ctID || ' nao possui um tarifario compativel com a chamada');
    end if;

    if(INSTR(i.ppsNome, 'PPS ')>0) then
      total := tarifarioValue;
      
    elsif(INSTR(i.ppsNome, 'PPP ')>0) then
      select minutos, sms 
      into planosMin, planosSms
      from PLANO_POSPAGO_PLAFOND
      where id_plano = i.ppsId;
      
      if(i.ntMin > planosMin or i.ntSms > planosSms) then
        total := tarifarioValue;
      else
        total:= 0;
      end if;
      
    elsif(INSTR(i.ppsNome, 'PP ')>0) then
      select minutos, sms, numero_dias
      into planosMin, planosSms, preTime
      from PLANO_PREPAGO
      where id_plano = i.ppsId;
      
      for j in c2 loop

        if ((sysdate-j.carrData < preTime) 
          AND (i.ppsValSer <= j.carrValor) 
          AND ((NVL(planosMin, 99999) > i.ntMin) or (NVL(planosSms,99999) > i.ntSms))) then
            total := 0;
          
        else
          total := tarifarioValue;
          
        end if;
      end loop;

    end if;
  end loop;
  
  if(dados = false) then
    raise_application_error(-20594, 'Cursor c1 nao devolveu dados');
  end if;
  
  
  return total;
end;

/
--------------------------------------------------------
--  DDL for Function C_PRECO_POR_MINUTO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SQL_Project"."C_PRECO_POR_MINUTO" (tel_origem NUMBER, tel_destino NUMBER) 
RETURN NUMBER IS
      
      cursor c1 is
        select count(*) AS ncontra_feitos, ct.id_contrato AS ncontrato, ct.numero AS ntel
        from contrato ct
          join num_telefone nt ON ct.numero = nt.numero
        where ct.numero = tel_destino
        group by ct.id_contrato, ct.numero;
      
      cursor c2 is
        select id_plano as idppp, minutos
        from plano_pospago_plafond;
    
      cursor c3 is
          select id_plano as idpre, minutos
          from plano_prepago;
      
      cursor c4 is
          select pps.id_plano as idpps
          from plano_pospago_simples pps
            join associado ass on pps.id_plano = ass.id_plano
            join contrato ct on ass.id_contrato = ct.id_contrato
            join num_telefone nt on ct.numero = nt.numero
          where 
            nt.numero = tel_origem;

  planops boolean := false;
  planopp boolean := false;
  pprepago boolean := false;
  verificacao number;
  minGastos number(3);
  preco_pagar float := -1;
  valorunid float;
  unid varchar2(20);
  saldo number;
  valor number;

BEGIN
    select count(nt.numero) into verificacao
    from  num_telefone nt
    where nt.numero = tel_origem;
    
    if verificacao = 0 then
      RAISE_APPLICATION_ERROR(-20501, 'Numero de telefone ' ||tel_origem|| ' inexistente.');
    end if;
    
    select count(nt.numero) into verificacao
    from  num_telefone nt
    where nt.numero = tel_destino;
    
    if verificacao = 0 then
      RAISE_APPLICATION_ERROR(-20502, 'Invalido numero de telefone');
    end if;
    for r in c1
    loop
      select count(cm.id_contrato) into verificacao
      from cancelamento cm
        join contrato ct on cm.id_contrato= ct.id_contrato
      where ct.id_contrato = r.ncontrato;
      
      if r.ncontra_feitos = verificacao then
        RAISE_APPLICATION_ERROR(-20511, 'O numero ' ||tel_destino|| ' est� inativo');
      end if;
    end loop;
    
    for i IN c4
    loop
      for j in c2
      loop
        if i.idpps = j.idppp then
          planopp := true;
          valor := j.minutos;
        end if;
      end loop;
      
      if planopp = false then
        for k in c3 
        loop
          if(i.idpps = k.idpre) then
            pprepago := true;
            valor := k.minutos; 
          end if;
        end loop;
      end if;
      
      if pprepago = false then
        planops := true;
      end if;
    end loop;
    
    select min_gastos into minGastos
    from num_telefone
    where numero = tel_origem;
    
    if pprepago then
      if minGastos < valor then
         preco_pagar := 0;
         dbms_output.put_line('Plano pre pago com ' ||valor|| ' minutos ja gastou ' ||minGastos);
      else
          select t.unidade, t.valorunidade, nt.saldo into unid, valorunid, saldo
          from tarifario t
              join contrato ct on t.id_tarifario = ct.id_tarifario
              join num_telefone nt on ct.numero = nt.numero
          where ct.numero = tel_origem;
          
          if upper(unid) = 'MINUTO' then
              if(saldo < valorunid) then
                 RAISE_APPLICATION_ERROR(-20508, 'Telefone sem saldo');
              else
                preco_pagar := valorunid;
              end if;
          else
              RAISE_APPLICATION_ERROR(-20507, 'Servi�o indisponivel');
          end if;
      end if;
      
    elsif planopp then
       dbms_output.put_line('Plano pos pago plafond gastou ' || minGastos || ' minutos');
       if valor < minGastos then
         preco_pagar := 0;
         dbms_output.put_line('Plano pos pago plafond com ' ||valor|| ' minutos ja gastou ' ||minGastos);
      else
          select t.unidade, t.valorunidade, nt.saldo into unid, valorunid, saldo
          from tarifario t
              join contrato ct on t.id_tarifario = ct.id_tarifario
              join num_telefone nt on ct.numero = nt.numero
          where ct.numero = tel_origem;
          
          if upper(unid) = 'MINUTO' then
              if(saldo < valorunid) then
                RAISE_APPLICATION_ERROR(-20508, 'Telefone sem saldo');
              else
                preco_pagar := valorunid;
              end if;
          else
              RAISE_APPLICATION_ERROR(-20507, 'Servi�o indisponivel');
          end if;
      end if;
      
    elsif planops then
      select t.unidade, t.valorunidade, nt.saldo into unid, valorunid, saldo
          from tarifario t
              join contrato ct on t.id_tarifario = ct.id_tarifario
              join num_telefone nt on ct.numero = nt.numero
          where ct.numero = tel_origem;
          
          if upper(unid) = 'MINUTO' then
              if(saldo < valorunid) then
                RAISE_APPLICATION_ERROR(-20508, 'Telefone sem saldo');
              else
                preco_pagar := valorunid;
              end if;
          else
              RAISE_APPLICATION_ERROR(-20507, 'Servi�o indisponivel');
          end if;
    else 
      dbms_output.put_line('Nenhum plano');
      select t.unidade, t.valorunidade, nt.saldo into unid, valorunid, saldo
          from tarifario t
              join contrato ct on t.id_tarifario = ct.id_tarifario
              join num_telefone nt on ct.numero = nt.numero
          where ct.numero = tel_origem;
          
          if upper(unid) = 'MINUTO' then
              if(saldo < valorunid) then
                RAISE_APPLICATION_ERROR(-20508, 'Telefone sem saldo');
              else
                preco_pagar := valorunid;
              end if;
          else
              RAISE_APPLICATION_ERROR(-20507, 'Servi�o indisponivel');
          end if;
    end if;
    
    return preco_pagar; 
END;

/
--------------------------------------------------------
--  DDL for Function D_TIPO_DE_CHAMADA_VOZ
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SQL_Project"."D_TIPO_DE_CHAMADA_VOZ" (
  num_telefone varchar2
) return varchar2 is
  helper number;
  
begin
  select count(numero) into helper
  from num_telefone
  where NUMERO = num_telefone;
  
  if(helper <= 0) then
    raise_application_error(-20501, 'N�mero de telefone '||num_telefone||' inexistente.');
  end if;
  
  if( not REGEXP_LIKE(num_telefone, '^[0-9]+$')) then
    raise_application_error(-20502, ' Invalido N�mero de telefone '||num_telefone);
  end if;
  
  select count(nt.numero) into helper
  from 
    num_telefone nt
    join contrato ct on nt.numero = ct.numero
  where 
    nt.numero = num_telefone
    and ct.valido = 1;
    
  if(helper <= 0) then
    raise_application_error(-20511, 'Numero '||num_telefone||' inativo');
  end if;
  
  select count(nt.numero) into helper
  from 
    num_telefone nt
    join contrato ct on nt.numero = ct.numero
    join tarifario ta on ct.id_tarifario = ta.id_tarifario
  where 
    nt.numero = num_telefone
    and ct.valido = 1
    and ta.estado = 1;
    
  if(helper <= 0) then
    raise_application_error(-20505, 'Tarif�rio n�o ativo.');
  end if;

  if(length(num_telefone) = 9) then
    if(num_telefone like '2%') then
      return 'Fixo Nacional';
      
    elsif(num_telefone like '9%') then 
      return 'Movel Nacional';
      
    elsif(num_telefone like '808%') then 
      return 'Movel Nacional';
      
    elsif(num_telefone like '800%') then 
      return 'Gratuito';  
    end if;  
    
  elsif(length(num_telefone) = 14) then
    if(num_telefone like '003512%') then
      return 'Fixo Nacional';
      
    elsif(num_telefone like '003519%') then 
      return 'Movel Nacional';
    end if;
    
  elsif(length(num_telefone) > 3 and num_telefone like '00%') then
    return 'Internacinal';  
    
  end if;

  raise_application_error(-20515, 'Gama de numeros indefinido.');
end;

/
--------------------------------------------------------
--  DDL for Function E_NUMERO_NORMALIZADO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SQL_Project"."E_NUMERO_NORMALIZADO" (num_telefone VARCHAR)
RETURN VARCHAR
IS
  v_numero_normalizado VARCHAR(255); 
BEGIN

  v_numero_normalizado := REGEXP_REPLACE(num_telefone, '[[:space:]-]', '');

  IF SUBSTR(v_numero_normalizado, 1, 5) = '00351' THEN

    v_numero_normalizado := SUBSTR(v_numero_normalizado, 6);
  END IF;

  RETURN v_numero_normalizado;
END;

/
--------------------------------------------------------
--  DDL for Function H_PODE_REALIZAR_A_CHAMADA
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SQL_Project"."H_PODE_REALIZAR_A_CHAMADA" (
  num_de_origem IN contrato.numero%TYPE,
  num_de_destino IN VARCHAR2
) RETURN VARCHAR2
IS
  num_telef NUMBER;
  saldo NUMBER;
  tipo_rede VARCHAR2(100);
BEGIN

  SELECT COUNT(*) INTO num_telef
  FROM contrato ct
  WHERE ct.numero = num_de_origem;

  IF num_telef = 0 THEN
    RAISE_APPLICATION_ERROR(-20502, 'N�mero de telefone inv�lido.');
  END IF;

  SELECT num.saldo INTO saldo
  FROM num_telefone num
  JOIN contrato ct ON num.numero = ct.numero
  WHERE ct.numero = num_de_origem;

  IF saldo <= 0 THEN
    RAISE_APPLICATION_ERROR(-20508, 'Telefone sem saldo.');
  END IF;

  tipo_rede := d_tipo_de_chamada_voz(num_de_destino);

  RETURN tipo_rede;
END;

/
--------------------------------------------------------
--  DDL for Function J_GET_SALDO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SQL_Project"."J_GET_SALDO" (p_numero VARCHAR, tipo VARCHAR) 
RETURN NUMBER
IS
  v_numero NUMBER;
  v_saldo NUMBER;
  v_minutos NUMBER;
  v_sms NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_numero
  FROM num_telefone num
  WHERE num.numero = p_numero; 

  IF v_numero = 0 THEN
    RAISE_APPLICATION_ERROR(-20502, 'Numero de telefone invalido');
  END IF;

  IF UPPER(tipo) = UPPER('valor') THEN
    SELECT num.saldo INTO v_saldo
    FROM num_telefone num
    WHERE num.numero = p_numero;
    RETURN v_saldo;



  ELSIF UPPER(tipo) = UPPER('voz') THEN
    SELECT ppp.minutos INTO v_minutos
    FROM plano_pospago_plafond ppp
    JOIN plano_pospago_simples pps ON ppp.id_plano = pps.id_plano
    JOIN associado ass ON pps.id_plano = ass.id_plano
    JOIN contrato ct ON ass.id_contrato = ct.id_contrato
    WHERE ct.numero = p_numero;

    RETURN v_minutos;


  ELSIF UPPER(tipo) = UPPER('sms') THEN 
    SELECT ppp.sms INTO v_sms
    FROM plano_pospago_plafond ppp
    JOIN plano_pospago_simples pps ON ppp.id_plano = pps.id_plano
    JOIN associado ass ON pps.id_plano = ass.id_plano
    JOIN contrato ct ON ass.id_contrato = ct.id_contrato
    WHERE ct.numero = p_numero;

    RETURN v_sms;
  END IF;

  RAISE_APPLICATION_ERROR(-20519, 'Tipo de saldo invalido');

END;

/
--------------------------------------------------------
--  DDL for Function M_FUNC_2021136600
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SQL_Project"."M_FUNC_2021136600" (
  idPlano number,
  idTarifario number,
  associar varchar2
) return varchar2 is
  
  result varchar2(50) := 'false';
  helper number;
  
begin

  select count(id_tarifario) into helper
  from tarifario
  where ID_TARIFARIO = idTarifario;

  if (helper <= 0) then
    raise_application_error(-20503, 'Tarif�rio inexistente.');
  end if;
  
  select count(id_plano) into helper
  from PLANO_POSPAGO_SIMPLES
  where ID_PLANO = idPlano;

  if (helper <= 0) then
    raise_application_error(-20516 ,'Plano inexistente.');
  end if;
  
  select count(id_plano) into helper
  from aplicavel
  where ID_PLANO = idPlano
  and ID_TARIFARIO = idTarifario;

  if ((upper(associar) like 'S%') and helper <= 0) then
    insert into aplicavel(ID_PLANO, ID_TARIFARIO) values (idPlano, idTarifario);
    result := 'associados -> true';
 
  elsif (helper > 0) then
    result := 'true';
    
  end if;

  return result;
end;

/
--------------------------------------------------------
--  DDL for Function M_FUNC_2021138149
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SQL_Project"."M_FUNC_2021138149" (numer number)
return number is
    minGastos number;
    
    cursor c1 is
      select count(nt.numero) as counter, nt.min_gastos as gasto
      from num_telefone nt
      where nt.numero = numer
      group by nt.min_gastos;
    
begin
    for r in c1 loop
      if r.counter = 0 then
        raise_application_error(-20501, 'Numero de telefone ' ||numer|| ' inexistente.');
      else
        minGastos := r.gasto;
      end if;
      
      return minGastos;
    end loop;
end;

/
--------------------------------------------------------
--  DDL for Function M_FUNC_2021142527
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SQL_Project"."M_FUNC_2021142527" (
  p_id_contrato NUMBER,
  p_mes DATE
  )
RETURN NUMBER 
IS
  v_id_contrato NUMBER;
  v_id_chamada NUMBER;
  v_preco_chamada NUMBER;
  v_preco_total NUMBER := 0;
  v_desc_voz NUMBER;
  
  cursor c1 is 
  select cvz.id_chamada
  from chamada_voz cvz
  join chamada ch on cvz.id_chamada = ch.id_chamada
  join num_telefone num on ch.numero = num.numero
  join contrato ct on num.numero = ct.numero
  where ct.id_contrato = p_id_contrato 
  and TRUNC(cvz.data_inicio, 'MONTH') = TRUNC(p_mes, 'MONTH');
  
BEGIN

  select count(id_contrato) into v_id_contrato
  from contrato ct
  where id_contrato = p_id_contrato;
    
  if v_id_contrato = 0 then
      RAISE_APPLICATION_ERROR(-20509, 'Contrato inexistente.');
  end if;
  
  
  select count(cam.desconto_voz) into  v_desc_voz
  from contrato ct
  join tarifario tr on ct.ID_TARIFARIO = tr.ID_TARIFARIO
  join num_telefone num on ct.numero = num.numero
  join adere adr on num.numero = adr.numero
  join grupo gr on adr.id_grupo = gr.id_grupo
  join campanha cam on gr.id_campanha = cam.id_campanha
  where ct.ID_CONTRATO = p_id_contrato
  and upper(tr.tipo) = upper('VOZ');
  
  if v_desc_voz = 0 then
      RAISE_APPLICATION_ERROR(-10522, 'Numero do contrato nao pertence a nehuma campanha');
  end if;
  
  select cam.desconto_voz into  v_desc_voz
  from contrato ct
  join tarifario tr on ct.ID_TARIFARIO = tr.ID_TARIFARIO
  join num_telefone num on ct.numero = num.numero
  join adere adr on num.numero = adr.numero
  join grupo gr on adr.id_grupo = gr.id_grupo
  join campanha cam on gr.id_campanha = cam.id_campanha
  where ct.ID_CONTRATO = p_id_contrato
  and upper(tr.tipo) = upper('VOZ');
  
  
  OPEN c1;
    LOOP
    FETCH c1 INTO v_id_chamada;
    
    EXIT WHEN c1%NOTFOUND;
    
    v_preco_chamada := b_custo_da_chamada(v_id_chamada) - v_desc_voz; 

    v_preco_total := v_preco_total + v_preco_chamada;
    
    END LOOP;
  
  CLOSE c1;
  
  
  RETURN v_preco_total;

END;

/
