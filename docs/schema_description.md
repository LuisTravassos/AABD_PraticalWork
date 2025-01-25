# Database Schema Description

This schema represents a telecommunications service management system, detailing the relationships and attributes of various entities. Below is a description of each table and its respective fields:

---

## **CLIENT**
- **ID_CLIENTE** (NUMBER, Primary Key): Unique identifier for each client.
- **EMAIL** (VARCHAR2(100 BYTE)): Client's email address.
- **DATA_NASC** (DATE): Client's date of birth.
- **NOME** (VARCHAR2(250 BYTE)): Client's name.
- **MORADA** (VARCHAR2(250 BYTE)): Client's address.
- **NIF** (NUMBER): Tax Identification Number.
- **SEXO** (VARCHAR2(50 BYTE)): Client's gender.
- **NACIONALIDADE** (VARCHAR2(250 BYTE)): Client's nationality.

---

## **CONTRACT**
- **ID_CONTRATO** (NUMBER, Primary Key): Unique identifier for each contract.
- **ID_TARIFARIO** (NUMBER, Foreign Key): References the tariff applied to the contract.
- **ID_CLIENTE** (NUMBER, Foreign Key): References the client associated with the contract.
- **NUMERO** (VARCHAR2(25 BYTE)): Client's phone number.
- **PERIODO_FIDELIZACAO** (VARCHAR2(250 BYTE)): Loyalty period of the contract.
- **DATA_INICIO** (DATE): Start date of the contract.
- **VALIDO** (NUMBER): Indicates the validity of the contract.

---

## **CANCELLATION**
- **ID_CANCELAMENTO** (NUMBER, Primary Key): Unique identifier for each cancellation.
- **ID_CONTRATO** (NUMBER, Foreign Key): References the contract being canceled.
- **DATA_CANCEL** (DATE): Date of cancellation.
- **MOTIVO** (VARCHAR2(250 BYTE)): Reason for cancellation.
- **VALOR_MULTA** (NUMBER): Penalty amount applied for cancellation.

---

## **NUM_TELEFONE (Phone Number)**
- **NUMERO** (VARCHAR2(25 BYTE), Primary Key): Phone number.
- **SALDO** (NUMBER): Balance of the account.
- **MIN_GASTOS** (VARCHAR2(20 BYTE)): Minimum expenses per month.
- **SMS_GASTOS** (VARCHAR2(20 BYTE)): SMS expenses per month.

---

## **CALL**
- **ID_CHAMADA** (NUMBER, Primary Key): Unique identifier for each call.
- **NUM_ORIGEM** (VARCHAR2(25 BYTE)): Originating phone number.
- **NUM_DESTINO** (VARCHAR2(25 BYTE)): Destination phone number.
- **TIPO** (VARCHAR2(25 BYTE)): Type of call.

---

## **VOICE CALL**
- **ID_CHAMADA** (NUMBER, Foreign Key): References the call being detailed.
- **DATA_INICIO** (TIMESTAMP): Start time of the voice call.
- **DATA_FIM** (TIMESTAMP): End time of the voice call.

---

## **SMS**
- **ID_CHAMADA** (NUMBER, Foreign Key): References the call associated with the SMS.
- **DATA_ENVIO** (TIMESTAMP): SMS sending time.
- **DATA_ENTREGA** (TIMESTAMP): SMS delivery time.
- **MENSAGEM** (VARCHAR2(200 BYTE)): Content of the SMS.

---

## **OTHER CALLS**
- **ID_CHAMADA** (NUMBER, Foreign Key): References the call being detailed.
- **DATA_INICIO** (TIMESTAMP): Start time of the call.
- **DATA_FIM** (TIMESTAMP): End time of the call.

---

## **EVENTS**
- **ID_EVENTO** (NUMBER, Primary Key): Unique identifier for each event.
- **DATA_INICIO** (DATE): Event start date.
- **DATA_FIM** (DATE): Event end date.
- **ESTADO** (VARCHAR2(250 BYTE)): Event status.

---

## **GROUP**
- **ID_GRUPO** (NUMBER, Primary Key): Unique identifier for each group.
- **NOME** (VARCHAR2(250 BYTE)): Group name.
- **DATA_INICIO** (DATE): Group creation date.
- **DATA_FIM** (DATE): Group expiration date.
- **N_MEMBROS** (NUMBER): Number of members in the group.

---

## **ASSOCIATED**
- **ID_CONTRATO** (NUMBER, Foreign Key): References the contract being associated.
- **ID_PLANO** (NUMBER, Foreign Key): References the associated plan.

---

## **BILLING PERIOD**
- **ID_FATURACAO** (NUMBER, Primary Key): Unique identifier for each billing period.
- **ID_CONTRATO** (NUMBER, Foreign Key): References the contract being billed.
- **DATA_INI** (DATE): Billing period start date.
- **DATA_FIM** (DATE): Billing period end date.

---

## **ATTACHED**
- **ID_FATURACAO** (NUMBER, Foreign Key): References the billing period.
- **ID_PACOTE** (NUMBER, Foreign Key): References the attached package.

---

## **PACKAGES**
- **ID_PACOTE** (NUMBER, Primary Key): Unique identifier for each package.
- **DESIGNACAO_PACOTE** (VARCHAR2(250 BYTE)): Package name.
- **DATA_LANCAMENTO** (DATE): Release date of the package.
- **TIPO** (VARCHAR2(250 BYTE)): Package type.
- **ESTADO** (VARCHAR2(250 BYTE)): Package status.
- **PRECO_PACOTE** (FLOAT(126)): Package price.
- **QUANT_PACOTE** (NUMBER): Quantity included in the package.
- **UNIDADE_PACOTE** (VARCHAR2(250 BYTE)): Unit of the package.
- **PERIODO_PACOTE** (VARCHAR2(250 BYTE)): Package period.

---

## **TARIFF**
- **ID_TARIFARIO** (NUMBER, Primary Key): Unique identifier for each tariff.
- **DESIGNACAO** (VARCHAR2(250 BYTE)): Tariff name.
- **TIPO** (VARCHAR2(250 BYTE)): Tariff type.
- **REDE** (VARCHAR2(100 BYTE)): Network.
- **ESTADO** (VARCHAR2(50 BYTE)): Tariff status.
- **UNIDADE** (VARCHAR2(250 BYTE)): Unit of measurement.
- **VALORUNIDADE** (FLOAT(126)): Value per unit.
- **DATA_LANCAMENTO** (DATE): Tariff release date.

---

## **RECHARGE**
- **ID_CARREGAMENTO** (NUMBER, Primary Key): Unique identifier for each recharge.
- **ID_PLANO** (NUMBER, Foreign Key): References the plan being recharged.
- **VALOR** (NUMBER): Recharge amount.
- **DATA_CARREG** (DATE): Recharge date.

---

## **SIMPLE POSTPAID PLAN**
- **ID_PLANO** (NUMBER, Primary Key): Unique identifier for the postpaid plan.
- **DATA_LANCAMENTO** (DATE): Plan release date.
- **NOME** (VARCHAR2(50 BYTE)): Plan name.
- **DESIGNACAO** (VARCHAR2(150 BYTE)): Plan description.
- **ESTADO** (VARCHAR2(50 BYTE)): Plan status.
- **VALOR_SERVICO** (FLOAT(126)): Service value.

---

## **POSTPAID PLAN WITH PLAFOND**
- **ID_PLANO** (NUMBER, Primary Key): Unique identifier for the postpaid plan with plafond.
- **MINUTOS** (NUMBER): Number of minutes included.
- **SMS** (NUMBER): Number of SMS included.

---

## **PREPAID PLAN**
- **ID_PLANO** (NUMBER, Primary Key): Unique identifier for the prepaid plan.
- **NUMERO_DIAS** (NUMBER): Validity period in days.
- **MINUTOS** (NUMBER): Number of minutes included.
- **SMS** (NUMBER): Number of SMS included.

---

## **CAMPAIGN**
- **ID_CAMPANHA** (NUMBER, Primary Key): Unique identifier for each campaign.
- **DATA_INICIO** (DATE): Campaign start date.
- **DATA_FIM** (DATE): Campaign end date.
- **NOME** (VARCHAR2(250 BYTE)): Campaign name.
- **DESIGNACAO** (VARCHAR2(150 BYTE)): Campaign description.
- **N_MAX_AMIGOS** (NUMBER): Maximum number of friends allowed.
- **DESCONTO_SMS** (NUMBER): SMS discount percentage.
- **DESCONTO_VOZ** (NUMBER): Voice discount percentage.

---

## **DISCOUNTABLE**
- **ID_FATURACAO** (NUMBER, Foreign Key): References the billing period.
- **ID_CAMPANHA** (NUMBER, Foreign Key): References the associated campaign.

---

## **INVOICE**
- **VALORCHAMADAS** (FLOAT(126)): Total call charges.
- **VALORCARREGAMENTOS** (FLOAT(126)): Total recharge value.
- **VALORPACOTES** (FLOAT(126)): Total package charges.
- **VALORTOTAL** (FLOAT(126)): Total invoice value.
- **NOME** (VARCHAR2(100 BYTE)): Client's name.
- **DATA_INI** (DATE): Invoice period start date.
- **DATA_FIM** (DATE): Invoice period end date.