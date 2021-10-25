#!/bin/bash

if [ $SERVICE != product-db ]; then
   mkdir -p /opt/consul
   echo "Starting Consul..."
   nohup consul agent -config-dir=/config/ > /tmp/consul.out 2>&1 &
fi

if [ $SERVICE == payments ]; then
 echo "Starting the payment application..."
  java -jar /bin/spring-boot-payments-0.0.12.jar > /spring_boot.out 2>&1 &
  sleep 3
  echo "Registering the service..."
  if [ consul services register /tmp/svc_payments.hcl ]; then
      nohup consul connect envoy -sidecar-for $SERVICE > /tmp/proxy.log 2>&1
   else 
      sleep 2
      consul services register /tmp/svc_payments.hcl
      nohup consul connect envoy -sidecar-for $SERVICE > /tmp/proxy.log 2>&1 
  fi
  
fi


if [ $SERVICE == public-api ]; then
 echo "Starting the Public-API application..."
   nohup /bin/public-api > /api.out 2>&1 &
   sleep 3

   if [ consul services register /config/svc_public_api.hcl ]; then
      consul config write /tmp/default-intentions.hcl
      nohup consul connect envoy -sidecar-for $SERVICE > /tmp/proxy.log 2>&1
   else
      sleep 2
      consul services register /config/svc_public_api.hcl
      consul config write /tmp/default-intentions.hcl
      nohup consul connect envoy -sidecar-for $SERVICE > /tmp/proxy.log 2>&1
   fi

fi


if [ $SERVICE == product-api ]; then
   echo "Starting the Product-API application..."
   /bin/wait.sh
   if [ consul services register /config/svc_product_api.hcl ]; then
         nohup /bin/product-api > /api.out 2>&1 &
         nohup consul connect envoy -sidecar-for $SERVICE > /tmp/proxy.log 2>&1 
   else 
         sleep 1
         consul services register /config/svc_product_api.hcl
         nohup /bin/product-api > /api.out 2>&1 &
         nohup consul connect envoy -sidecar-for $SERVICE > /tmp/proxy.log 2>&1 
   fi
fi

if [ $SERVICE == product-db ]; then
   sudo mv /tmp/pg_hba.conf /var/lib/postgresql/data/
   # Killing postgress
   echo "Terminating postgress..."
   pkill postgres
   sleep 3
   echo "Starting postgres DB.."
   nohup postgres 2>&1 &
   echo "Starting Consul..."
   sudo mkdir -p /opt/consul
   sudo nohup consul agent -config-dir=/config/ > /tmp/consul.out 2>&1 &
   echo "Registering the service..."
   sleep 2
   echo "Populate table.."
   if [ psql postgres://postgres:password@localhost:5432/products?sslmode=disable -f /docker-entrypoint-initdb.d/products.sql ]; then
         consul services register /tmp/svc_db.hcl
         sudo nohup consul connect envoy -sidecar-for $SERVICE > /tmp/proxy.log 2>&1 
   else
      sleep 2
      psql postgres://postgres:password@localhost:5432/products?sslmode=disable -f /docker-entrypoint-initdb.d/products.sql
      consul services register /tmp/svc_db.hcl
      sudo nohup consul connect envoy -sidecar-for $SERVICE > /tmp/proxy.log 2>&1 
   fi

fi

if [ $SERVICE == frontend ]; then
  echo "Starting the Frontend application..."
  sleep 3
  consul services register /tmp/svc_frontend.hcl && \
  consul connect envoy -sidecar-for $SERVICE & > /tmp/proxy.log 2>&1
  sleep 1
  nginx
  while true; do sleep 1; done 
fi
