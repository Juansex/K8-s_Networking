#!/bin/bash

echo "Desplegando recursos de Kubernetes..."

echo "Aplicando Deployments..."
kubectl apply -f manifests/web-deployment.yaml
kubectl apply -f manifests/api-deployment.yaml
kubectl apply -f manifests/app-deployment.yaml
kubectl apply -f manifests/service-deployment.yaml

echo "Esperando a que los deployments esten listos..."
kubectl wait --for=condition=available --timeout=120s deployment/web-server
kubectl wait --for=condition=available --timeout=120s deployment/api-server
kubectl wait --for=condition=available --timeout=120s deployment/app-server
kubectl wait --for=condition=available --timeout=120s deployment/data-server

echo "Aplicando Services..."
kubectl apply -f manifests/web-service.yaml
kubectl apply -f manifests/api-service.yaml
kubectl apply -f manifests/app-service.yaml
kubectl apply -f manifests/service-service.yaml

echo "Aplicando Ingress..."
kubectl apply -f manifests/ingress.yaml

echo "Despliegue completado. Verificando estado..."
kubectl get deployments
kubectl get services
kubectl get ingress

echo "Despliegue finalizado exitosamente."
