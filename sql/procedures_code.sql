--------------------------------------------------------
--  File created - Quinta-feira-Junho-08-2023   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure A_EMITE_FATURA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SQL_Project"."A_EMITE_FATURA" (
    nTelefone varchar2,
    anoMes varchar2 
) is

  cursor c1 is
    select 
      carr.valor as carrValor
      
    from num_telefone nt
      left join carregamento carr on nt.numero = carr.numero
      
    where nTelefone = nt.numero
      and carr.data_carreg between add_months(to_date(anoMes, 'YYYY-MM'), -1) and to_date(anoMes, 'YYYY-MM');  

  cursor c2 is
    select
      ch.id_chamada as chId
      
    from num_telefone nt
      join chamada ch on nt.numero = ch.numero
      
      left join chamada_voz chv on ch.id_chamada = chv.id_chamada
      left join outras_chamadas och on ch.id_chamada = och.id_chamada
      left join sms chs on ch.id_chamada = chs.id_chamada
      
    where nTelefone = nt.numero
      and (chv.data_inicio between add_months(to_date(anoMes, 'YYYY-MM'), -1) and to_date(anoMes, 'YYYY-MM')
      or och.data_inicio between add_months(to_date(anoMes, 'YYYY-MM'), -1) and to_date(anoMes, 'YYYY-MM')
      or chs.data_envio between add_months(to_date(anoMes, 'YYYY-MM'), -1) and to_date(anoMes, 'YYYY-MM'));

  dados boolean := false;
  helper number;
  custoChamadasTotal float := 0;
  custoCarregamentosTotal float := 0;
  custoPlano float := 0;
  custoTotal float := 0;
  
begin
  select count(numero) 
  into helper
  from num_telefone
  where nTelefone = numero;
  
  if (helper <= 0) then
    raise_application_error(-20501, 'Numero de telefone inexistente');
  end if;
  
  select count(nt.numero) into helper
  from 
    num_telefone nt
    join contrato ct on nt.numero = ct.numero
  where 
    nt.numero = nTelefone
    and ct.valido = 1;
    
  if(helper <= 0) then
    raise_application_error(-20511, 'Numero '||nTelefone||' inativo');
  end if;
  
  for i in c2 loop
    dados := true;
    custoChamadasTotal := custoChamadasTotal + b_custo_da_chamada(i.chId);
  end loop;
  
  for i in c1 loop
    custoCarregamentosTotal := custoCarregamentosTotal + i.carrValor;
  end loop;
  
  select 
    pps.VALOR_SERVICO into custoPlano
    
  from num_telefone nt
    
    join contrato ct on nt.numero = ct.numero
    join tarifario ta on ct.id_tarifario = ta.id_tarifario
    
    left join associado ass on ct.ID_CONTRATO = ass.ID_CONTRATO
    left join plano_pospago_simples pps on ass.ID_PLANO = pps.ID_PLANO
    
    join aplicavel ap on ta.ID_TARIFARIO = ap.ID_TARIFARIO
    and pps.ID_PLANO = ap.ID_PLANO
    
  where 
    nTelefone = nt.numero
    and ta.ESTADO = 1
    and pps.ESTADO = 1;
    
  custoTotal := custoPlano + custoCarregamentosTotal + custoChamadasTotal;
  
  if not REGEXP_LIKE(anoMes, '^\d{4}-\d{2}$') then
    raise_application_error(-20512, 'Periodo yyyy-mm invalido');
  end if;
  
  if(to_date(anoMes, 'yyyy-mm') > sysdate) then
    raise_application_error(-20513, 'Periodo ainda nao terminado');
  end if;
  
  select count(numero) into helper
  from fatura
  where numero = nTelefone
    and data_ini = add_months(to_date(anoMes, 'YYYY-MM'), -1)
    and data_fim = to_date(anoMes, 'YYYY-MM')
    and VALORTOTAL = custoTotal;
  
  if(helper > 0) then
    raise_application_error(-20510, 'Fatura j� foi emitida');
  else
    insert into fatura values (custoChamadasTotal, 
                              custoCarregamentosTotal, 
                              custoPlano, 
                              custoTotal,
                              nTelefone,
                              add_months(to_date(anoMes, 'YYYY-MM'), -1),
                              to_date(anoMes, 'YYYY-MM'));
  end if;
end;

/
--------------------------------------------------------
--  DDL for Procedure F_ENVIA_SMS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SQL_Project"."F_ENVIA_SMS" (num_de_origem VARCHAR, num_de_destino VARCHAR, mensagem VARCHAR)
IS
  NumInexistente exception;
    pragma exception_init (NumInexistente, -20501);
  NumInvalido exception;
    pragma exception_init (NumInvalido, -20502);
  NumSemSaldo exception;
    pragma exception_init (NumSemSaldo, -20508);
  TarInvalido exception;
    pragma exception_init (TarInvalido, -20505);
  NumInativo exception;
    pragma exception_init (NumInativo, -20511);
  ServIndes exception;
    pragma exception_init (NumInativo, -20507);
    
    CURSOR c1 IS
        SELECT count(*) AS ncontra_feitos, ct.id_contrato AS ncontrato, ct.numero AS ntel
        FROM contrato ct
          JOIN num_telefone nt ON ct.numero = nt.numero
        WHERE ct.numero = num_de_origem
        GROUP BY ct.id_contrato, ct.numero;
      
    cursor c2 is
        select id_plano as idppp, sms
        from plano_pospago_plafond;
    
    cursor c3 is
        select id_plano as idpre, sms
        from plano_prepago;
    
    cursor c4 is
        select pps.id_plano as idpps
        from plano_pospago_simples pps
          join associado ass on pps.id_plano = ass.id_plano
          join contrato ct on ass.id_contrato = ct.id_contrato
          join num_telefone nt on ct.numero = nt.numero
        where 
          nt.numero = num_de_origem;
    
  verificacao number(1);
  planops boolean := false;
  planopp boolean := false;
  pprepago boolean := false;
  maxIDcha number;
  valor number;
  smsGastos number;
  envia boolean := false;
  unid varchar2(20);
  valorunid float;
  saldo number;
BEGIN
    SELECT count(nt.numero) INTO verificacao
    FROM  num_telefone nt
    WHERE nt.numero = num_de_origem;
    
    IF verificacao = 0 THEN
      raise NumInexistente;
    END IF;
    
    SELECT count(nt.numero) INTO verificacao
    FROM  num_telefone nt
    WHERE nt.numero = num_de_destino;
    
    IF verificacao = 0 THEN
      raise NumInvalido;
    END IF;
    
    FOR r IN c1
    LOOP
      SELECT count(cm.id_contrato) INTO verificacao
      FROM cancelamento cm
        JOIN contrato ct ON cm.id_contrato= ct.id_contrato
      WHERE ct.id_contrato = r.ncontrato;
      
      IF r.ncontra_feitos = verificacao THEN
        raise NumInativo;
      END IF;
    END LOOP;
     
    for i IN c4
    loop
      for j in c2
      loop
        if i.idpps = j.idppp then
          planopp := true;
          valor := j.sms;
        end if;
      end loop;
      
      if planopp = false then
        for k in c3 
        loop
          if(i.idpps = k.idpre) then
            pprepago := true;
            valor := k.sms; 
          end if;
        end loop;
      end if;
      
      if pprepago = false then
        planops := true;
      end if;
    end loop;
    
    select sms_gastos into smsGastos
    from num_telefone
    where numero = num_de_origem;
    
    if pprepago then
      if valor < smsGastos then
         envia := true;
         dbms_output.put_line('Plano pre pago com ' ||valor|| ' ja gastou ' ||smsGastos);
      else
          select t.unidade, t.valorunidade, nt.saldo into unid, valorunid, saldo
          from tarifario t
              join contrato ct on t.id_tarifario = ct.id_tarifario
              join num_telefone nt on ct.numero = nt.numero
          where ct.numero = num_de_origem;
          
          if upper(unid) = 'SMS' then
              if(saldo < valorunid) then
                raise NumSemSaldo;
              else
                envia :=true;
              end if;
          end if;
          
      end if;
      
    elsif planopp then
       dbms_output.put_line('Plano pos pago plafond');
       if valor < smsGastos then
         envia := true;
         dbms_output.put_line('Plano pre pago com ' ||valor|| ' ja gastou ' ||smsGastos);
      else
          select t.unidade, t.valorunidade, nt.saldo into unid, valorunid, saldo
          from tarifario t
              join contrato ct on t.id_tarifario = ct.id_tarifario
              join num_telefone nt on ct.numero = nt.numero
          where ct.numero = num_de_origem;
          
          if upper(unid) = 'SMS' then
              if(saldo < valorunid) then
                raise NumSemSaldo;
              else
                envia :=true;
              end if;
          end if;
      end if;
      
    elsif planops then
      select t.unidade, t.valorunidade, nt.saldo into unid, valorunid, saldo
          from tarifario t
              join contrato ct on t.id_tarifario = ct.id_tarifario
              join num_telefone nt on ct.numero = nt.numero
          where ct.numero = num_de_origem;
          
          if upper(unid) = 'SMS' then
              if(saldo < valorunid) then
                raise NumSemSaldo;
              else
                envia :=true;
              end if;
          end if;
    else 
      dbms_output.put_line('Nenhum plano');
      select t.unidade, t.valorunidade, nt.saldo into unid, valorunid, saldo
          from tarifario t
              join contrato ct on t.id_tarifario = ct.id_tarifario
              join num_telefone nt on ct.numero = nt.numero
          where ct.numero = num_de_origem;
          
          if upper(unid) = 'SMS' then
              if(saldo < valorunid) then
                raise NumSemSaldo;
              else
                envia :=true;
              end if;
          end if;
    end if;
    
    select max(id_chamada) into maxIDcha
    from chamada;
    if envia then
      insert into chamada values(maxIDcha + 1, num_de_origem, num_de_destino, 'SMS');
      insert into sms values(maxIDcha + 1, sysdate, sysdate, MENSAGEM);
      dbms_output.put_line('Mensagem enviada com sucesso!');
    end if;
   
    EXCEPTION
      
      when NumInexistente then
        dbms_output.put_line('Erro: Numero de origem inexistente');
      when NumInvalido then
        dbms_output.put_line('Erro: N�mero de destino inv�lido.');
      when NumInativo then
        dbms_output.put_line('Erro: N�mero de origem inativo.');
      when ServIndes then
        dbms_output.put_line('Erro: Servi�o indispon�vel.');
      when NumSemSaldo then
        dbms_output.put_line('Erro: Telefone sem saldo.');
      
  
END;

/
--------------------------------------------------------
--  DDL for Procedure G_ESTABELECE_CHAMADA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SQL_Project"."G_ESTABELECE_CHAMADA" (
  num_de_origem varchar2,
  num_de_destino varchar2
) is

  NumInexistente exception;
    pragma exception_init (NumInexistente, -20501);
  NumInvalido exception;
    pragma exception_init (NumInvalido, -20502);
  NumInativo exception;
    pragma exception_init (NumInativo, -20511);
  TarInvalido exception;
    pragma exception_init (TarInvalido, -20505);
  NumIndefinido exception;
    pragma exception_init (NumIndefinido, -20515);
  
  cursor c1 is
    select
      ta.tipo as taTipo 
    from
      num_telefone nt
      join contrato ct on nt.numero = ct.numero
      join tarifario ta on ct.id_tarifario = ta.id_tarifario
      left join associado ass on ct.id_contrato = ass.id_contrato
      left join plano_pospago_simples pps on ass.id_plano = pps.id_plano
      join aplicavel ap on ta.ID_TARIFARIO = ap.ID_TARIFARIO
      and pps.ID_PLANO = ap.ID_PLANO
    where
      nt.numero = num_de_origem
      and ct.valido = 1
      and ta.estado = 1
      and pps.estado = 1
    group by 
      ta.tipo;

  helper varchar2(150);
  dados boolean := false;
  
begin
  helper := D_TIPO_DE_CHAMADA_VOZ(num_de_origem);
  helper := D_TIPO_DE_CHAMADA_VOZ(num_de_destino);
  
  for i in c1 loop
    dados := true;
    
    insert into chamada values(
      SeqIdChamada.nextval, 
      num_de_origem, 
      num_de_destino, 
      i.taTipo);
    
    insert into eventos values(
      SeqIdEvento.nextval,
      SeqIdChamada.currval,
      sysdate, 
      null, 
      'Chamada Iniciada');
    
  end loop;
  
  if(dados = false) then
    raise_application_error(-20532, 'Tarifario nao aplicavel com Plano contrato');
  end if;
end;

/
--------------------------------------------------------
--  DDL for Procedure K_NOVO_CONTRATO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SQL_Project"."K_NOVO_CONTRATO" (
    nif1 VARCHAR, 
    nome1 VARCHAR, 
    plano VARCHAR, 
    tarifario VARCHAR,
    periodo_meses NUMBER
) IS
    
    cursor c1 is
      select count(pps.id_plano), pps.estado as esta, pps.id_plano as idplano
      from plano_pospago_simples pps
      where upper(pps.nome) = upper(plano)
      group by pps.estado, pps.id_plano;
      
    cursor c2 is
      select count(id_tarifario), id_tarifario idtar
      from tarifario t
      where upper(t.nome) = upper(tarifario)
      group by id_tarifario;
    
    nifCliente exception;
      pragma exception_init (nifCliente, -20518);
    planoInexis exception;
      pragma exception_init (planoInexis, -20516);
    planoInvalid exception;
      pragma exception_init (planoInvalid, -20517);
    periodoInvalido exception;
      pragma exception_init (periodoInvalido, -20521);
    tarifarioInv exception;
      pragma exception_init (tarifarioInv, -20503);
    
    verificacao number;
    estado number;
    dados boolean := false;
    newNumero number(9);
    newIDContrato number;
    idCli number;
    msgBoasVindas varchar2(160);
    nomeCli varchar2(150);
    newIdChamada number;
    idtarif number;
    idpp number;
BEGIN

    select count(id_cliente), c.nome, c.id_cliente into verificacao, nomeCli, idCli
    from cliente c
    where c.nif = nif1 and upper(c.nome) = upper(nome1)
    group by c.nome, c.id_cliente; 
    
    if verificacao = 0 then
      raise nifCliente;
    end if;
    
    
    for r in c1 loop
      dados := true;
      if r.esta = 0 then
        raise planoInvalid;
      end if;
      idpp := r.idplano;
    end loop;
    
    if dados = false then
      raise planoInexis;
    end if;
    
    dados := false;
    for k in c2 loop
      dados := true;
      idtarif := k.idtar;
    end loop;
    
    if dados = false then
      raise tarifarioInv;
    end if;
    
    if periodo_meses <= 0 then
      raise periodoInvalido;
    end if;
    
    select max(numero) into newNumero
    from num_telefone;
    newNumero := newNumero + 1;
    
    select max(id_contrato) into newIDContrato
    from contrato;
    newIDContrato := newIDContrato + 1;
    
    select max(id_chamada) into newIdChamada
    from chamada;
    newIdChamada := newIdChamada + 1;
    
    dbms_output.put_line('Id contrato: ' || newIDContrato);
    dbms_output.put_line('ID Tarifario: ' || idtarif);
    dbms_output.put_line('Novo numero: ' || newNumero);
    dbms_output.put_line('Id cliente: ' || idCli);
    dbms_output.put_line('Id plano: ' || idpp);
    dbms_output.put_line('Periodo: ' || periodo_meses);
    insert into num_telefone values(newNumero,0,0,0);
    insert into contrato values(newIDContrato,idtarif ,newNumero,idCli,periodo_meses,sysdate,1);
    insert into associado values(newIDContrato, idpp);
    
    msgBoasVindas := 'Bem vindo '|| nomeCli;
    dbms_output.put_line('Mensagem: ' ||msgBoasVindas);
    
    insert into chamada values(newIdChamada,393549708,newNumero, 'SMS');
    insert into sms values(newIdChamada, sysdate, sysdate, msgBoasVindas);
    EXCEPTION
      
      when nifCliente then
        dbms_output.put_line('Erro: Nif inv�lido.');
      when planoInexis then
        dbms_output.put_line('Erro: Plano inexistente.');
      when planoInvalid then
        dbms_output.put_line('Erro: Plano inv�lido.');
      when periodoInvalido then
        dbms_output.put_line('Erro: Periodo inv�lido.');
      when tarifarioInv then
        dbms_output.put_line('Erro: Tarif�rio inexistente.');
  
END;

/
--------------------------------------------------------
--  DDL for Procedure N_PROC_2021136600
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SQL_Project"."N_PROC_2021136600" (
  idGrupo number,
  numTele varchar2
) is

--exce��es
  NumInexistente exception;
    pragma exception_init (NumInexistente, -20501);
  NumInvalido exception;
    pragma exception_init (NumInvalido, -20502);
  NumInativo exception;
    pragma exception_init (NumInativo, -20511);
  TarInvalido exception;
    pragma exception_init (TarInvalido, -20505);
  NumIndefinido exception;
    pragma exception_init (NumIndefinido, -20515);

  cursor c1 is
    select
      count(ad.id_grupo) as adIdGroup,
      gr.n_membros as grMembros
    from
      num_telefone nt
      left join adere ad on nt.numero = ad.numero
      right join grupo gr on ad.id_grupo = gr.id_grupo
    where
      gr.id_grupo = idGrupo
      and gr.estado = 1
    group by
      gr.n_membros;

  helper1 varchar2(150);
  helper2 number;
  dados boolean := false;
  
begin
  helper1 := D_TIPO_DE_CHAMADA_VOZ(numTele);
  
  select count(id_grupo) into helper2
  from grupo
  where id_grupo = idGrupo;

  if(helper2 <= 0) then
    raise_application_error(-20580, 'Nao existe um grupo com id' + idGrupo);
  end if;
  
  helper2 := 0;
  
  select count(id_grupo) into helper2
  from adere
  where id_grupo = idGrupo
  and numero = numTele;

  if(helper2 > 0) then
    raise_application_error(-20583, 'Numero ja pertece a esse grupo');
  end if;
  
  for i in c1 loop
    dados := true;
  
    if (i.adIdGroup < i.grMembros) then
      insert into adere values(idGrupo, numTele);
    else
      raise_application_error(-20582, 'Grupo cheio');
    end if;
    
  end loop;

  if(dados = false) then
    raise_application_error(-20581, 'Grupo esta com estado invalido');
  end if;
end;

/
--------------------------------------------------------
--  DDL for Procedure N_PROC_2021139149
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SQL_Project"."N_PROC_2021139149" (numer number, valorCarregamento number)
is
  cursor c1 is
      select count(nt.numero) as counter
      from num_telefone nt
      where nt.numero = numer;
      
  cursor c2 is
          select pps.id_plano as idpps
          from plano_pospago_simples pps
            join associado ass on pps.id_plano = ass.id_plano
            join contrato ct on ass.id_contrato = ct.id_contrato
            join num_telefone nt on ct.numero = nt.numero
          where 
            nt.numero = numer;
            
  cursor c3 is
          select id_plano as idpre
          from plano_prepago;
  
  dados boolean := false;
  planopre boolean := false;
  newIdCarr number;
  idplano number;
begin
    for r in c1 loop
      dados := true;
    end loop;
    
    if dados = false then
      raise_application_error(-20501, 'Numero de telefone ' ||numer|| ' inexistente.');
    end if;
    
    for k in c2 loop
      for j in c3 loop
        if k.idpps = j.idpre then
          planopre := true;
          idplano := k.idpps;
        end if;
      end loop;
    end loop;
    
    if planopre = false then
      raise_application_error(-20522, 'Numero de telefone ' ||numer|| ' n�o possui plano pre pago.');
    end if;
    
    select max(id_carregamento) into newIdCarr
    from carregamento;
    
    newIdCarr := newIdCarr + 1;
    insert into carregamento values(newIdCarr,idplano,numer,valorCarregamento,sysdate);
end;

/
--------------------------------------------------------
--  DDL for Procedure N_PROC_2021142527
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "SQL_Project"."N_PROC_2021142527" (
  p_id_contrato contrato.id_contrato%TYPE,
  p_motivo cancelamento.motivo%TYPE,
  p_valor_multa cancelamento.valor_multa%TYPE)
IS
  num_contratos NUMBER;
BEGIN
  
  select count(*) into num_contratos
  from contrato ct
  where ct.id_contrato = p_id_contrato;
  

  if num_contratos = 0 then
      RAISE_APPLICATION_ERROR(-20509,'Contrato inexistente.');
  end if;

  INSERT INTO cancelamento(id_cancelamento, id_contrato, data_cancel, motivo, valor_multa)
  VALUES(cancelamento_seq.NEXTVAL, p_id_contrato, SYSDATE, p_motivo, p_valor_multa);

END;

/
