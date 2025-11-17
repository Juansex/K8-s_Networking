# Implementación de Servicios en Kubernetes

Este proyecto implementa una arquitectura de microservicios en Kubernetes utilizando Minikube, demostrando diferentes tipos de servicios de red y configuraciones de ingress.

## Arquitectura

El proyecto consta de cuatro componentes principales:

- **Web Server**: Servidor frontend con nginx expuesto mediante LoadBalancer
- **API Server**: Servidor backend con Apache httpd usando ClusterIP
- **App Server**: Servidor de aplicaciones con Caddy usando NodePort
- **Data Server**: Servicio de datos con busybox accesible via Ingress

## Requisitos Previos

- Minikube instalado
- kubectl configurado
- 4GB RAM mínimo disponible
- Conexión a Internet para descargar imágenes

## Tipos de Servicios Implementados

### LoadBalancer

Utilizado por el componente `web-server` para exponer el servicio al exterior del cluster. Este tipo de servicio provisiona automáticamente un balanceador de carga externo.

**Características:**
- Asignación automática de IP externa
- Distribución de carga entre pods
- Acceso directo desde el host

### ClusterIP

Implementado en `api-server` y `data-server` para comunicación interna. Es el tipo de servicio predeterminado que crea una IP virtual accesible únicamente dentro del cluster.

**Características:**
- Comunicación inter-servicios
- No expuesto externamente
- Mayor seguridad

### NodePort

Configurado para `app-server`, expone el servicio en un puerto específico de cada nodo del cluster.

**Características:**
- Puerto fijo (30080)
- Accesible mediante IP del nodo
- Útil para desarrollo y testing

### Ingress

Gestiona el acceso HTTP/HTTPS externo a los servicios, proporcionando enrutamiento basado en nombres de host.

**Hosts configurados:**
- `data.local`: Redirige al servicio de datos
- `api.local`: Redirige al servicio API

## Estructura del Proyecto

```
.
├── manifests/
│   ├── web-deployment.yaml      # Deployment del servidor web
│   ├── web-service.yaml         # LoadBalancer para web
│   ├── api-deployment.yaml      # Deployment del API
│   ├── api-service.yaml         # ClusterIP para API
│   ├── app-deployment.yaml      # Deployment de aplicación
│   ├── app-service.yaml         # NodePort para app
│   ├── service-deployment.yaml  # Deployment de servicio de datos
│   ├── service-service.yaml     # ClusterIP para datos
│   └── ingress.yaml             # Configuración de Ingress
├── scripts/
│   ├── deploy.sh                # Script de despliegue
│   ├── cleanup.sh               # Script de limpieza
│   └── status.sh                # Script de verificación
└── README.md
```

## Instalación y Configuración

### Paso 1: Iniciar Minikube

```bash
minikube start --cpus=2 --memory=4096
```

Verificar que el cluster esté corriendo:

```bash
minikube status
```

### Paso 2: Habilitar el Addon de Ingress

```bash
minikube addons enable ingress
```

Esto instala el controlador NGINX Ingress Controller en el cluster.

### Paso 3: Desplegar los Recursos

Ejecutar el script de despliegue:

```bash
./scripts/deploy.sh
```

O aplicar los manifiestos manualmente:

```bash
kubectl apply -f manifests/
```

### Paso 4: Configurar Hosts Locales

Obtener la IP de Minikube:

```bash
minikube ip
```

Agregar las siguientes líneas al archivo `/etc/hosts` (reemplazar con la IP obtenida):

```
<MINIKUBE_IP> data.local
<MINIKUBE_IP> api.local
```

### Paso 5: Iniciar el Túnel para LoadBalancer

En una terminal separada, ejecutar:

```bash
minikube tunnel
```

Este comando requiere privilegios de administrador y debe mantenerse en ejecución.

## Verificación de Servicios

### Verificar Estado General

```bash
./scripts/status.sh
```

O manualmente:

```bash
kubectl get all
```

### Probar LoadBalancer (Web Server)

```bash
kubectl get svc web-loadbalancer
curl http://<EXTERNAL-IP>
```

### Probar ClusterIP (API Server)

Desde dentro del cluster:

```bash
kubectl run test-pod --image=curlimages/curl -it --rm --restart=Never -- curl http://api-clusterip
```

### Probar NodePort (App Server)

```bash
minikube service app-nodeport --url
curl $(minikube service app-nodeport --url)
```

O acceder directamente:

```bash
curl http://$(minikube ip):30080
```

### Probar Ingress

```bash
curl http://data.local
curl http://api.local
```

## Descripción de Recursos

### Deployments

Cada deployment está configurado con:
- Réplicas para alta disponibilidad
- Límites de recursos (CPU y memoria)
- Labels para identificación
- Health checks implícitos

### Services

Los servicios proporcionan:
- Descubrimiento de servicios automático
- Balanceo de carga entre pods
- Abstracción de la red interna

### Ingress

El ingress ofrece:
- Enrutamiento basado en host
- Terminación SSL/TLS (configurable)
- Reescritura de URLs
- Punto de entrada único

## Comandos Útiles

### Verificar pods en ejecución:
```bash
kubectl get pods -o wide
```

### Ver logs de un pod:
```bash
kubectl logs <pod-name>
```

### Describir un recurso:
```bash
kubectl describe service <service-name>
```

### Escalar un deployment:
```bash
kubectl scale deployment web-server --replicas=5
```

### Ver eventos del cluster:
```bash
kubectl get events --sort-by='.lastTimestamp'
```

## Limpieza

Para eliminar todos los recursos:

```bash
./scripts/cleanup.sh
```

O manualmente:

```bash
kubectl delete -f manifests/
```

Detener Minikube:

```bash
minikube stop
```

Eliminar el cluster completamente:

```bash
minikube delete
```

## Resolución de Problemas

### Los pods no inician

Verificar recursos disponibles:
```bash
kubectl describe pod <pod-name>
```

### El servicio LoadBalancer permanece en Pending

Asegurarse de que `minikube tunnel` esté en ejecución.

### Ingress no responde

Verificar que el addon esté habilitado:
```bash
minikube addons list | grep ingress
```

Verificar logs del ingress controller:
```bash
kubectl logs -n ingress-nginx <ingress-controller-pod>
```

### No se puede acceder a NodePort

Verificar el puerto asignado:
```bash
kubectl get svc app-nodeport
```

Usar la IP de Minikube, no localhost:
```bash
curl http://$(minikube ip):30080
```

## Consideraciones de Producción

Este proyecto está diseñado para entornos de desarrollo y aprendizaje. Para producción considerar:

- Implementar TLS/SSL en Ingress
- Configurar health checks y readiness probes
- Establecer políticas de red (NetworkPolicies)
- Implementar autoscaling (HPA)
- Configurar persistent volumes para datos
- Implementar monitoreo y logging centralizado
- Definir resource quotas y limit ranges
- Usar namespaces para aislamiento

## Referencias

- Documentación oficial de Kubernetes: https://kubernetes.io/docs/
- Minikube: https://minikube.sigs.k8s.io/docs/
- NGINX Ingress Controller: https://kubernetes.github.io/ingress-nginx/