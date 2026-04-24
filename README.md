# 📊 Análisis de Riesgo Empresarial (SQL + Python + Machine Learning)

---

## 🧠 Descripción

Proyecto end-to-end donde se integran **SQL Server + Python + Machine Learning** para analizar y clasificar el riesgo financiero de empresas.

---

## 📁 Fuente de datos

🔗 https://www.datosabiertos.gob.pe/dataset/acceso-de-las-mipyme-al-cr%C3%A9dito-en-el-sistema-financiero-formal-ministerio-de-la-produccion

---

# 🗄️ SQL – Preparación y análisis de negocio

---

## 🔹 Limpieza y validación de datos

Se realizó un proceso completo de ETL:

* eliminación de registros inválidos
* tratamiento de valores nulos y negativos
* estandarización de variables

---

## 🔹 Análisis exploratorio en SQL

Se identificaron patrones clave a nivel agregado:

### 📊 Distribución por tamaño de empresa

![Distribución tamaño](images/sql/tamano.png)

---

### 📊 Análisis por sector

![Sector](images/sql/sector.png)

---

### 📊 Análisis geográfico

![Geografía](images/sql/geo.png)

---

## 🎯 Construcción del target

Se definió un indicador de riesgo basado en el ratio deuda/ventas.

![target](images/sql/target.png)

---

# 🐍 Python – Análisis y modelado

---

## 🔍 Análisis Exploratorio

### 📊 Distribución del ratio (problema)

![Ratio original](images/python/ratio.png)

📌 **Hallazgo:**
Distribución altamente sesgada con presencia de valores extremos que dificultan la interpretación.

---

## 🔧 Tratamiento de outliers

Para mejorar la calidad del análisis, se aplicó un recorte de valores extremos:

* uso del percentil 99
* reducción del impacto de outliers
* tranformas a logaritmos par tenr una mejor visualización

📌 **Resultado:**
Se obtuvo una distribución más representativa del comportamiento real de los datos.

---

### 📊 Distribución del ratio (ajustada)

![Ratio limpio](images/python/ratio_limpio.png)

---

## 📊 Distribución del riesgo

![Target](images/python/target_1.png)

📌 Dataset con desbalance moderado entre clases.

---
## 📊 Riesgo por Tamaño de Empresa

![empresa](images/python/empresa.png)
---
## 📊 Riesgo por Sector

![empresa_s](images/python/empresa_s.png)
---

# 🤖 Modelado

---

## 🔴 Modelo sin balanceo

* Sesgo hacia clases mayoritarias
* No detecta correctamente la clase minoritaria


![sin_b](images/python/sin_b.png)

---

## 🟢 Modelo con SMOTE (balanceo real)

* Mejora la detección de "RIESGO MODERADO"
* Mayor equilibrio entre clases

![con_b](images/python/con_b.png)

---

### 📊 Evaluación

![Matriz de confusión](images/python/matriz.png)

---

# 📈 Resultados clave

* El modelo sin balanceo ignora clases minoritarias
* SMOTE mejora significativamente el recall
* El tratamiento de outliers mejora la interpretabilidad del ratio

---

# 🎯 Conclusión

El proyecto demuestra la importancia de:

* tratar valores extremos en datos financieros
* aplicar técnicas de balanceo en modelos de clasificación
* integrar SQL y Python en un flujo completo de análisis

---

