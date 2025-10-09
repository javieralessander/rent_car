#!/bin/bash

# RentCar JSON Server Startup Script
echo "🚗 Iniciando RentCar JSON Server..."

# Check if json-server is installed locally
if [ ! -d "node_modules/json-server" ]; then
    echo "📦 json-server no está instalado localmente. Instalando..."
    npm install json-server
fi

# Start the JSON server
echo "🚀 Iniciando servidor en puerto 3001..."
echo "📊 Datos disponibles en:"
echo "   - Tipos de Vehículos: http://localhost:3001/tipos-vehiculos"
echo "   - Marcas: http://localhost:3001/marcas"
echo "   - Modelos: http://localhost:3001/modelos"
echo "   - Tipos de Combustible: http://localhost:3001/tipos-combustible"
echo "   - Vehículos: http://localhost:3001/vehiculos"
echo "   - Clientes: http://localhost:3001/clientes"
echo "   - Empleados: http://localhost:3001/empleados"
echo "   - Inspecciones: http://localhost:3001/inspecciones"
echo "   - Rentas: http://localhost:3001/rentas"
echo ""
echo "🔧 Para detener el servidor: Ctrl + C"
echo ""

npx json-server --watch db.json --port 3001 --host localhost --delay 200