#!/bin/bash

# Script para limpiar prints del proyecto Flutter
# Este script reemplaza todos los print() statements con Logger equivalents

echo "🧹 Iniciando limpieza de prints en el proyecto..."

# Buscar todos los archivos .dart que contienen print(
files_with_prints=$(find . -name "*.dart" -type f -exec grep -l "print(" {} \;)

if [ -z "$files_with_prints" ]; then
    echo "✅ No se encontraron archivos con print() statements"
    exit 0
fi

echo "📁 Archivos encontrados con print() statements:"
echo "$files_with_prints"

echo ""
echo "🔄 Procesando archivos..."

# Procesar cada archivo
for file in $files_with_prints; do
    echo "📝 Procesando: $file"
    
    # Backup del archivo original
    cp "$file" "$file.backup"
    
    # Reemplazos comunes
    sed -i "s/print('/Logger.debug('/g" "$file"
    sed -i "s/print(\"/Logger.debug(\"/g" "$file"
    sed -i "s/print(\${/Logger.debug(\${/g" "$file"
    
    # Agregar import si no existe
    if ! grep -q "import.*logger.dart" "$file"; then
        # Buscar la línea después de los imports existentes
        if grep -q "^import" "$file"; then
            # Agregar después del último import
            sed -i "/^import.*dart';$/a import '../../../../core/utils/logger.dart';" "$file"
        else
            # Si no hay imports, agregar al principio
            sed -i "1i import '../../../../core/utils/logger.dart';" "$file"
        fi
    fi
done

echo ""
echo "✅ Limpieza completada!"
echo "💾 Se crearon backups con extensión .backup"
echo ""
echo "📊 Resumen:"
echo "- Archivos procesados: $(echo "$files_with_prints" | wc -l)"
echo "- Logger imports agregados donde era necesario"
echo "- print() reemplazados por Logger.debug()"
echo ""
echo "🔍 Para revisar los cambios, ejecuta:"
echo "flutter analyze"
