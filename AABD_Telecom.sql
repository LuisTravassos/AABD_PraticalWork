/*==============================================================*/
/* DBMS name:      ORACLE Version 11g                           */
/* Created on:     31/03/2023 18:48:15                          */
/*==============================================================*/


drop table ADERE cascade constraints;

drop table ANEXADO cascade constraints;

drop table APLICAVEL cascade constraints;

drop table ASSOCIADO cascade constraints;

drop table CAMPANHA cascade constraints;

drop table CANCELAMENTO cascade constraints;

drop table CARREGAMENTO cascade constraints;

drop table CHAMADA cascade constraints;

drop table CHAMADA_VOZ cascade constraints;

drop table CLIENTE cascade constraints;

drop table CONTRATO cascade constraints;

drop table DESCONTAVEL cascade constraints;

drop table EVENTOS cascade constraints;

drop table GRUPO cascade constraints;

drop table NUM_TELEFONE cascade constraints;

drop table OUTRAS_CHAMADAS cascade constraints;

drop table PACOTES cascade constraints;

drop table PERIODO_FATURACAO cascade constraints;

drop table PLANO cascade constraints;

drop table PLANO_POSPAGO_PLAFOND cascade constraints;

drop table PLANO_POSPAGO_SIMPLES cascade constraints;

drop table PLANO_PREPAGO cascade constraints;

drop table SMS cascade constraints;

drop table TARIFARIO cascade constraints;

/*==============================================================*/
/* Table: ADERE                                                 */
/*==============================================================*/
create table ADERE 
(
   ID_GRUPO             NUMBER,
   NUMERO               VARCHAR2(25)
);

/*==============================================================*/
/* Table: ANEXADO                                               */
/*==============================================================*/
create table ANEXADO 
(
   ID_FATURACAO         NUMBER               not null,
   ID_PACOTE            NUMBER               not null,
   constraint PK_ANEXADO primary key (ID_FATURACAO, ID_PACOTE)
);

/*==============================================================*/
/* Table: APLICAVEL                                             */
/*==============================================================*/
create table APLICAVEL 
(
   ID_PLANO             NUMBER               not null,
   ID_TARIFARIO         NUMBER               not null,
   constraint PK_APLICAVEL primary key (ID_PLANO, ID_TARIFARIO)
);

/*==============================================================*/
/* Table: ASSOCIADO                                             */
/*==============================================================*/
create table ASSOCIADO 
(
   ID_CONTRATO          NUMBER               not null,
   ID_PLANO             NUMBER               not null,
   constraint PK_ASSOCIADO primary key (ID_CONTRATO, ID_PLANO)
);

/*==============================================================*/
/* Table: CAMPANHA                                              */
/*==============================================================*/
create table CAMPANHA 
(
   ID_CAMPANHA          NUMBER               not null,
   DATA_INICIO          DATE,
   DATA_FIM             DATE,
   NOME                 VARCHAR2(50),
   DESIGNACAO           VARCHAR2(150),
   N_MAX_AMIGOS         NUMBER,
   DESCONTO_VOZ         NUMBER,
   DESCONTO_SMS         NUMBER,
   constraint PK_CAMPANHA primary key (ID_CAMPANHA)
);

/*==============================================================*/
/* Table: CANCELAMENTO                                          */
/*==============================================================*/
create table CANCELAMENTO 
(
   ID_CANCELAMENTO      NUMBER               not null,
   ID_CONTRATO          NUMBER               not null,
   DATA_CANCEL          DATE,
   MOTIVO               VARCHAR2(250),
   VALOR_MULTA          INTEGER,
   constraint PK_CANCELAMENTO primary key (ID_CANCELAMENTO)
);

/*==============================================================*/
/* Table: CARREGAMENTO                                          */
/*==============================================================*/
create table CARREGAMENTO 
(
   ID_CARREGAMENTO      NUMBER               not null,
   ID_PLANO             NUMBER               not null,
   ID_PRE               NUMBER               not null,
   NUMERO               VARCHAR2(25)         not null,
   VALOR                NUMBER,
   DATA_CARREG          DATE,
   constraint PK_CARREGAMENTO primary key (ID_CARREGAMENTO)
);

/*==============================================================*/
/* Table: CHAMADA                                               */
/*==============================================================*/
create table CHAMADA 
(
   ID_VOZ3              NUMBER               not null,
   NUMERO               VARCHAR2(25)         not null,
   NUM_NUMERO           VARCHAR2(25)         not null,
   N_ORIGEM             NUMBER(9),
   N_DESTINO            NUMBER(9),
   constraint PK_CHAMADA primary key (ID_VOZ3)
);

/*==============================================================*/
/* Table: CHAMADA_VOZ                                           */
/*==============================================================*/
create table CHAMADA_VOZ 
(
   ID_VOZ3              NUMBER               not null,
   ID_VOZ               NUMBER               not null,
   NUMERO               VARCHAR2(25),
   NUM_NUMERO           VARCHAR2(25),
   N_ORIGEM             NUMBER(9),
   N_DESTINO            NUMBER(9),
   DATA_INICIO          DATE,
   DATA_FIM             DATE,
   constraint PK_CHAMADA_VOZ primary key (ID_VOZ3, ID_VOZ)
);

/*==============================================================*/
/* Table: CLIENTE                                               */
/*==============================================================*/
create table CLIENTE 
(
   ID_CLIENTE           NUMBER               not null,
   EMAIL                VARCHAR2(100),
   DATA_NASCIMENTO      DATE,
   NIF                  NUMBER,
   MORADA               VARCHAR2(100),
   NOME                 VARCHAR2(50),
   SEXO                 VARCHAR2(1),
   NACIONALIDADE        VARCHAR2(20),
   constraint PK_CLIENTE primary key (ID_CLIENTE)
);

/*==============================================================*/
/* Table: CONTRATO                                              */
/*==============================================================*/
create table CONTRATO 
(
   ID_CONTRATO          NUMBER               not null,
   ID_TARIFARIO         NUMBER               not null,
   NUMERO               VARCHAR2(25)         not null,
   ID_CLIENTE           NUMBER               not null,
   PERIODO_FIDELIZACAO  VARCHAR2(50),
   DATA_INICIO          DATE,
   DURACAO              VARCHAR2(50),
   VALIDO               SMALLINT,
   constraint PK_CONTRATO primary key (ID_CONTRATO)
);

/*==============================================================*/
/* Table: DESCONTAVEL                                           */
/*==============================================================*/
create table DESCONTAVEL 
(
   ID_FATURACAO         NUMBER               not null,
   ID_CAMPANHA          NUMBER               not null,
   constraint PK_DESCONTAVEL primary key (ID_FATURACAO, ID_CAMPANHA)
);

/*==============================================================*/
/* Table: EVENTOS                                               */
/*==============================================================*/
create table EVENTOS 
(
   ID_EVENTO            NUMBER               not null,
   ID_VOZ3              NUMBER               not null,
   DATA_INI             DATE,
   DATA_FIM             DATE,
   ESTADO               VARCHAR2(50),
   constraint PK_EVENTOS primary key (ID_EVENTO)
);

/*==============================================================*/
/* Table: GRUPO                                                 */
/*==============================================================*/
create table GRUPO 
(
   ID_GRUPO             NUMBER               not null,
   ID_CAMPANHA          NUMBER               not null,
   DATA_INI             DATE,
   DATA_FIM             DATE,
   ESTADO               VARCHAR2(50),
   N_MEMBROS            NUMBER,
   constraint PK_GRUPO primary key (ID_GRUPO)
);

/*==============================================================*/
/* Table: NUM_TELEFONE                                          */
/*==============================================================*/
create table NUM_TELEFONE 
(
   NUMERO               VARCHAR2(25)         not null,
   SALDO                NUMBER,
   REDE                 VARCHAR2(100),
   constraint PK_NUM_TELEFONE primary key (NUMERO)
);

/*==============================================================*/
/* Table: OUTRAS_CHAMADAS                                       */
/*==============================================================*/
create table OUTRAS_CHAMADAS 
(
   ID_VOZ3              NUMBER               not null,
   ID_VOZ2              NUMBER               not null,
   NUMERO               VARCHAR2(25),
   NUM_NUMERO           VARCHAR2(25),
   N_ORIGEM             NUMBER(9),
   N_DESTINO            NUMBER(9),
   DATA_INICIO          DATE,
   DATA_FIM             DATE,
   constraint PK_OUTRAS_CHAMADAS primary key (ID_VOZ3, ID_VOZ2)
);

/*==============================================================*/
/* Table: PACOTES                                               */
/*==============================================================*/
create table PACOTES 
(
   ID_PACOTE            NUMBER               not null,
   DESIGNACAO_PACOTE    VARCHAR2(150),
   DATA_LANCAMENTO      DATE,
   TIPO                 VARCHAR2(50),
   REDE                 VARCHAR2(100),
   ESTADO               VARCHAR2(50),
   PRECO_PACOTE         FLOAT,
   QUANT_PACOTE         NUMBER,
   UNIDADE_PACOTE       VARCHAR2(50),
   PERIODO_PACOTE       NUMBER,
   constraint PK_PACOTES primary key (ID_PACOTE)
);

/*==============================================================*/
/* Table: PERIODO_FATURACAO                                     */
/*==============================================================*/
create table PERIODO_FATURACAO 
(
   ID_FATURACAO         NUMBER               not null,
   ID_CONTRATO          NUMBER               not null,
   DATA_INI             DATE,
   DATA_FIM             DATE,
   VALOR                NUMBER,
   DATA                 DATE,
   constraint PK_PERIODO_FATURACAO primary key (ID_FATURACAO)
);

/*==============================================================*/
/* Table: PLANO                                                 */
/*==============================================================*/
create table PLANO 
(
   ID_PLANO             NUMBER               not null,
   DATA_LANCAMENTO      DATE,
   NOME                 VARCHAR2(50),
   DESIGNACAO           VARCHAR2(150),
   ESTADO               VARCHAR2(50),
   VALOR_SERVICO        FLOAT,
   constraint PK_PLANO primary key (ID_PLANO)
);

/*==============================================================*/
/* Table: PLANO_POSPAGO_PLAFOND                                 */
/*==============================================================*/
create table PLANO_POSPAGO_PLAFOND 
(
   ID_PLANO             NUMBER               not null,
   ID_POS_PLANFOND      NUMBER               not null,
   DATA_LANCAMENTO      DATE,
   NOME                 VARCHAR2(50),
   DESIGNACAO           VARCHAR2(150),
   ESTADO               VARCHAR2(50),
   VALOR_SERVICO        FLOAT,
   MINUTOS              NUMBER,
   SMS                  NUMBER,
   constraint PK_PLANO_POSPAGO_PLAFOND primary key (ID_PLANO, ID_POS_PLANFOND)
);

/*==============================================================*/
/* Table: PLANO_POSPAGO_SIMPLES                                 */
/*==============================================================*/
create table PLANO_POSPAGO_SIMPLES 
(
   ID_PLANO             NUMBER               not null,
   ID_POS_SIMPLES       NUMBER               not null,
   DATA_LANCAMENTO      DATE,
   NOME                 VARCHAR2(50),
   DESIGNACAO           VARCHAR2(150),
   ESTADO               VARCHAR2(50),
   VALOR_SERVICO        FLOAT,
   constraint PK_PLANO_POSPAGO_SIMPLES primary key (ID_PLANO, ID_POS_SIMPLES)
);

/*==============================================================*/
/* Table: PLANO_PREPAGO                                         */
/*==============================================================*/
create table PLANO_PREPAGO 
(
   ID_PLANO             NUMBER               not null,
   ID_PRE               NUMBER               not null,
   DATA_LANCAMENTO      DATE,
   NOME                 VARCHAR2(50),
   DESIGNACAO           VARCHAR2(150),
   ESTADO               VARCHAR2(50),
   VALOR_SERVICO        FLOAT,
   NUMERO_DIAS          NUMBER,
   MINUTOS              NUMBER,
   SMS                  NUMBER,
   constraint PK_PLANO_PREPAGO primary key (ID_PLANO, ID_PRE)
);

/*==============================================================*/
/* Table: SMS                                                   */
/*==============================================================*/
create table SMS 
(
   ID_VOZ3              NUMBER               not null,
   ID_SMS               NUMBER               not null,
   NUMERO               VARCHAR2(25),
   NUM_NUMERO           VARCHAR2(25),
   N_ORIGEM             NUMBER(9),
   N_DESTINO            NUMBER(9),
   DATA_ENVIO           DATE,
   DATA_ENTREGA         DATE,
   constraint PK_SMS primary key (ID_VOZ3, ID_SMS)
);

/*==============================================================*/
/* Table: TARIFARIO                                             */
/*==============================================================*/
create table TARIFARIO 
(
   ID_TARIFARIO         NUMBER               not null,
   NOME                 VARCHAR2(50),
   DESIGNACAO           VARCHAR2(150),
   TIPO                 VARCHAR2(50),
   REDE                 VARCHAR2(100),
   ESTADO               VARCHAR2(50),
   UNIDADE              VARCHAR2(50),
   VALORUNIDADE         FLOAT,
   DATA_LANCAMENTOT     DATE,
   constraint PK_TARIFARIO primary key (ID_TARIFARIO)
);

alter table ADERE
   add constraint FK_ADERE_REFERENCE_GRUPO foreign key (ID_GRUPO)
      references GRUPO (ID_GRUPO);

alter table ADERE
   add constraint FK_ADERE_REFERENCE_NUM_TELE foreign key (NUMERO)
      references NUM_TELEFONE (NUMERO);

alter table ANEXADO
   add constraint FK_ANEXADO_ANEXADO_PERIODO_ foreign key (ID_FATURACAO)
      references PERIODO_FATURACAO (ID_FATURACAO);

alter table ANEXADO
   add constraint FK_ANEXADO_ANEXADO2_PACOTES foreign key (ID_PACOTE)
      references PACOTES (ID_PACOTE);

alter table APLICAVEL
   add constraint FK_APLICAVE_APLICAVEL_PLANO foreign key (ID_PLANO)
      references PLANO (ID_PLANO);

alter table APLICAVEL
   add constraint FK_APLICAVE_APLICAVEL_TARIFARI foreign key (ID_TARIFARIO)
      references TARIFARIO (ID_TARIFARIO);

alter table ASSOCIADO
   add constraint FK_ASSOCIAD_ASSOCIADO_CONTRATO foreign key (ID_CONTRATO)
      references CONTRATO (ID_CONTRATO);

alter table ASSOCIADO
   add constraint FK_ASSOCIAD_ASSOCIADO_PLANO foreign key (ID_PLANO)
      references PLANO (ID_PLANO);

alter table CANCELAMENTO
   add constraint FK_CANCELAM_HOUVE_CONTRATO foreign key (ID_CONTRATO)
      references CONTRATO (ID_CONTRATO);

alter table CARREGAMENTO
   add constraint FK_CARREGAM_APLICADO_PLANO_PR foreign key (ID_PLANO, ID_PRE)
      references PLANO_PREPAGO (ID_PLANO, ID_PRE);

alter table CARREGAMENTO
   add constraint FK_CARREGAM_PAGA_NUM_TELE foreign key (NUMERO)
      references NUM_TELEFONE (NUMERO);

alter table CHAMADA
   add constraint FK_CHAMADA_ENVIA_NUM_TELE foreign key (NUM_NUMERO)
      references NUM_TELEFONE (NUMERO);

alter table CHAMADA
   add constraint FK_CHAMADA_RECEBE_NUM_TELE foreign key (NUMERO)
      references NUM_TELEFONE (NUMERO);

alter table CHAMADA_VOZ
   add constraint FK_CHAMADA__INHERITAN_CHAMADA foreign key (ID_VOZ3)
      references CHAMADA (ID_VOZ3);

alter table CONTRATO
   add constraint FK_CONTRATO_REALIZA_CLIENTE foreign key (ID_CLIENTE)
      references CLIENTE (ID_CLIENTE);

alter table CONTRATO
   add constraint FK_CONTRATO_REFERENTE_NUM_TELE foreign key (NUMERO)
      references NUM_TELEFONE (NUMERO);

alter table CONTRATO
   add constraint FK_CONTRATO_SELECIONA_TARIFARI foreign key (ID_TARIFARIO)
      references TARIFARIO (ID_TARIFARIO);

alter table DESCONTAVEL
   add constraint FK_DESCONTA_DESCONTAV_PERIODO_ foreign key (ID_FATURACAO)
      references PERIODO_FATURACAO (ID_FATURACAO);

alter table DESCONTAVEL
   add constraint FK_DESCONTA_DESCONTAV_CAMPANHA foreign key (ID_CAMPANHA)
      references CAMPANHA (ID_CAMPANHA);

alter table EVENTOS
   add constraint FK_EVENTOS_TEM_CHAMADA foreign key (ID_VOZ3)
      references CHAMADA (ID_VOZ3);

alter table GRUPO
   add constraint FK_GRUPO_PERTENCE_CAMPANHA foreign key (ID_CAMPANHA)
      references CAMPANHA (ID_CAMPANHA);

alter table OUTRAS_CHAMADAS
   add constraint FK_OUTRAS_C_INHERITAN_CHAMADA foreign key (ID_VOZ3)
      references CHAMADA (ID_VOZ3);

alter table PERIODO_FATURACAO
   add constraint FK_PERIODO__POSSUI_CONTRATO foreign key (ID_CONTRATO)
      references CONTRATO (ID_CONTRATO);

alter table PLANO_POSPAGO_PLAFOND
   add constraint FK_PLANO_PO_HERANCA2PL_PLANO foreign key (ID_PLANO)
      references PLANO (ID_PLANO);

alter table PLANO_POSPAGO_SIMPLES
   add constraint FK_PLANO_PO_HERANCA1PL_PLANO foreign key (ID_PLANO)
      references PLANO (ID_PLANO);

alter table PLANO_PREPAGO
   add constraint FK_PLANO_PR_HERANCAPL_PLANO foreign key (ID_PLANO)
      references PLANO (ID_PLANO);

alter table SMS
   add constraint FK_SMS_INHERITAN_CHAMADA foreign key (ID_VOZ3)
      references CHAMADA (ID_VOZ3);

LTER TABLE NUM_TELEFONE 
	ADD CONSTRAINT SO_NUMEROS CHECK (regexp_like(numero, '^[0-9]$'));

