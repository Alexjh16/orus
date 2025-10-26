# Usar Nginx para servir archivos estáticos
FROM nginx:alpine

# Copiar los archivos construidos al directorio de Nginx
COPY build/web /usr/share/nginx/html

# Exponer el puerto 80
EXPOSE 80

# Comando por defecto de Nginx
CMD ["nginx", "-g", "daemon off;"]