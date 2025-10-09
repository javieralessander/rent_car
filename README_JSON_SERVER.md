# RentCar JSON Server

Este JSON Server proporciona una API REST completa para el desarrollo de la aplicación RentCar Flutter.

## 🚀 Inicio Rápido

### Opción 1: Script de inicio automático
```bash
./start-json-server.sh
```

### Opción 2: Manual
```bash
# Instalar json-server globalmente (solo la primera vez)
npm install -g json-server

# Iniciar el servidor
npm start
```

## 📊 Endpoints Disponibles

El servidor estará disponible en `http://localhost:3000`

### Gestión de Vehículos
- **GET** `/tipos-vehiculos` - Obtener todos los tipos de vehículos
- **POST** `/tipos-vehiculos` - Crear nuevo tipo de vehículo
- **PUT** `/tipos-vehiculos/:id` - Actualizar tipo de vehículo
- **DELETE** `/tipos-vehiculos/:id` - Eliminar tipo de vehículo

- **GET** `/marcas` - Obtener todas las marcas
- **POST** `/marcas` - Crear nueva marca
- **PUT** `/marcas/:id` - Actualizar marca
- **DELETE** `/marcas/:id` - Eliminar marca

- **GET** `/modelos` - Obtener todos los modelos
- **POST** `/modelos` - Crear nuevo modelo
- **PUT** `/modelos/:id` - Actualizar modelo
- **DELETE** `/modelos/:id` - Eliminar modelo

- **GET** `/tipos-combustible` - Obtener tipos de combustible
- **POST** `/tipos-combustible` - Crear tipo de combustible
- **PUT** `/tipos-combustible/:id` - Actualizar tipo de combustible
- **DELETE** `/tipos-combustible/:id` - Eliminar tipo de combustible

- **GET** `/vehiculos` - Obtener todos los vehículos
- **POST** `/vehiculos` - Crear nuevo vehículo
- **PUT** `/vehiculos/:id` - Actualizar vehículo
- **DELETE** `/vehiculos/:id` - Eliminar vehículo

### Gestión de Personas
- **GET** `/clientes` - Obtener todos los clientes
- **POST** `/clientes` - Crear nuevo cliente
- **PUT** `/clientes/:id` - Actualizar cliente
- **DELETE** `/clientes/:id` - Eliminar cliente

- **GET** `/empleados` - Obtener todos los empleados
- **POST** `/empleados` - Crear nuevo empleado
- **PUT** `/empleados/:id` - Actualizar empleado
- **DELETE** `/empleados/:id` - Eliminar empleado

### Proceso de Renta
- **GET** `/inspecciones` - Obtener todas las inspecciones
- **POST** `/inspecciones` - Crear nueva inspección
- **PUT** `/inspecciones/:id` - Actualizar inspección
- **DELETE** `/inspecciones/:id` - Eliminar inspección

- **GET** `/rentas` - Obtener todas las rentas
- **POST** `/rentas` - Crear nueva renta
- **PUT** `/rentas/:id` - Actualizar renta
- **DELETE** `/rentas/:id` - Eliminar renta

## 🔍 Consultas Avanzadas

JSON Server soporta consultas con parámetros:

```bash
# Filtrar por campo
GET /vehiculos?marca=1
GET /clientes?tipoPersona=fisica
GET /rentas?cliente=1

# Búsqueda
GET /clientes?q=Juan
GET /vehiculos?q=Toyota

# Paginación
GET /rentas?_page=1&_limit=10

# Ordenamiento
GET /vehiculos?_sort=id&_order=desc

# Relaciones
GET /modelos?_expand=marca
```

## 📝 Estructura de Datos

### Tipos de Vehículos
```json
{
  "id": 1,
  "descripcion": "Automóvil",
  "estado": true
}
```

### Vehículos
```json
{
  "id": 1,
  "descripcion": "Toyota Corolla 2023",
  "numeroChasis": "TC2023001",
  "numeroMotor": "TM2023001",
  "numeroPlaca": "G123456",
  "tipoVehiculo": 1,
  "marca": 1,
  "modelo": 1,
  "tipoCombustible": 1,
  "estado": true
}
```

### Clientes
```json
{
  "id": 1,
  "nombre": "Juan Pérez",
  "cedula": "001-1234567-8",
  "numeroTarjetaCR": "4111111111111111",
  "limiteCredito": 50000.00,
  "tipoPersona": "fisica",
  "estado": true
}
```

### Empleados
```json
{
  "id": 1,
  "nombre": "Carlos Martínez",
  "cedula": "001-1111111-1",
  "tandaLabor": "matutina",
  "porcientoComision": 5.0,
  "fechaIngreso": "2023-01-15T00:00:00.000Z",
  "estado": true
}
```

### Inspecciones
```json
{
  "id": 1,
  "vehiculo": 1,
  "cliente": 1,
  "tieneRalladuras": false,
  "cantidadCombustible": "Lleno",
  "tieneGomaRespuesta": true,
  "tieneGato": true,
  "tieneRoturasCristal": false,
  "estadoGoma1": true,
  "estadoGoma2": true,
  "estadoGoma3": true,
  "estadoGoma4": true,
  "fecha": "2024-10-08T10:00:00.000Z",
  "empleadoInspeccion": 1,
  "estado": true
}
```

### Rentas
```json
{
  "id": 1,
  "empleado": 1,
  "vehiculo": 1,
  "cliente": 1,
  "fechaRenta": "2024-10-01T09:00:00.000Z",
  "fechaDevolucion": "2024-10-05T17:00:00.000Z",
  "montoPorDia": 2500.00,
  "cantidadDias": 4,
  "comentario": "Renta para viaje de negocios",
  "estado": true
}
```

## ⚙️ Configuración de Flutter

Actualiza tu archivo `.env.development` en Flutter:

```env
API_URL=http://localhost:3000
```

## 🔧 Comandos Útiles

```bash
# Reiniciar con datos iniciales
npm run dev

# Ver todas las rutas disponibles
curl http://localhost:3000

# Backup de la base de datos
cp db.json db.backup.json
```

## 📱 Integración con Flutter

Los servicios de Flutter ya están configurados para usar estos endpoints. Simplemente asegúrate de que el JSON Server esté corriendo antes de probar la aplicación.

## 🚨 Notas Importantes

- Los datos se almacenan en `db.json` y persisten entre reinicios
- El servidor incluye un delay de 200ms para simular latencia real
- Soporta CORS para desarrollo desde Flutter web
- Los IDs se auto-incrementan automáticamente