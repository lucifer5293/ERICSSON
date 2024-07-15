#!/bin/bash
# Script Name: System_backup.sh
# Description: This script take the backup of system.
# Author: Arun Singh A
# Date: 18-April-2023
#set -x
 
#while read LINE; do export "$LINE"; done < ./variables.txt
 
HOME=/home/$USER
 
# Set the namespace
namespace="weca-benin-test"
 
# Get the current date in the "YYYY-MM-DD_HH:MM:SS" format
CURRENT_DATE_TIME=$(date '+%Y-%m-%d_%H:%M:%S')
 
#echo y | kubectl hpecp authenticate $HPEC_URL --hpecp-user=$HPEC_USER --hpecp-pass="$HPEC_PASSWORD"
 
# Backup directory
backup_dir="$HOME/BACKUPS/backup_$CURRENT_DATE_TIME/"
 
# Function to display colorful messages
function print_message {
  case "$2" in
    "success") echo -e "\e[32m$1\e[0m";;
    "info") echo -e "\e[34m$1\e[0m";;
    "warning") echo -e "\e[33m$1\e[0m";;
    "error") echo -e "\e[31m$1\e[0m";;
    *) echo "$1";;
  esac
}
 
# Display welcome message
print_message "Welcome to the Interactive Kubernetes Backup Script!" "info"
 
# Confirmation prompt
read -p "Do you want to proceed with the backup? (y/n): " confirm_backup
if [ "$confirm_backup" != "y" ]; then
  print_message "Backup canceled. Exiting script." "info"
  exit 1
fi
 
# Backup for ConfigMaps
print_message "Backing up ConfigMaps..." "info"
mkdir -p "$backup_dir/configmap/$namespace"
cd "$backup_dir/configmap/$namespace"
 
# Export each ConfigMap in the namespace
for i in $(kubectl -n "$namespace" get configmaps | grep -v NAME | awk '{print $1}'); do
  k8s-export-configmap --namespace "$namespace" "$i" "$i" > /dev/null
done
 
print_message "Backup of ConfigMaps completed." "success"
 
# Function to backup resources
function backup_resources {
  resource_type=$1
  print_message "Backing up $resource_type..." "info"
  mkdir -p "$backup_dir/$resource_type/$namespace"
  cd "$backup_dir/$resource_type/$namespace"
 
  for i in $(kubectl -n "$namespace" get "$resource_type" | grep -v NAME | awk '{print $1}'); do
    kubectl -n "$namespace" get "$resource_type" "$i" -o yaml > "$i.yaml" 
  done
 
  print_message "Backup of $resource_type completed." "success"
}
 
# Backup Secrets
backup_resources "secrets"
 
# Backup Services
backup_resources "services"
 
# Backup ServiceAccounts
backup_resources "serviceaccounts"
 
# Backup StatefulSets (STS)
backup_resources "sts"
 
# Backup Deployments
backup_resources "deployment"
 
# Backup NetworkPolicies
backup_resources "networkpolicies"
 
print_message "Backing up Helmfile..." "info"
 
# Taking backup of Helmfile
backup_name="Backup for helmfile"
backup_dir="$HOME/BACKUPS/backup_$CURRENT_DATE_TIME/helmfile"
mkdir -p "$backup_dir"
sudo cp -apr /etc/ewp/helmfile $backup_dir
 
print_message "Backup of helmfile completed." "success"
 
print_message "Backing up for overall backup..." "info"
 
# Taking status of pods and helm list
backup_name="Backup for overall-status"
backup_dir="$HOME/BACKUPS/backup_$CURRENT_DATE_TIME/overall-status"
mkdir -p "$backup_dir"
kubectl get pod -o wide > $backup_dir/pod-status.txt 2>/dev/null
helm list > $backup_dir/helmlist.txt 2>/dev/null
kubectl get svc > $backup_dir/svc.txt 2>/dev/null
kubectl get pvc > $backup_dir/pvc.txt 2>/dev/null
kubectl get networkpolicies > $backup_dir/networkpolicy.txt 2>/dev/null
kubectl get sts > $backup_dir/statefulset.txt 2>/dev/null
kubectl get serviceaccounts > $backup_dir/serviceaccounts.txt 2>/dev/null
kubectl get configmap > $backup_dir/configmap.txt 2>/dev/null
kubectl get secrets > $backup_dir/secrets.txt 2>/dev/null
df -hT > $backup_dir/disk-space.txt 2>/dev/null
cat /etc/hosts > $backup_dir/host.txt 2>/dev/null
k8s-ca-list > $backup_dir/ca-list.txt 2>/dev/null
 
print_message "Backup of overall backup is completed." "success"
 
# Display completion message
print_message "Backup completed. Files are saved in: $HOME/BACKUPS/backup_$CURRENT_DATE_TIME/" "success"
