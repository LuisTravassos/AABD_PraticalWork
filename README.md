# Telecommunications Database Project  

Welcome to the **Telecommunications Database Project**! This repository hosts a comprehensive Oracle SQL database solution for managing telecom services, including client contracts, billing, calls, SMS, and marketing campaigns.  

---

## Key Features  
- **Oracle SQL Implementation**: Leveraged advanced Oracle SQL features such as PL/SQL stored procedures, triggers, and materialized views.  
- **Data Integrity**: Enforced via constraints (PK, FK, UNIQUE), normalization, and transactional error handling.  
- **Scalability**: Optimized with indexing, partitioning strategies, and modular code design.  

---

## Technical Highlights  
- **ER Modeling**: Designed entity-relationship diagrams to map business logic into relational tables.  
- **PL/SQL Automation**: Developed triggers for real-time data validation and procedures for batch operations.  
- **Performance Tuning**: Applied Oracle-specific indexing and query optimization techniques.  

---

## Language Note

**Important**: Some parts of the code and documentation are written in **Portuguese (Portugal)** as the project was originally developed in that language. However, the repository is organized to be intuitive, and additional explanations are provided in English to ensure broader accessibility.

---

## Database Diagram

Below is the database schema diagram for the project:

![Database Diagram](docs/database_diagram.png)

---

## Repository Structure

The repository is divided into three main sections:

### **1. Documentation (`docs/`)**
Contains all the supporting materials to understand the database's structure, design decisions, and operational integrity:
- **`database_diagram.png`**: A visual representation of the database schema.
- **`integrity_mechanisms.md`**: Explanation of the mechanisms used to ensure data integrity (e.g., constraints, triggers).
- **`physical_parameters.md`**: Details the physical design considerations (e.g., indexes, partitioning, storage).
- **`schema_description.md`**: A detailed description of the database schema, tables, fields, and relationships.

### **2. SQL Files (`sql/`)**
Houses all the SQL scripts necessary to create and manage the database:
- **`create_database.sql`**: Script to create the database schema and define its tables and relationships.
- **`functions_code.sql`**: Contains SQL functions that implement custom business logic.
- **`procedures_code.sql`**: Includes stored procedures for batch operations or reusable workflows.
- **`triggers_code.sql`**: Defines database triggers for automated actions.
- **`views_code.sql`**: Scripts for creating database views that simplify querying complex data.

---

## License

This project is licensed under the [MIT License](/LICENSE). Feel free to use, modify, and distribute this project.
