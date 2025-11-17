#!/bin/bash

echo "Estado del Cluster Kubernetes"
echo "=============================="
echo ""

echo "Deployments:"
kubectl get deployments -o wide
echo ""

echo "Pods:"
kubectl get pods -o wide
echo ""

echo "Services:"
kubectl get services -o wide
echo ""

echo "Ingress:"
kubectl get ingress
echo ""

echo "Eventos recientes:"
kubectl get events --sort-by='.lastTimestamp' | tail -10
