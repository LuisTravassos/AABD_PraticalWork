# Physical Parameter Calculations of Selected Tables

## Selected Tables
The five tables in our system expected to occupy the most space are:
- **CONTRACT**
- **CLIENT**
- **PHONE_NUMBER**
- **CALL**
- **EVENTS**

> **Note**: For `INITIAL` and `NEXT` calculations, the insertion values reflect the number of database entries in the project. Update values are estimated based on system nature and objectives.

---

### `CONTRACT`
- **Existing Records**: 2500  
- **Updates**: At least +300/year  
- **Deletions**: None  
- **Storage Parameters**:  
  - `PCTFREE`: 20  
  - `PCTUSED`: 75  
  - **Block Size (T.B.)**: 4096 bytes (default)  

#### Average Field Size
| Field            | Size (bytes) |
|------------------|--------------|
| `ID_CONTRATO`    | 4            |
| `ID_CLIENTE`     | 4            |
| `ID_TARIFARIO`   | 4            |
| `PERIODO_FIDELIZACAO` | 50     |
| `DATA_INICIO`    | 7            |
| `VALIDO`         | 1            |
| **Total**        | **70 bytes** |

#### Record Size Calculations
- **Average Record Size (T.M.R.)**: `70 + 5 (row overhead) + 4 (block overhead) = 79 bytes`  
- **Free Space per Block (E.L.B.)**: `4096 * (100 - 20) / 100 - 84 = 3192 bytes`  
- **Records per Block (N.R.B.)**: `3192 / 79 = 40 records per block`

#### Storage Requirements
1. **Initial Storage (INITIAL)**:  
   - Number of Blocks (N.B.): `2500 / 40 = 63 blocks`  
   - Initial Table Space (E.I.T.): `63 * 4096 = 258 KB`  

2. **Next Storage (NEXT)**:  
   - Predicted Blocks: `300 / 40 = 8 blocks`  
   - Next Table Space (E.N.T.): `8 * 4096 = 32 KB`  

---

### `CLIENT`
- **Existing Records**: 1000  
- **Updates**: At least +100/year  
- **Deletions**: None  
- **Storage Parameters**:  
  - `PCTFREE`: 15  
  - `PCTUSED`: 80  
  - **Block Size (T.B.)**: 4096 bytes (default)  

#### Average Field Size
| Field            | Size (bytes) |
|------------------|--------------|
| `ID_CLIENTE`     | 4            |
| `EMAIL`          | 50           |
| `NOME`           | 100          |
| `MORADA`         | 100          |
| `TELEFONE`       | 10           |
| `SEXO`           | 1            |
| `NACIONALIDADE`  | 20           |
| **Total**        | **285 bytes** |

#### Record Size Calculations
- **Average Record Size (T.M.R.)**: `285 + 5 (row overhead) + 4 (block overhead) = 294 bytes`  
- **Free Space per Block (E.L.B.)**: `4096 * (100 - 15) / 100 - 84 = 3372 bytes`  
- **Records per Block (N.R.B.)**: `3372 / 294 = 11 records per block`

#### Storage Requirements
1. **Initial Storage (INITIAL)**:  
   - Number of Blocks (N.B.): `1000 / 11 = 91 blocks`  
   - Initial Table Space (E.I.T.): `91 * 4096 = 372 KB`  

2. **Next Storage (NEXT)**:  
   - Predicted Blocks: `100 / 11 = 10 blocks`  
   - Next Table Space (E.N.T.): `10 * 4096 = 40 KB`  

---

### `NUM_TELEFONE`
- **Existing Records**: 1010  
- **Updates**: At least +500/year  
- **Deletions**: None  
- **Storage Parameters**:  
  - `PCTFREE`: 25  
  - `PCTUSED`: 70  
  - **Block Size (T.B.)**: 4096 bytes (default)  

#### Average Field Size
| Field         | Size (bytes) |
|---------------|--------------|
| `NUMERO`      | 10           |
| `SALDO`       | 8            |
| `MIN_GASTOS`  | 5            |
| `SMS_GASTOS`  | 5            |
| **Total**     | **28 bytes** |

#### Record Size Calculations
- **Average Record Size (T.M.R.)**: `28 + 5 (row overhead) + 4 (block overhead) = 37 bytes`  
- **Free Space per Block (E.L.B.)**: `4096 * (100 - 25) / 100 - 84 = 2988 bytes`  
- **Records per Block (N.R.B.)**: `2988 / 37 = 80 records per block`

#### Storage Requirements
1. **Initial Storage (INITIAL)**:  
   - Number of Blocks (N.B.): `1010 / 80 = 13 blocks`  
   - Initial Table Space (E.I.T.): `13 * 4096 = 52 KB`  

2. **Next Storage (NEXT)**:  
   - Predicted Blocks: `500 / 80 = 7 blocks`  
   - Next Table Space (E.N.T.): `7 * 4096 = 28 KB`  

---

### `CHAMADA`
- **Existing Records**: 408  
- **Updates**: At least +500/year  
- **Deletions**: None  
- **Storage Parameters**:  
  - `PCTFREE`: 5  
  - `PCTUSED`: 85  
  - **Block Size (T.B.)**: 4096 bytes (default)  

#### Average Field Size
| Field         | Size (bytes) |
|---------------|--------------|
| `ID_CHAMADA`  | 4            |
| `NUMERO`      | 10           |
| `N_DESTINO`   | 5            |
| **Total**     | **29 bytes** |

#### Record Size Calculations
- **Average Record Size (T.M.R.)**: `29 + 5 (row overhead) + 4 (block overhead) = 38 bytes`  
- **Free Space per Block (E.L.B.)**: `4096 * (100 - 5) / 100 - 84 = 3807 bytes`  
- **Records per Block (N.R.B.)**: `3807 / 38 = 100 records per block`

#### Storage Requirements
1. **Initial Storage (INITIAL)**:  
   - Number of Blocks (N.B.): `408 / 100 = 5 blocks`  
   - Initial Table Space (E.I.T.): `5 * 4096 = 20 KB`  

2. **Next Storage (NEXT)**:  
   - Predicted Blocks: `500 / 100 = 5 blocks`  
   - Next Table Space (E.N.T.): `5 * 4096 = 20 KB`  

---

### `EVENTOS`
- **Existing Records**: 57  
- **Updates**: At least +3500/year  
- **Deletions**: None  
- **Storage Parameters**:  
  - `PCTFREE`: 5  
  - `PCTUSED`: 85  
  - **Block Size (T.B.)**: 4096 bytes (default)  

#### Average Field Size
| Field         | Size (bytes) |
|---------------|--------------|
| `ID_EVENTO`   | 4            |
| `ID_CHAMADA`  | 4            |
| `DATA_INI`    | 7            |
| `DATA_FIM`    | 7            |
| **Total**     | **72 bytes** |

#### Record Size Calculations
- **Average Record Size (T.M.R.)**: `72 + 5 (row overhead) + 5 (block overhead) = 82 bytes`  
- **Free Space per Block (E.L.B.)**: `4096 * (100 - 5) / 100 - 84 = 3807 bytes`  
- **Records per Block (N.R.B.)**: `3807 / 82 = 46 records per block`

#### Storage Requirements
1. **Initial Storage (INITIAL)**:  
   - Number of Blocks (N.B.): `57 / 46 = 2 blocks`  
   - Initial Table Space (E.I.T.): `2 * 4096 = 8 KB`  

2. **Next Storage (NEXT)**:  
   - Predicted Blocks: `3500 / 46 = 76 blocks`  
   - Next Table Space (E.N.T.): `76 * 4096 = 304 KB`