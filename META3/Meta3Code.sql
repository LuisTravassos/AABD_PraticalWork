/*Crie a função b_custo_da_chamada que recebe como argumento o identificador de uma chamada, e calcula
o custo dessa chamada tomando em consideração o plano contratado e do tarifário aplicável ao número de
telefone que efetuou a chamada. Algumas exceções que poderão ser lançadas: -20514
FUNCTION b_custo_da_chamada (idChamada NUMBER) return NUMBER*/

SELECT b_custo_da_chamada(400) FROM dual;

create or replace function b_custo_da_chamada(
  idChamada number
) return float is

/*Cursor para receber tudo associado à chamada,
so deve retornar uma linha de resultados*/
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
      
    where --verificar se o numero está a 100%
      ch.id_chamada = idChamada
      and ta.ESTADO = 1
      and pps.ESTADO = 1;
      
--cursor responsavel por verificar carregamentos
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

--variaveis
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
--verificar se chamada existe
  select count(id_chamada) 
  into helper
  from chamada
  where ID_CHAMADA = idChamada;
  
  if (helper <= 0) then
    raise_application_error(-20514, 'Inválido Identificador de chamada: '||idChamada);
  end if;
 
 --inicio loop c1
  for i in c1 loop
    dados := true;

--verifica se a chamada é do tipo do tarifario, se nao for acusa erro
--calcula o valor a pagar pelo tarifario, valor*minutos
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

/*baseado no tipo de plano retorna valores 
diferentes baseados no enunciado*/
    if(INSTR(i.ppsNome, 'PPS ')>0) then
      total := tarifarioValue; --valor do tarifario*
      
    elsif(INSTR(i.ppsNome, 'PPP ')>0) then
      select minutos, sms 
      into planosMin, planosSms
      from PLANO_POSPAGO_PLAFOND
      where id_plano = i.ppsId;
      
--se o cliente tiver ultrapassado os seus minutos/sms paga o valor do tarifario
      if(i.ntMin > planosMin or i.ntSms > planosSms) then
        total := tarifarioValue; --valor do tarifario*
      else
        total:= 0;
      end if;
      
    elsif(INSTR(i.ppsNome, 'PP ')>0) then
      select minutos, sms, numero_dias
      into planosMin, planosSms, preTime
      from PLANO_PREPAGO
      where id_plano = i.ppsId;
      
      for j in c2 loop
/*se o cliente tiver feito um carregamento superior ou igual ao valor do plano
num periodo de tempo menor que o do plano e nao tiver ultrapassado o valor de 
chamadas/sms no meio tempo paga nada, contrario paga o tarifario*/

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


------------------------------ ^^^^ FUNCTION b_custo_da_chamada ^^^^^ ---------------------

------------------------------ FUNCTION d_tipo_de_chamada_voz -----------------------------------------

/*Crie a função d_tipo_de_chamada_voz que recebe como argumento um número de 
telefone de destino, e que valida se é um número de uma gama válida e caso seja, 
retorna o tipo de destino. 
Algumas exceções que poderão ser lançadas: -20501 , -20502 , -20505 , -20511 , -20515
FUNCTION d_tipo_de_chamada_voz (num_telefone VARCHAR) return VARCHAR*/

SELECT d_tipo_de_chamada_voz('300000000') FROM dual;

create or replace function d_tipo_de_chamada_voz(
  num_telefone varchar2
) return varchar2 is
--variaveis
  helper number;
  
begin
--verifica se existe o numero
  select count(numero) into helper
  from num_telefone
  where NUMERO = num_telefone;
  
  if(helper <= 0) then
    raise_application_error(-20501, 'Número de telefone '||num_telefone||' inexistente.');
  end if;
  
--verifica se é so composto por numeros  
  if( not REGEXP_LIKE(num_telefone, '^[0-9]+$')) then
    raise_application_error(-20502, ' Invalido Número de telefone '||num_telefone);
  end if;
  
--verifica se existe um contrato ativo anexado ao numero  
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
  
--verifica se o tarifario do numero esta ativo  
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
    raise_application_error(-20505, 'Tarifário não ativo.');
  end if;

--retorna o tipo  
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

--nao reconheceu o tipo  
  raise_application_error(-20515, 'Gama de numeros indefinido.');
end;
/

----------------------------------- PROCEDURE g_estabelece_chamada ----------------------

/*Crie o procedimento g_estabelece_chamada, que recebe como argumento o número de origem e o número
de destino e após verificar se o número que origina a chamada pode realizar essa chamada, regista-a e
regista o evento de chamada iniciada. Algumas exceções que poderão ser lançadas: -20501 , -20502 , 
-20508 , -20511*/

DECLARE
  IdChamada NUMBER;
  IdEvento NUMBER;
BEGIN
  SELECT MAX(id_chamada) INTO IdChamada
  FROM chamada;
  
  IF IdChamada IS NULL THEN
    IdChamada := 1;
  END IF;
  
  SELECT MAX(id_evento) INTO IdEvento
  FROM eventos;
  
  IF IdEvento IS NULL THEN
    IdEvento := 1;
  END IF;
  
  EXECUTE IMMEDIATE 'CREATE SEQUENCE SeqIdChamada START WITH ' || IdChamada || ' INCREMENT BY 1';
  EXECUTE IMMEDIATE 'CREATE SEQUENCE SeqIdEvento START WITH ' || IdEvento || ' INCREMENT BY 1';
END;
/

drop sequence SeqIdChamada;
drop sequence SeqIdEvento;

exec g_estabelece_chamada('900000000', '900000001');

create or replace procedure g_estabelece_chamada(
  num_de_origem varchar2,
  num_de_destino varchar2
) is

/*Existe a declaraçao de duas sequencias que podem ser necessario
ser lançadas/relançadas*/

--inicia os erros, irá ser lançada a função D so para os erros
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
  
--cursor para retornar tipo do tarifario e garantir que estao tudo nos conformes
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

--variaveis      
  helper varchar2(150);
  dados boolean := false;
  
begin
--verificar erros
  helper := D_TIPO_DE_CHAMADA_VOZ(num_de_origem);
  helper := D_TIPO_DE_CHAMADA_VOZ(num_de_destino);
  
  for i in c1 loop
    dados := true;
    
    --insere dados no tabela chamada
    insert into chamada values(
      SeqIdChamada.nextval, 
      num_de_origem, 
      num_de_destino, 
      i.taTipo);
    
    --insere dados na tabela eventos  
    insert into eventos values(
      SeqIdEvento.nextval,
      SeqIdChamada.currval,
      sysdate, 
      null, 
      'Chamada Iniciada');
    
  end loop;
  
  --se nao houver dados no cursor
  if(dados = false) then
    raise_application_error(-20532, 'Tarifario nao aplicavel com Plano contrato');
  end if;
end;
/

---------------------------------------- trigger i_atualiza_saldo -----------------------------------

/*Crie o trigger i_atualiza_saldo que quanto é registado o término de uma chamada, e de acordo
com o plano contratado, o tarifário aplicável ao número que realizou a chamada, o tipo de chamada, o
tipo de destino e a duração atualize o saldo associado a esse número de telefone (ver 2.1 a 2.4).
TRIGGER atualiza_saldo*/

SELECT b_custo_da_chamada(400) FROM dual;

create or replace trigger i_atualiza_saldo
  before insert on eventos
  for each row
  
declare

--cursor para obter a chamada e os dados do numero associado ao evento
  cursor c1 is
    select
      ch.id_chamada as chID,
      nt.numero as ntNum,
      nt.saldo as ntSaldo
    from 
      chamada ch
      join num_telefone nt on ch.numero = nt.numero
    where
      ch.id_chamada = :new.id_chamada;
  
--variaveis  
  saldoMinus float;
  
--exceções  
  IDchamada exception;
  pragma exception_init(IDchamada, -20514);
  tarCompativel exception;
  pragma exception_init(tarCompativel, -20531);
  
begin

--so se o evento for de termino de chamada
  if (upper(:new.estado) = 'CHAMADA TERMINADA') then
  
    for i in c1 loop
    --chama função B
      saldoMinus := b_custo_da_chamada(i.chID);
      
      --se tiver saldo para pagar o custo da chamada paga
      if(i.ntSaldo >= saldoMinus) then
        update num_telefone
          set saldo = saldo - saldoMinus
          where numero = i.ntNum;
      end if;
    end loop; 
  end if;

end;
/


-----------------------------------------Procedimento N_PROC_2021136600 -----------------------------

/*Permite numeros aderirem a grupos na tabela GRUPO;*/

exec n_proc_2021136600(101, '962316851');

create or replace procedure n_proc_2021136600(
  idGrupo number,
  numTele varchar2
) is

--exceções
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

--cursor com o objetivo de investigar as specs do grupo
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

--variaveis  
  helper1 varchar2(150);
  helper2 number;
  dados boolean := false;
  
begin
--usar a funcao D para lanças as exceçoes
  helper1 := D_TIPO_DE_CHAMADA_VOZ(numTele);
  
  select count(id_grupo) into helper2
  from grupo
  where id_grupo = idGrupo;

--verificar se o grupo existe 
  if(helper2 <= 0) then
    raise_application_error(-20580, 'Nao existe um grupo com id' + idGrupo);
  end if;
  
  helper2 := 0;
  
  select count(id_grupo) into helper2
  from adere
  where id_grupo = idGrupo
  and numero = numTele;

--verificar se o numero ja pertence ao grupo  
  if(helper2 > 0) then
    raise_application_error(-20583, 'Numero ja pertece a esse grupo');
  end if;
  
  for i in c1 loop
    dados := true;

--se houver espaço para adicionar o numero adiciona-se    
    if (i.adIdGroup < i.grMembros) then
      insert into adere values(idGrupo, numTele);
    else
      raise_application_error(-20582, 'Grupo cheio');
    end if;
    
  end loop;

--o grupo esta desativado 
  if(dados = false) then
    raise_application_error(-20581, 'Grupo esta com estado invalido');
  end if;
end;
/


----------------------------------------- O_TRIG_2021136600_1 & _2 ---------------------------

/*Ao inserir uma entrada na tabela CHAMADA irá ver qual o tipo dela e registar esse 
ID na tabela respetiva. Por exemplo, CHAMADA, id - 123, TIPO - VOZ irá 
gerar em CHAMADA_VOZ, id - 123;
Irá fazer algo semelhante para as tabelas Planos também*/


create or replace trigger o_trig_2021136600_1
  after insert or update on chamada
  for each row
declare
  
  /*ATENCAO, como este trigger era muito simples fiz um segundo de natureza 
  semelhante chamado o_trig_2021136600_2*/
  
begin

--Verifica o tipo de chamada e adiciona na tabela respetiva a entrada
--o trigger é after para se puder ir buscar o id correto
  if (upper(:new.tipo) = 'VOZ') then
    insert into chamada_voz values (:new.id_chamada, sysdate - 0.1, sysdate + 1);
    
  elsif (upper(:new.tipo) = 'SMS') then
    insert into sms values (:new.id_chamada, sysdate - 0.1, sysdate + 1, 'Boas');
    
  elsif (upper(:new.tipo) = 'OUTRO') then
    insert into outras_chamadas values (:new.id_chamada, sysdate - 0.1, sysdate + 1);
    
  else
--nao insere nada caso o tipo seja errado 
    raise_application_error(-20572, 'Tipo da chamada desconhecido');
    
  end if;
end;


create or replace trigger o_trig_2021136600_2
  after insert or update on plano_pospago_simples
  for each row
declare
  
  /*ATENCAO, como este trigger era muito simples fiz um segundo de natureza 
  semelhante chamado o_trig_2021136600_1*/
  
begin
--Verifica o tipo de chamada e adiciona na tabela respetiva a entrada
--o trigger é after para se puder ir buscar o id correto
  if(INSTR(:new.nome, 'PPP ') > 0) then
    insert into plano_pospago_plafond(id_plano) values (:new.id_plano);
    
  elsif(INSTR(:new.nome, 'PP ') > 0) then
    insert into plano_prepago(id_plano) values (:new.id_plano);
    
  else
--nao insere nada caso o tipo seja errado   
    raise_application_error(-20571, 'Tipo da plano desconhecido');
    
  end if;
end;
/


------------------------------- FUNCTION m_func_2021136600 ------------------------------

/*Verifica se tarifario X é aplicavel a plano Y e se o user pretender 
associa os dois na tabela aplicavel;*/

SET SERVEROUTPUT ON;

DECLARE
  output VARCHAR2(50);
BEGIN
  output := m_func_2021136600(1, 14, 's');
  DBMS_OUTPUT.PUT_LINE(output);
END;
/

SELECT m_func_2021136600(1, 14, 'sim') FROM dual;


create or replace function m_func_2021136600(
  idPlano number,
  idTarifario number,
  associar varchar2
) return varchar2 is
  
--variaveis  
  result varchar2(50) := 'false';
  helper number;
  
begin

  select count(id_tarifario) into helper
  from tarifario
  where ID_TARIFARIO = idTarifario;

--verifica se existe tarifario  
  if (helper <= 0) then
    raise_application_error(-20503, 'Tarifário inexistente.');
  end if;
  
  select count(id_plano) into helper
  from PLANO_POSPAGO_SIMPLES
  where ID_PLANO = idPlano;

--verifica se existe plano 
  if (helper <= 0) then
    raise_application_error(-20516 ,'Plano inexistente.');
  end if;
  
  select count(id_plano) into helper
  from aplicavel
  where ID_PLANO = idPlano
  and ID_TARIFARIO = idTarifario;

--se escolher associar o plano e o tarifario e estes nao o forem associa
--depois retorna true
  if ((upper(associar) like 'S%') and helper <= 0) then
    insert into aplicavel(ID_PLANO, ID_TARIFARIO) values (idPlano, idTarifario);
    result := 'associados -> true';

--se estiverem associados retorna true    
  elsif (helper > 0) then
    result := 'true';
    
  end if;

--dps de testar as alternativas so resta retornar false 
  return result;
end;
/


--------------------------- Procedimento a_emite_fatura (extra) --------------------------------------

/*Crie o procedimento a_emite_fatura que recebe como argumento um número de telefone e o ano mês
do período de faturação (ano_mes no formato ‘yyyy-mm’) e se número estiver associado um plano pós-
pago deve emitir e registar os dados da fatura desse período, se esta ainda não existir. Além da data
da emissão, a fatura deve conter o montante a pagar considerando o plano contratado, tarifário
aplicável, ... , e as chamadas e SMS enviados no período. A fatura deve incluir/descriminar a duração
e o custo de cada chamada realizado no período e o custo de cada SMS enviado. Algumas exceções
que poderão ser lançadas: -20501 , -20502 , -20510 , -20511 , -20512 , -20513*/

exec a_emite_fatura('900000000', '2023-07');

create or replace PROCEDURE a_emite_fatura(
    nTelefone varchar2,
    anoMes varchar2 --formato "yyyy-mm"
) is

--cursor responsavel por verificar carregamentos
  cursor c1 is
    select 
      carr.valor as carrValor
      
    from num_telefone nt
      left join carregamento carr on nt.numero = carr.numero
      
    where nTelefone = nt.numero
      and carr.data_carreg between add_months(to_date(anoMes, 'YYYY-MM'), -1) and to_date(anoMes, 'YYYY-MM');  

--cursor para chamadas      
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

--variaveis
  dados boolean := false;
  helper number;
  custoChamadasTotal float := 0;
  custoCarregamentosTotal float := 0;
  custoPlano float := 0;
  custoTotal float := 0;
  
begin
  --verificar se numero existe
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
    
  --verifica se existe um contrato ativo anexado ao numero  
  if(helper <= 0) then
    raise_application_error(-20511, 'Numero '||nTelefone||' inativo');
  end if;
  
  --custo Total das chamadas usando a funcao B
  for i in c2 loop
    dados := true;
    custoChamadasTotal := custoChamadasTotal + b_custo_da_chamada(i.chId);
  end loop;
  
  --valor total dos carregamentos para a data selecionada
  for i in c1 loop
    custoCarregamentosTotal := custoCarregamentosTotal + i.carrValor;
  end loop;
  
  --valor do plano contratado
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
    
  --soma de valores  
  custoTotal := custoPlano + custoCarregamentosTotal + custoChamadasTotal;
  
  --periodo de tempo mal feito
  if not REGEXP_LIKE(anoMes, '^\d{4}-\d{2}$') then
    raise_application_error(-20512, 'Periodo yyyy-mm invalido');
  end if;
  
  --periodo de tempo superior ao presente
  if(to_date(anoMes, 'yyyy-mm') > sysdate) then
    raise_application_error(-20513, 'Periodo ainda nao terminado');
  end if;
  
  select count(numero) into helper
  from fatura
  where numero = nTelefone
    and data_ini = add_months(to_date(anoMes, 'YYYY-MM'), -1)
    and data_fim = to_date(anoMes, 'YYYY-MM')
    and VALORTOTAL = custoTotal;
  
  --verifica se dados de fatura ja existem  
  if(helper > 0) then
    raise_application_error(-20510, 'Fatura já foi emitida');
  else
    --insersao no tabela fatura
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