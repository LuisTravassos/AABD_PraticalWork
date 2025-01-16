# Physical Parameter Calculations (Example/Model)

## Fixed and Variable Headers
- **Fixed Header (HF)**: 84 bytes  
- **Variable Header (HV)**: 5 bytes per record  
  - 2 bytes for record header  
  - 1 byte for the number of columns  
  - 2 bytes for the Row Directory  

## Storage Parameters
- **PCTFREE**: X (1 to 25)  
- **PCTUSED**: Y (40 to 95)  
- **Block Size (T.B.)**: 4096 bytes (default)  
- **Average Record Size (T.M.R.)**:  
  - Sum of average field sizes  
  - +5 bytes per record (Variable Header)  
  - +1 byte per column  

### Free Space in Block
**Free Space in Block (E.L.B.):**  
\[ \text{Block Size} \times \frac{(100 - \text{PCTFREE})}{100} - \text{Fixed Header} \]

### Records Per Block
**Records Per Block (N.R.B.):**  
\[ \text{Free Space in Block} / \text{Average Record Size} \]  
(*Rounded down to the nearest whole number*)

---

## Initial Space Calculation

### Initial Number of Blocks
**Initial Number of Blocks (N.B.):**  
\[ \text{Existing Records} / \text{Records Per Block} \]  
(*Rounded up to the nearest whole number*)

### Initial Table Space
**Initial Table Space (E.I.T.):**  
\[ \text{Number of Blocks} \times \text{Block Size} \]

---

## Next Space Calculation

### Predicted Number of Blocks
**Predicted Number of Blocks (N.B.):**  
\[ \text{Predicted Records} / \text{Records Per Block} \]  
(*Rounded up to the nearest whole number*)

### Next Table Space
**Next Table Space (E.N.T.):**  
\[ \text{Predicted Number of Blocks} \times \text{Block Size} \]

---

## Selected Tables
The five tables in our system (**AABD Telecom**) expected to occupy the most space are:
- **CONTRACT**
- **CLIENT**
- **PHONE_NUMBER**
- **CALL**
- **EVENTS**

> **Note**: For `INITIAL` and `NEXT` calculations, the insertion values reflect the number of database entries in the project. Update values are estimated based on system nature and objectives.

---

### **CONTRACT**
- **Existing Records**: 599  
- **Updates**: At least +500/year  
- **Deletions**: None  
- **PCTFREE**: 10  
- **PCTUSED**: 80  
- **Block Size**: 4096 bytes  

#### Field Sizes
| Field              | Size (bytes) |
|--------------------|--------------|
| ID_CONTRACT        | 4            |
| ID_TARIFF          | 4            |
| NUMBER             | 9            |
| ID_CLIENT          | 4            |
| LOYALTY_PERIOD     | 2            |
| START_DATE         | 7            |
| VALID              | 1            |
| **Sum**            | **31**       |

#### Calculations
- **Average Record Size (T.M.R.)**: 31 + 5 + 7 = 43 bytes  
- **Free Space in Block (E.L.B.)**:  
  \[ 4096 \times \frac{(100 - 10)}{100} - 84 = 4012.90 \text{ bytes} \]  
- **Records Per Block (N.R.B.)**:  
  \[ 4012.90 / 43 = 93 \]

**Initial Space**  
- **Initial Number of Blocks**:  
  \[ 599 / 93 = 7 \]  
- **Initial Table Space (E.I.T.)**:  
  \[ 7 \times 4096 = 28672 \text{ bytes} \]

**Next Space**  
- **Predicted Number of Blocks**:  
  \[ 500 / 93 = 6 \]  
- **Next Table Space (E.N.T.)**:  
  \[ 6 \times 4096 = 22021.50 \text{ bytes} \]

---

### **CLIENT**
- **Existing Records**: 390  
- **Updates**: At least +500/year  
- **Deletions**: None  
- **PCTFREE**: 20  
- **PCTUSED**: 75  
- **Block Size**: 4096 bytes  

#### Field Sizes
| Field              | Size (bytes) |
|--------------------|--------------|
| ID_CLIENT          | 4            |
| EMAIL              | 100          |
| BIRTH_DATE         | 7            |
| TAX_ID             | 9            |
| NAME               | 100          |
| GENDER             | 50           |
| NATIONALITY        | 50           |
| **Sum**            | **320**      |

#### Calculations
- **Average Record Size (T.M.R.)**: 320 + 5 + 7 = 332 bytes  
- **Free Space in Block (E.L.B.)**:  
  \[ 4096 \times \frac{(100 - 20)}{100} - 84 = 3192 \text{ bytes} \]  
- **Records Per Block (N.R.B.)**:  
  \[ 3192 / 332 = 9 \]

**Initial Space**  
- **Initial Number of Blocks**:  
  \[ 390 / 9 = 44 \]  
- **Initial Table Space (E.I.T.)**:  
  \[ 44 \times 4096 = 0.17 \text{ MB} \]

**Next Space**  
- **Predicted Number of Blocks**:  
  \[ 500 / 9 = 55.56 \]  
- **Next Table Space (E.N.T.)**:  
  \[ 55.56 \times 4096 = 0.21 \text{ MB} \]

---

### Remaining Tables
Details for **PHONE_NUMBER**, **CALL**, and **EVENTS** follow the same structure above. Calculations include specific field sizes, adjustments for updates, and allocation estimates for `INITIAL` and `NEXT` based on record growth.
