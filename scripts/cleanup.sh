#!/bin/bash

echo "Eliminando recursos de Kubernetes..."

echo "Eliminando Ingress..."
kubectl delete -f manifests/ingress.yaml --ignore-not-found=true

echo "Eliminando Services..."
kubectl delete -f manifests/web-service.yaml --ignore-not-found=true
kubectl delete -f manifests/api-service.yaml --ignore-not-found=true
kubectl delete -f manifests/app-service.yaml --ignore-not-found=true
kubectl delete -f manifests/service-service.yaml --ignore-not-found=true

echo "Eliminando Deployments..."
kubectl delete -f manifests/web-deployment.yaml --ignore-not-found=true
kubectl delete -f manifests/api-deployment.yaml --ignore-not-found=true
kubectl delete -f manifests/app-deployment.yaml --ignore-not-found=true
kubectl delete -f manifests/service-deployment.yaml --ignore-not-found=true

echo "Limpieza completada."
